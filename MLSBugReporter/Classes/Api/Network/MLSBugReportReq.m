//
//  MLSBugReportReq.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSBugReportReq.h"
#import "MLSBugRepotRootModel.h"
#import "MLSBugReportNetworkModelManager.h"
#import "MLSBugReporterOptions.h"
#import "MLSBugReporterLoginViewController.h"
#import <MLSNetwork/MLSNetwork-umbrella.h>
@interface MLSBugReportReq ()<MLSNetworkLogProtocol>
@end
@implementation MLSBugReportReq
- (NSString *)baseUrl {
    return MLSBugReporterOptions.shareOptions.zentaoBaseUrl;
}
- (NSString *)requestUrl {
    return MLSBugReporterOptions.shareOptions.zentaoIndexUrl;
}
- (NSDictionary *)requestQueryArgument {
    MLSZentaoConfigModel *configModel = MLSBugReporterOptions.shareOptions.configModel;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self otherQueryParams]];
    if (configModel) {
        [dict addEntriesFromDictionary:@{
                                         configModel.moduleVar : [self modlueName],
                                         configModel.methodVar : [self methodName],
                                         configModel.sessionVar :configModel ? configModel.sessionID : @"",
                                         configModel.viewVar : @"json"
                                         }];
    }
    return dict;
}
- (id)requestFullParams {
    if (self.requestMethod == MLSRequestMethodGET) {
        NSDictionary *requestDict = [super requestFullParams];
        if (!requestDict) {
            return [self requestQueryArgument];
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self requestQueryArgument]];
        [dict setValuesForKeysWithDictionary:requestDict];
        return dict;
    }
    NSMutableDictionary *parasm = [NSMutableDictionary dictionaryWithDictionary:[super requestFullParams]];
    [parasm removeObjectsForKeys:[self requestQueryArgument].allKeys];
    return parasm;
}
- (id<MLSNetworkModelProtocol>)modelManager {
    return (id)MLSBugReportNetworkModelManager.class;
}
- (Class<MLSNetworkRootDataProtocol>)serverRootDataClass {
    return (id)MLSBugRepotRootModel.class;
}
- (NSTimeInterval)requestTimeoutInterval {
    return 10;
}

- (NSString *)modlueName {
    return @"";
}
- (NSString *)methodName {
    return @"";
}
//- (NSTimeInterval)requestTimeoutInterval {
//    return 15;
//}
- (NSDictionary *)otherQueryParams {
    return @{};
}
- (BOOL)requestCompletePreprocessor {
    if ([self.responseString containsString:@"self.location"] && [self.responseString containsString:@"m=user"] && [self.responseString containsString:@"f=login"]) {
        MLSBugReporterOptions.shareOptions.configModel = nil;
        [MLSTipClass hideLoading];
        [MLSBugReporterLoginViewController showIfNeed];
        return NO;
    }
    return YES;
}
- (void)requestFailedFilter {
    if ([self.responseString containsString:@"self.location"] && [self.responseString containsString:@"m=user"] && [self.responseString containsString:@"f=login"]) {
        MLSBugReporterOptions.shareOptions.configModel = nil;
        [MLSTipClass hideLoading];
        [MLSBugReporterLoginViewController showIfNeed];
    }
}
- (id<MLSNetworkLogProtocol>)logger {
    return self.class;
}
#define MLSBugReportNetworkLoggerMarco \
va_list args;\
va_start(args, fmt);\
NSLogv(fmt, args);\
va_end(args);

+ (void)log:(MLSNetworkLogLevel)level msg:(NSString *)fmt, ... {
    MLSBugReportNetworkLoggerMarco
}
@end
