//
//  MLSBugReporterManager.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/11.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSBugReporterManager.h"
#import "Buglife.h"
#import "LIFEDataProvider.h"
#import "LIFEReportOwner.h"
#import "Buglife+Protected.h"
#import "MLSZentaoDataProvider.h"
#import "MLSZenTaoBugFiled.h"
#import "MLSBugReporterOptions.h"
#import "Matrix.h"
#import "MLSZentaoPingReq.h"
#import "MLSBugReporterLoginViewController.h"
#import "MLSBugReportCreateBugReq.h"
#import <objc/runtime.h>
#import "LIFESwizzler.h"
#import "MLSBugReporterManager+Private.h"
#import "MLSUserStepTracker.h"
#import "MLSBuglifeManager.h"
#import "MLSBugLogger.h"
#import "MLSCrashTracker.h"
#import "MLSNetworkTracker.h"
#import "MLSBugConsoleTracker.h"
@interface MLSBugReporterManager ()<BuglifeDelegate>
@property (nonatomic, strong) NSTimer *pingTimer;
@property (nonatomic, strong) MatrixIssue *matrixIssue;
@end
@implementation MLSBugReporterManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MLSBugReporterManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[MLSBugReporterManager alloc] init];
        // 5 分钟ping 下session，保活
        instance.pingTimer = [NSTimer scheduledTimerWithTimeInterval:5 * 60 target:instance selector:@selector(pingSession) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:instance.pingTimer forMode:NSRunLoopCommonModes];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    });
    return instance;
}
+ (void)applicationWillTerminate {
    [[MLSBugReporterOptions shareOptions] saveLocal];
}
+ (void)applicationDidEnterBackground {
    [[MLSBugReporterOptions shareOptions] saveLocal];
}
+ (void)startWithInvocationEvent:(MLSInvocationEvent)invocationEvent {
    [self startWithInvocationEvent:invocationEvent options:MLSBugReporterOptions.shareOptions];
}

+ (void)startWithInvocationEvent:(MLSInvocationEvent)invocationEvent options:(MLSBugReporterOptions *)options {
    NSAssert(options.zentaoProductName, @"请先配置禅道项目名称");
    [self setTrackingCrashes:options.trackingCrashes];
    
#if TARGET_OS_SIMULATOR
    NSLog(@"日志存放路径：%@", [MLSBugLogger getLogRootPath]);
#endif
    [MLSBuglifeManager installWithOptions:invocationEvent];

    [self setTrackingUserSteps:options.trackingUserSteps];
    [self setTrackingNetwork:options.trackingNetwork];
    [self setTrackingConsoleLog:options.trackingConsoleLog];
    
    [options saveLocal];
    if (options.autoPresentLogin) {
        [MLSBugReporterLoginViewController showIfNeed];        
    }

}

+ (void)log:(NSString *)content {
    MLSBugLogDefault(content);
}

+ (void)setTrackingUserSteps:(BOOL)trackingUserSteps {
    MLSBugReporterOptions.shareOptions.trackingUserSteps = trackingUserSteps;
    trackingUserSteps ? [MLSUserStepTracker install] : [MLSUserStepTracker unInstall];
}

+ (void)setTrackingCrashes:(BOOL)trackingCrashes {
    MLSBugReporterOptions.shareOptions.trackingCrashes = trackingCrashes;
    trackingCrashes ? [MLSCrashTracker install] : [MLSCrashTracker unInstall];
}

+ (void)setGetWifiName:(BOOL)getWifiName {
    MLSBugReporterOptions.shareOptions.getWifiName = getWifiName;
}

+ (void)setTrackingConsoleLog:(BOOL)trackingConsoleLog {
    MLSBugReporterOptions.shareOptions.trackingConsoleLog = trackingConsoleLog;
    trackingConsoleLog ? [MLSBugConsoleTracker install] : [MLSBugConsoleTracker unInstall];
}

+ (void)setTrackingNetwork:(BOOL)trackingNetwork {
    MLSBugReporterOptions.shareOptions.trackingNetwork = trackingNetwork;
    trackingNetwork ? [MLSNetworkTracker install] : [MLSNetworkTracker uninstall];
}
+ (void)setTrackingNetworkURLFilter:(NSString *)trackingNetworkURLFilter {
    MLSBugReporterOptions.shareOptions.trackingNetworkURLFilter = trackingNetworkURLFilter;
    [MLSNetworkTracker setTrackingNetworkURLFilter:trackingNetworkURLFilter];
}
+ (void)setUnTrackingNetworkURLFilter:(NSString *)unTrackingNetworkURLFilter {
    MLSBugReporterOptions.shareOptions.unTrackingNetworkURLFilter = unTrackingNetworkURLFilter;
    [MLSNetworkTracker setUnTrackingNetworkURLFilter:unTrackingNetworkURLFilter];
}
+ (void)setNetworkResponseMaxLength:(NSUInteger)maxLength {
    MLSBugReporterOptions.shareOptions.ressponseMaxLength = maxLength;
    [MLSNetworkTracker setResponseMaxLength:maxLength];
}
+ (void)setCrashlogFmt:(MLSCrashLogFormat)fmt {
    MLSBugReporterOptions.shareOptions.crashlogFmt = fmt;
}
+ (void)setCombineAllLog:(BOOL)combineAllLog {
    MLSBugReporterOptions.shareOptions.combineAllLog = combineAllLog;
}
+ (void)setUserData:(NSString *)data forKey:(NSString *)key {
    [Buglife.sharedBuglife setStringValue:data forAttribute:key];
}

+ (void)removeUserDataForKey:(NSString *)key {
    [Buglife.sharedBuglife setStringValue:nil forAttribute:key];
}

+ (void)removeAllUserData {
    [Buglife.sharedBuglife removeAllAttributes];
}

+ (void)sendException:(NSException *)exception {
    // not imp
}

+ (void)setZenTaoBaseUrl:(NSString *)zentaoBaseUrl {
    MLSBugReporterOptions.shareOptions.zentaoBaseUrl = zentaoBaseUrl;
}
+ (void)setZenTaoIndexUrl:(NSString *)zentaoIndexUrl {
    MLSBugReporterOptions.shareOptions.zentaoIndexUrl = zentaoIndexUrl;
}
+ (void)setZenTaoProductName:(NSString *)productName {
    MLSBugReporterOptions.shareOptions.zentaoProductName = productName;
}

// MARK: - SESSSION
- (void)pingSession {
    // 已经登录过，重新刷新session即可
    [[MLSZentaoPingReq requestWithParam:nil] startWithSuccess:^(id<MLSRetryPreRequestProtocol> req, id data, NSError *error) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([str containsString:@"refresh"]) {
        } else {
            MLSBugReporterOptions.shareOptions.configModel = nil;
            [MLSBugReporterLoginViewController showIfNeed];
        }
    } failure:^(id<MLSRetryPreRequestProtocol> req, id data, NSError *error) {
    }];
}

@end


