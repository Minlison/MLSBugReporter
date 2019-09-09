//
//  MLSBugReporterOptions.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSBugReporterManager.h"
#import "MLSZentaoConfigModel.h"
#import "MLSZenTaoBugModel.h"
NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXTERN NSString *const MLSUserStepLogCapacityKey;
FOUNDATION_EXTERN NSString *const MLSConsoleLogCapacityKey;
FOUNDATION_EXTERN NSString *const MLSLogCapacityKey;
FOUNDATION_EXTERN NSString *const MLSNetworkLogCapacityKey;
FOUNDATION_EXTERN NSString *const MLSCustomCrashWithScreenshotKey;      // 手动提交的异常是否截图   默认 NO
FOUNDATION_EXTERN NSString *const MLSCrashLogAllThreadsKey;

@interface MLSBugReporterOptions ()
+ (instancetype)shareOptions;
@property (nonatomic, strong) MLSZentaoConfigModel *configModel;
@property (nonatomic, strong) MLSZenTaoBugModel *bugModel;
@property (nonatomic, copy) NSString *zentaoModuleID;
@property (nonatomic, copy) NSString *zentaoProductID;
@property (nonatomic, copy) NSString *zentaoProjectID;
@property (nonatomic, copy) NSString *zentaoOpenedBuild;
@property (nonatomic, copy) NSString *zentaoAsignUserID;
@property (nonatomic, copy) NSString *zentaoBugTypeID;
@property (nonatomic, copy) NSString *zentaoBugPriID;
@property (nonatomic, copy) NSString *zentaoSeverityID;


/**
 * 设置其它的启动项
 * 目前支持的可设置项如下：
 * 因为是使用DDLog，所以配置本地日志文件大小
 * MLSUserStepLogCapacityKey NSNumber 设置收集最近的用户操作步骤数量，默认 500 项
 * MLSConsoleLogCapacityKey  NSNumber 设置收集最近的控制台日志数量，默认 500 项
 * MLSLogCapacityKey  NSNumber 设置收集最近的  自定义日志数量，默认 500 项
 * MLSNetworkLogCapacityKey  NSNumber 设置记录最近的网络请求数量，默认 20 项
 */
@property(nonatomic, copy) NSDictionary *extraOptions;
- (NSUInteger)stepLogCapacity;
- (NSUInteger)consoleLogCapacity;
- (NSUInteger)logCapacity;
- (NSUInteger)networkLogCapacity;
- (BOOL)customCrashWithScreenshot;
- (BOOL)crashlogAllThreads;
- (void)saveLocal;
@end

NS_ASSUME_NONNULL_END
