//
//  MLSBuglifeManager.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/24.
//

#import "MLSBuglifeManager.h"
#import <MLSUICore/MLSUICore.h>
#import "MLSBugReporterOptions.h"
#import "MLSBugReporterLoginViewController.h"
#import "MLSBugReporterManager+Private.h"
#import "MLSZenTaoBugFiled.h"
@interface MLSBuglifeManager () <BuglifeDelegate>
@end
@implementation MLSBuglifeManager
+ (instancetype)sharedInstance {
    static dispatch_once_t lifemanagerOnce;
    static MLSBuglifeManager *instance = nil;
    dispatch_once(&lifemanagerOnce,^{
        instance = [[super alloc] init];
    });
    return instance;
}

+ (void)installWithOptions:(LIFEInvocationOptions)options {
    [[self sharedInstance] installWithOptions:options];
}
- (void)installWithOptions:(LIFEInvocationOptions)options {
    [Buglife.sharedBuglife startWithEmail:@""];
    Buglife.sharedBuglife.delegate = self;
    Buglife.sharedBuglife.invocationOptions = options;
    Buglife.sharedBuglife.retryPolicy = LIFERetryPolicyManualRetry;
    
    NSMutableArray <LIFEInputField *>*inputFields = [NSMutableArray array];
    // 标题
    [inputFields addObject:[[MLSZenTaoBugFiled alloc] initWithType:(MLSZenTaoBugFiledTypeBugTitle)]];
    // 重现步骤
    [inputFields addObject:[[MLSZenTaoBugFiled alloc] initWithType:(MLSZenTaoBugFiledTypeBugSteps)]];
    // 产品
    [inputFields addObject:[[MLSZenTaoBugFiled alloc] initWithType:(MLSZenTaoBugFiledTypeProduct)]];
    // 模块
    [inputFields addObject:[[MLSZenTaoBugFiled alloc] initWithType:(MLSZenTaoBugFiledTypeModule)]];
    // 项目
    [inputFields addObject:[[MLSZenTaoBugFiled alloc] initWithType:(MLSZenTaoBugFiledTypeProject)]];
    // 影响版本
    [inputFields addObject:[[MLSZenTaoBugFiled alloc] initWithType:(MLSZenTaoBugFiledTypeBuild)]];
    // 指派给
    [inputFields addObject:[[MLSZenTaoBugFiled alloc] initWithType:(MLSZenTaoBugFiledTypeAsignTo)]];
    // bug类型
    [inputFields addObject:[[MLSZenTaoBugFiled alloc] initWithType:(MLSZenTaoBugFiledTypeBugType)]];
    // bug 严重程度
    [inputFields addObject:[[MLSZenTaoBugFiled alloc] initWithType:(MLSZenTaoBugFiledTypeBugLevel)]];
    // bug 优先级
    [inputFields addObject:[[MLSZenTaoBugFiled alloc] initWithType:(MLSZenTaoBugFiledTypeBugPriority)]];
    
    
    Buglife.sharedBuglife.inputFields = inputFields;
}
// 回调 微信监控系统 matrix
- (void)reportCrashToMatrix:(BOOL)success {
    if (MLSBugReporterManager.sharedInstance.matrixIssue) {
        [[Matrix sharedInstance] reportIssueComplete:MLSBugReporterManager.sharedInstance.matrixIssue success:success];
        MLSBugReporterManager.sharedInstance.matrixIssue = nil;
    }
}

/// MARK: - BugLife Delegate


- (void)buglife:(nonnull Buglife *)buglife handleAttachmentRequestWithCompletionHandler:(nonnull void (^)(void))completionHandler {
    completionHandler();
}

- (nullable NSString *)buglife:(nonnull Buglife *)buglife titleForPromptWithInvocation:(LIFEInvocationOptions)invocation {
    if (invocation == LIFEInvocationOptionsCrashReport) {
        return @"检测到应用上次崩溃信息";
    }
    return @"提交至禅道";
}

- (void)buglifeDidCompleteReportWithAttributes:(nonnull NSDictionary<NSString *, NSString *> *)attributes {
    [MLSTipClass hideLoading];
    [MLSTipClass hideLoadingInView:nil];
    // 由网络情况决定是否上报成功 See MLSZentaoDataProvider
//    [self reportCrashToMatrix:YES];
}

- (BOOL)buglifeWillPresentReportCompletedDialog:(nonnull Buglife *)buglife {
    [MLSTipClass hideLoading];
    [MLSTipClass hideLoadingInView:nil];
    return YES;
}

- (void)buglife:(nonnull Buglife *)buglife userCanceledReportWithAttributes:(nonnull NSDictionary<NSString *, NSString *> *)attributes {
    [MLSTipClass hideLoading];
    [MLSTipClass hideLoadingInView:nil];
    // 用户取消上报，直接把本地清楚
    [self reportCrashToMatrix:YES];
}

- (void)buglife:(Buglife *)buglife shouldHandleInvocation:(LIFEInvocationOptions)invocation completion:(void (^)(BOOL))completion {
    if (MLSBugReporterOptions.shareOptions.configModel.sessionID.length <= 0) {
        completion(NO);
        [MLSBugReporterLoginViewController showIfNeed];
        return;
    }
    [MLSTipClass showLoading];
    [MLSBugReporterLoginViewController getBugProductID:^(BOOL success, NSError *error) {
        [MLSTipClass hideLoading];
        completion(success);
        if (!success) {
            [MLSBugReporterLoginViewController showIfNeed];
            [MLSTipClass showErrorWithText:error.localizedDescription inView:nil];
        }
    }];
}
@end
