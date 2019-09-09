//
//  MLSBugReporterOptions.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/24.
//

#import <Foundation/Foundation.h>
#import "MLSBugReporterManager.h"
#import "MLSBugReporterManager+Private.h"
#import "MLSZentaoConfigModel.h"
#import "MLSZenTaoBugModel.h"
#import "MLSBugReporterOptions.h"
const LIFEInvocationOptions LIFEInvocationOptionsCrashReport = 1 << 7;

@implementation MLSBugReporterOptions
+ (instancetype)defaultOptions {
    return [self shareOptions];
}
+ (instancetype)shareOptions {
    static dispatch_once_t onceToken;
    static MLSBugReporterOptions *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [MLSBugReporterOptions loadFromLocal];
    });
    return instance;
}
- (NSUInteger)stepLogCapacity {
    return [[self.extraOptions objectForKey:MLSUserStepLogCapacityKey] unsignedIntegerValue];
}
- (NSUInteger)consoleLogCapacity {
    return [[self.extraOptions objectForKey:MLSConsoleLogCapacityKey] unsignedIntegerValue];
}
- (NSUInteger)logCapacity {
    return [[self.extraOptions objectForKey:MLSLogCapacityKey] unsignedIntegerValue];
}
- (NSUInteger)networkLogCapacity {
    return [[self.extraOptions objectForKey:MLSNetworkLogCapacityKey] unsignedIntegerValue];
}
- (BOOL)customCrashWithScreenshot {
    return [[self.extraOptions objectForKey:MLSCustomCrashWithScreenshotKey] boolValue];
}
- (BOOL)crashlogAllThreads {
    return [[self.extraOptions objectForKey:MLSCrashLogAllThreadsKey] boolValue];
}
+ (instancetype)_defaultOptions {
    MLSBugReporterOptions *options = [[MLSBugReporterOptions alloc] init];
    options.trackingCrashes = YES;
    options.trackingUserSteps = YES;
    options.trackingConsoleLog = YES;
    options.trackingNetwork = YES;
    options.trackingNetworkURLFilter = @"";
    options.zentaoProductID = @"0";
    options.zentaoModuleID = @"0";
    options.zentaoProjectID = @"0";
    options.zentaoOpenedBuild = @"trunk";
    options.zentaoAsignUserID = @"0";
    options.zentaoBugTypeID = @"codeerror";
    options.zentaoBugPriID = @"3";
    options.zentaoSeverityID = @"3";
    options.combineAllLog = YES;
    options.ressponseMaxLength = 1024;
    options.crashlogFmt = MLSCrashLogFormatJson;
    options.version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    options.build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    options.zentaoBaseUrl = @"http://39.107.123.15:9091";
    options.zentaoIndexUrl = @"/index.php";
    options.extraOptions = @{
                             MLSUserStepLogCapacityKey : @(500),
                             MLSConsoleLogCapacityKey : @(500),
                             MLSLogCapacityKey : @(500),
                             MLSNetworkLogCapacityKey : @(20),
                             MLSCustomCrashWithScreenshotKey : @(NO),
                             MLSCrashLogAllThreadsKey : @(NO)
                             };
    return options;
}

+ (MLSBugReporterOptions *)loadFromLocal {
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    filePath = [filePath stringByAppendingPathComponent:@".options.data"];
    if ([NSFileManager.defaultManager fileExistsAtPath:filePath]) {
        MLSBugReporterOptions *options = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        return options;
    }
    return [MLSBugReporterOptions _defaultOptions];
}
- (void)saveLocal {
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    filePath = [filePath stringByAppendingPathComponent:@".options.data"];
    if ([NSFileManager.defaultManager fileExistsAtPath:filePath]) {
        [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
    }
    [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
}
- (void)setConfigModel:(MLSZentaoConfigModel *)configModel {
    _configModel = configModel;
    [self saveLocal];
}
- (NSString *)zentaoBaseUrl {
    if (!_zentaoBaseUrl) {
        _zentaoBaseUrl = @"http://39.107.123.15:9091";
    }
    return _zentaoBaseUrl;
}
- (NSString *)zentaoIndexUrl {
    if (!_zentaoIndexUrl) {
        _zentaoIndexUrl = @"/index.php";
    }
    return _zentaoIndexUrl;
}
- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeBool:self.trackingCrashes forKey:@"trackingCrashes"];
    [aCoder encodeBool:self.trackingUserSteps forKey:@"trackingUserSteps"];
    [aCoder encodeBool:self.trackingConsoleLog forKey:@"trackingConsoleLog"];
    [aCoder encodeBool:self.trackingNetwork forKey:@"trackingNetwork"];
    [aCoder encodeBool:self.combineAllLog forKey:@"combineAllLog"];
    [aCoder encodeInt64:self.ressponseMaxLength forKey:@"ressponseMaxLength"];
    [aCoder encodeInteger:self.crashlogFmt forKey:@"crashlogFmt"];
    [aCoder encodeObject:self.trackingNetworkURLFilter forKey:@"trackingNetworkURLFilter"];
    [aCoder encodeObject:self.version forKey:@"version"];
    [aCoder encodeObject:self.build forKey:@"build"];
    [aCoder encodeObject:self.extraOptions forKey:@"extraOptions"];
    [aCoder encodeObject:self.configModel forKey:@"configModel"];
    [aCoder encodeObject:self.zentaoProductID forKey:@"zentaoProductID"];
    [aCoder encodeObject:self.zentaoModuleID forKey:@"zentaoModuleID"];
    [aCoder encodeObject:self.zentaoProjectID forKey:@"zentaoProjectID"];
    [aCoder encodeObject:self.zentaoOpenedBuild forKey:@"zentaoOpenedBuild"];
    [aCoder encodeObject:self.zentaoAsignUserID forKey:@"zentaoAsignUserID"];
    [aCoder encodeObject:self.zentaoBugTypeID forKey:@"zentaoBugTypeID"];
    // 每次归档，默认都是 3
    [aCoder encodeObject:@"3" forKey:@"zentaoBugPriID"];
    [aCoder encodeObject:@"3" forKey:@"zentaoSeverityID"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    MLSBugReporterOptions *options = [[MLSBugReporterOptions alloc] init];
    options.trackingCrashes = [aDecoder decodeBoolForKey:@"trackingCrashes"];
    options.trackingUserSteps = [aDecoder decodeBoolForKey:@"trackingUserSteps"];
    options.trackingConsoleLog = [aDecoder decodeBoolForKey:@"trackingConsoleLog"];
    options.trackingNetwork = [aDecoder decodeBoolForKey:@"trackingNetwork"];
    options.combineAllLog = [aDecoder decodeBoolForKey:@"combineAllLog"];
    options.ressponseMaxLength = [aDecoder decodeInt64ForKey:@"ressponseMaxLength"];
    options.trackingNetworkURLFilter = [aDecoder decodeObjectForKey:@"trackingNetworkURLFilter"];
    options.crashlogFmt = [aDecoder decodeIntegerForKey:@"crashlogFmt"];
    options.version = [aDecoder decodeObjectForKey:@"version"];
    options.build = [aDecoder decodeObjectForKey:@"build"];
    options.extraOptions = [aDecoder decodeObjectForKey:@"extraOptions"];
    options.configModel = [aDecoder decodeObjectForKey:@"configModel"];
    options.zentaoProductID = [aDecoder decodeObjectForKey:@"zentaoProductID"]?:@"0";
    options.zentaoModuleID = [aDecoder decodeObjectForKey:@"zentaoModuleID"]?:@"0";
    options.zentaoProjectID = [aDecoder decodeObjectForKey:@"zentaoProjectID"]?:@"0";
    options.zentaoOpenedBuild = [aDecoder decodeObjectForKey:@"zentaoOpenedBuild"]?:@"trunk";
    options.zentaoAsignUserID = [aDecoder decodeObjectForKey:@"zentaoAsignUserID"]?:@"0";
    options.zentaoBugTypeID = [aDecoder decodeObjectForKey:@"zentaoBugTypeID"]?:@"codeerror";
    options.zentaoBugPriID = [aDecoder decodeObjectForKey:@"zentaoBugPriID"]?:@"3";
    options.zentaoSeverityID = [aDecoder decodeObjectForKey:@"zentaoSeverityID"]?:@"3";
    
    return options;
}

@end
NSString *const MLSUserStepLogCapacityKey = @"MLSUserStepLogCapacityKey";
NSString *const MLSConsoleLogCapacityKey = @"MLSConsoleLogCapacityKey";
NSString *const MLSLogCapacityKey = @"MLSLogCapacityKey";
NSString *const MLSNetworkLogCapacityKey = @"MLSNetworkLogCapacityKey";
NSString *const MLSCustomCrashWithScreenshotKey = @"MLSCustomCrashWithScreenshotKey";      // 手动提交的异常是否截图   默认 NO
NSString *const MLSNetworkActivityIndicatorHiddenKey = @"MLSNetworkActivityIndicatorHiddenKey"; // 是否隐藏网络请求状态     默认 NO
NSString *const MLSCrashLogAllThreadsKey = @"MLSCrashLogAllThreadsKey";
