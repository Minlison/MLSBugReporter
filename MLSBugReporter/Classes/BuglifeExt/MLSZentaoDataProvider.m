//
//  MLSZentaoDataProvider.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSZentaoDataProvider.h"
#import "LIFEReport.h"
#import "LIFEReproStep.h"
#import "LIFEMacros.h"
#import "LIFEAppInfo.h"
#import "LIFEAppInfoProvider.h"
#import "LIFENetworkManager.h"
#import "LIFEUserDefaults.h"
#import "LIFEReportOwner.h"
#import "Buglife+Protected.h"
#import "NSMutableDictionary+LIFEAdditions.h"
#import "NSError+LIFEAdditions.h"
#import "MLSBugReportCreateBugReq.h"
#import "MLSBugReporterOptions.h"
#import "LIFEReportAttachmentImpl.h"
#import "MLSZenTaoUploadFileReq.h"
#import "LIFEAVFoundation.h"
#import "LIFEVideoAttachment.h"
#import "MLSBugReporterManager+Private.h"
#import "Matrix.h"
#import "MLSBugLogger.h"
#import "MLSDeviceInfoTool.h"
#import <MLSUICore/MLSUICore.h>
#import <AFNetworking/AFNetworking.h>

@interface LIFEDataProvider ()
@property (nonatomic) LIFEReportOwner *reportOwner;
@property (nonatomic) NSString *sdkVersion;
@property (nonatomic) NSString *sdkName;
@property (nonatomic) LIFEAppInfoProvider *appInfoProvider;
//@property (nonatomic) LIFENetworkManager *networkManager;
@property (nonatomic) dispatch_queue_t workQueue;
- (void)_savePendingReport:(LIFEReport *)report;
- (void)_removeSavedReport:(LIFEReport *)report;
@end
@implementation MLSZentaoDataProvider

- (void)_submitReport:(nonnull LIFEReport *)report withRetryPolicy:(LIFERetryPolicy)retryPolicy fromPendingReportsDirectory:(BOOL)isFromPendingReportsDir completion:(nullable LIFEDataProviderSubmitCompletion)completion
{
    NSParameterAssert(self.reportOwner);
    NSParameterAssert(self.sdkVersion);
    // Submission attempts should be incremented *before* serializing to JSON or caching.
    report.submissionAttempts += 1;
    
    NSMutableDictionary *reportDict = [report JSONDictionary].mutableCopy;
    [LIFENSMutableDictionaryify(reportDict) life_safeSetObject:self.sdkVersion forKey:@"sdk_version"];
    [LIFENSMutableDictionaryify(reportDict) life_safeSetObject:self.sdkName forKey:@"sdk_name"];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    mutableParameters[@"report"] = reportDict;
   
    NSMutableDictionary *appDict = [report.appInfo JSONDictionary].mutableCopy;
    mutableParameters[@"app"] = appDict;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    BOOL saveFailedSubmissions = (!isFromPendingReportsDir && retryPolicy == LIFERetryPolicyNextLaunch);
    BOOL removeSuccessfulSubmissions = (saveFailedSubmissions || isFromPendingReportsDir);
    
    // Save pending reports if required by the retry policy
    if (saveFailedSubmissions) {
        // TODO: Need to remove & re-save so that submissionAttempts actually increments beyond 2
        [self _savePendingReport:report];
    }
    LIFEAttribute *bugModelAttr = [report.attributes objectForKey:@"bugModel"];
    if (bugModelAttr) {
        MLSZenTaoBugModel *bugModel = [MLSZenTaoBugModel mls_modelWithJSON:bugModelAttr.stringValue];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"title" : bugModel.bugTitle?:@"",
                                                                                    @"assignedTo" : bugModel.assignedTo,
                                                                                    @"openedBuild" : bugModel.openedBuild,
                                                                                    @"product" : @(bugModel.productID).stringValue,
                                                                                    @"severity" : @(bugModel.severity).stringValue,
                                                                                    @"steps" : bugModel.steps?:@"",
                                                                                    @"type" : bugModel.type,
                                                                                    @"pri" : bugModel.pri,
                                                                                    @"os" : bugModel.os,
                                                                                    }];
        
        if (bugModel.moduleID > 0) {
            [params setObject:@(bugModel.moduleID).stringValue forKey:@"module"];
        }
        NSMutableString *steps = [[NSMutableString alloc] init];
        // 拼接应用信息
        [MLSDeviceInfoTool appendApplicaitonInfo:steps];
        
        if ([bugModel.steps containsString:@"\n"]) {
            [[bugModel.steps componentsSeparatedByString:@"\n"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [steps appendFormat:@"<p>%@</p>",obj];
            }];
        } else {
            [steps appendFormat:@"<p>%@</p>",bugModel.steps];
        }
        [params setObject:steps forKey:@"steps"];
        
        dispatch_group_t group = dispatch_group_create();
        NSMutableArray <LIFEReportAttachmentImpl *>*mutableAttachments = [NSMutableArray arrayWithArray:report.attachments];
        // 上传图片
        [self uploadImagesWithMutableAttachments:mutableAttachments steps:steps inGroup:group];
        
        dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
            
            [params setObject:steps forKey:@"steps"];
            [self reportToZentao:report mutableAttachments:mutableAttachments bugModel:bugModel params:params removeSuccessfulSubmissions:removeSuccessfulSubmissions completion:completion];
            
        });
    }
}
- (void)reportToZentao:(LIFEReport *)report mutableAttachments:(NSMutableArray <LIFEReportAttachmentImpl *>*)mutableAttachments bugModel:(MLSZenTaoBugModel *)bugModel params:(NSDictionary *)params removeSuccessfulSubmissions:(BOOL)removeSuccessfulSubmissions completion:(nullable LIFEDataProviderSubmitCompletion)completion {
    MLSBugReportCreateBugReq *req = [MLSBugReportCreateBugReq requestWithProductID:@(bugModel.productID).stringValue params:nil];
    req.constructingBodyBlock = ^(id<AFMultipartFormData> formData) {
        // 参数
        [params enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
            [formData appendPartWithFormData:[obj dataUsingEncoding:NSUTF8StringEncoding] name:key];
        }];
        
        // 视频文件
        [mutableAttachments enumerateObjectsUsingBlock:^(LIFEReportAttachmentImpl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 视频
            if (([obj.uniformTypeIdentifier isEqualToString:LIFEAVFileTypeMPEG4]
                 || [obj.uniformTypeIdentifier isEqualToString:LIFEAVAssetExportPresetHighestQuality]
                 || [obj.uniformTypeIdentifier isEqualToString:LIFEAVMediaTypeVideo]
                 || [obj.uniformTypeIdentifier isEqualToString:LIFEAttachmentTypeIdentifierCrashText])) {
                [formData appendPartWithFileData:obj.attachmentData name:@"files[]" fileName:obj.filename mimeType:obj.uniformTypeIdentifier];
            }
        }];
        
        
        // 日志文件
        [self appendLogFiles:formData];
    };
    [req startWithModelCompletionBlockWithSuccess:^(__kindof MLSBugReportCreateBugReq *request, MLSZenTaoBugModel *model) {
        
        if ([request.responseJSONObject objectForKey:@"locate"]) {
            [self _removeSavedReport:report removeSuccessfulSubmissions:removeSuccessfulSubmissions];
            if (completion) {
                completion(YES);
            }
        } else {
            if (completion) {
                completion(NO);
            }
        }
    } failure:^(__kindof MLSNetworkRequest *request, MLSBugReportCreateBugReq *model) {
        if (completion) {
            completion(NO);
        }
    }];
}
- (void)uploadImagesWithMutableAttachments:(NSMutableArray <LIFEReportAttachmentImpl *>*)mutableAttachments steps:(NSMutableString *)steps inGroup:(dispatch_group_t)group {
    NSMutableArray <NSString *>*imgUrls = [NSMutableArray arrayWithCapacity:mutableAttachments.count];
    [mutableAttachments enumerateObjectsUsingBlock:^(LIFEReportAttachmentImpl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 图片
        if ([obj isImageAttachment]) {
            dispatch_group_enter(group);
            [self uploadFileAttachmet:obj completion:^(NSString *fileUrl) {
                if (fileUrl) {
                    [mutableAttachments removeObject:obj];
                    CGFloat width = (int)(UIScreen.mainScreen.bounds.size.width * 0.3);
                    CGFloat height = (int)(UIScreen.mainScreen.bounds.size.height * 0.3);
                    NSString *imgUrlString = [NSString stringWithFormat:@"<p>截图，点击图片全屏查看<img src=\"%@\" data-ke-src=\"%@\" alt="" width=\"%d\" height=\"%d\"></p>",fileUrl, fileUrl, (int)width, (int)height];
                    [steps appendFormat:@"\n%@",imgUrlString];
                }
                dispatch_group_leave(group);
            }];
        }
    }];
}
- (void)append:(id<AFMultipartFormData>)formData logType:(MLSBugLogType)logType {
    NSString *path = [MLSBugLogger getLogZipFileWithType:(logType)];
    if (!path) {
        return;
    }
    NSURL *fileUrl = [NSURL fileURLWithPath:path];
    if (fileUrl) {
        NSError *error = nil;
        [formData appendPartWithFileURL:fileUrl name:@"files[]" error:&error];
        NSLog(@"%@",error);
    }
}

- (void)appendLogFiles:(id<AFMultipartFormData>)formData {
    if (MLSBugReporterOptions.shareOptions.combineAllLog) {
        [self append:formData logType:(MLSBugLogTypeCombineAll)];
    } else {
        // 增加网络日志
        if (MLSBugReporterOptions.shareOptions.trackingNetwork) {
            [self append:formData logType:(MLSBugLogTypeNetwork)];
        }
        
        // 增加用户追踪日志
        if (MLSBugReporterOptions.shareOptions.trackingUserSteps) {
            [self append:formData logType:(MLSBugLogTypeUserTrack)];
        }
        
        // 增加控制台日志
        if (MLSBugReporterOptions.shareOptions.trackingConsoleLog) {
            [self append:formData logType:(MLSBugLogTypeConsole)];
        }
        
        // 默认日志
        [self append:formData logType:(MLSBugLogTypeDefault)];
    }
}

- (void)removeAllLogsFile {
    if (MLSBugReporterOptions.shareOptions.combineAllLog) {
        [MLSBugLogger deleteLogZipFileWithType:MLSBugLogTypeCombineAll];
        [MLSBugLogger removeLogFileForType:(MLSBugLogTypeCombineAll)];
    } else {
        // 删除网络日志
        if (MLSBugReporterOptions.shareOptions.trackingNetwork) {
            [MLSBugLogger deleteLogZipFileWithType:MLSBugLogTypeNetwork];
            [MLSBugLogger removeLogFileForType:(MLSBugLogTypeNetwork)];
        }
        // 删除网络日志
        if (MLSBugReporterOptions.shareOptions.trackingUserSteps) {
            [MLSBugLogger deleteLogZipFileWithType:MLSBugLogTypeUserTrack];
            [MLSBugLogger removeLogFileForType:(MLSBugLogTypeUserTrack)];
        }
        // 删除网络日志
        if (MLSBugReporterOptions.shareOptions.trackingConsoleLog) {
            [MLSBugLogger deleteLogZipFileWithType:MLSBugLogTypeConsole];
            [MLSBugLogger removeLogFileForType:(MLSBugLogTypeConsole)];
        }
        [MLSBugLogger deleteLogZipFileWithType:MLSBugLogTypeDefault];
        [MLSBugLogger removeLogFileForType:(MLSBugLogTypeDefault)];
    }
}
- (void)_removeSavedReport:(LIFEReport *)report removeSuccessfulSubmissions:(BOOL)removeSuccessfulSubmissions {
    [self removeAllLogsFile];
    
    if (MLSBugReporterManager.sharedInstance.matrixIssue) {
        [[Matrix sharedInstance] reportIssueComplete:MLSBugReporterManager.sharedInstance.matrixIssue success:YES];
        MLSBugReporterManager.sharedInstance.matrixIssue = nil;
    }
    if (removeSuccessfulSubmissions) {
        [self _removeSavedReport:report];
    }
}

- (void)uploadFileAttachmet:(LIFEReportAttachmentImpl *)imageAttachmet completion:(void (^)(NSString *fileUrl))completion {
    // 上传图片
    MLSZenTaoUploadFileReq *req =  [MLSZenTaoUploadFileReq requestWithParam:nil];
    req.constructingBodyBlock = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageAttachmet.attachmentData name:@"imgFile" fileName:imageAttachmet.filename mimeType:imageAttachmet.uniformTypeIdentifier];
    };
    [req startWithSuccess:^(MLSZenTaoUploadFileReq * req, id data, NSError *error) {
        NSDictionary *responsObj = req.responseJSONObject;
        if ([responsObj isKindOfClass:NSDictionary.class]) {
            NSString *imgUrl = [responsObj objectForKey:@"url"];
            completion(imgUrl);
        }
    } failure:^(MLSZenTaoUploadFileReq * req, id data, NSError *error) {
        completion(nil);
    }];
}


- (void)logClientEventWithName:(nonnull NSString *)eventName
{
//    LIFELogIntDebug(@"Logging event: \"%@\"", eventName);
//
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//
//    [self.reportOwner switchCaseAPIKey:^(NSString *apiKey) {
//        [LIFENSMutableDictionaryify(params) life_safeSetObject:apiKey forKey:@"api_key"];
//    } email:^(NSString * _Nonnull email) {
//        [LIFENSMutableDictionaryify(params) life_safeSetObject:email forKey:@"email"];
//    }];
//
//    NSString *deviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
//    NSString *userIdentifier = [Buglife sharedBuglife].userIdentifier;
//    NSString *userEmail = [Buglife sharedBuglife].userEmail;
//    NSMutableDictionary *clientEventParams = [NSMutableDictionary dictionary];
//    [clientEventParams life_safeSetObject:self.sdkVersion forKey:@"sdk_version"];
//    [clientEventParams life_safeSetObject:self.sdkName forKey:@"sdk_name"];
//    [clientEventParams life_safeSetObject:eventName forKey:@"event_name"];
//    [clientEventParams life_safeSetObject:userIdentifier forKey:@"user_identifier"];
//    [clientEventParams life_safeSetObject:userEmail forKey:@"user_email"];
//    [clientEventParams life_safeSetObject:deviceIdentifier forKey:@"device_identifier"];
//
//    [self.appInfoProvider asyncFetchAppInfoToQueue:self.workQueue completion:^(LIFEAppInfo *appInfo) {
//        clientEventParams[@"bundle_short_version"] = appInfo.bundleShortVersion;
//        clientEventParams[@"bundle_version"] = appInfo.bundleVersion;
//
//        NSMutableDictionary *appParams = [NSMutableDictionary dictionary];
//        [appParams life_safeSetObject:appInfo.bundleIdentifier forKey:@"bundle_identifier"];
//        [appParams life_safeSetObject:@"ios" forKey:@"platform"];
//        [appParams life_safeSetObject:appInfo.bundleName forKey:@"bundle_name"];
//
//        [params life_safeSetObject:appParams forKey:@"app"];
//        [params life_safeSetObject:clientEventParams forKey:@"client_event"];
//
//        [self.networkManager POST:@"" parameters:params callbackQueue:self.workQueue success:^(id responseObject) {
//            LIFELogIntDebug(@"Successfully posted event \"%@\"", eventName);
//        } failure:^(NSError *error) {
//            LIFELogIntError(@"Error posting event \"%@\"\n  Error: %@", eventName, error);
//        }];
//    }];
}
@end
