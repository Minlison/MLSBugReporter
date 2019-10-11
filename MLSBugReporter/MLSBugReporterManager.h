//
//  MLSBugReporterManager.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/11.
//  Copyright © 2019 minlison. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  呼出方式
 *  所有方式都会自动收集 Crash 信息（如果允许）
 */
typedef NS_OPTIONS(NSUInteger, MLSInvocationEvent) {
    
    // 静默模式，只收集 Crash 信息（如果允许）
    MLSInvocationEventNone = 0,
    
    // 通过摇一摇呼出
    MLSInvocationEventShake = 1 << 0,
    
    // 截屏后自动弹出
    MLSInvocationEventScreenshot = 1 << 1,
    
    // 通过悬浮小球呼出
    MLSInvocationEventFloatingButton = 1 << 2,
    
};

/**
 崩溃日志格式

 - MLSCrashLogFormatJson: Json 格式
 - MLSCrashLogFormatAppleFmt: Apple 崩溃日志格式化
 */
typedef NS_ENUM(NSInteger, MLSCrashLogFormat) {
    MLSCrashLogFormatJson,
    MLSCrashLogFormatAppleFmt,
};


@interface MLSBugReporterOptions : NSObject <NSCopying, NSCoding>

/**
 默认选项

 @return options
 */
+ (instancetype)defaultOptions;

/**
 * 是否跟踪闪退，联机 Debug 状态下默认 NO，其它情况默认 YES
 */
@property(nonatomic, assign) BOOL trackingCrashes;

/// 是否手机WIFI 名称
/// @param getWifiName 是否搜集Wifi名称
/// 注意: 开启此选项需要配置 Wireless Accessory Configuration 权限
/// 默认: NO
@property(nonatomic, assign) BOOL getWifiName;

/**
 * 是否跟踪用户操作步骤，默认 YES
 * 跟踪 UIControl 的点击事件， UIViewController 的跳转
 */
@property(nonatomic, assign) BOOL trackingUserSteps;

/**
 * 是否收集控制台日志，默认 YES
 */
@property(nonatomic, assign) BOOL trackingConsoleLog;

/**
 是否合并所有日志
 会合并 UserStepsLog， ConsoleLog，DefaultLog， NetworkLog
 Default YES
 */
@property (nonatomic, assign) BOOL combineAllLog;


/**
 * 是否跟踪网络请求，只跟踪 HTTP / HTTPS 请求，默认 NO
 * 强烈建议同时设置 trackingNetworkURLFilter 对需要跟踪的网络请求进行过滤
 */
@property(nonatomic, assign) BOOL trackingNetwork;

/**
 崩溃日志格式化方式
 */
@property (nonatomic, assign) MLSCrashLogFormat crashlogFmt;

/**
 网络返回数据最大长度 string.length
 */
@property (nonatomic, assign) NSUInteger ressponseMaxLength;

/**
 * 设置需要跟踪的网络请求 URL，多个地址用 | 隔开，支持正则表达式，不设置则跟踪所有请求
 * 强烈建议设置为应用服务器接口的域名，如果接口是通过 IP 地址访问，则设置为 IP 地址
 * 如：设置为 .com，则网络请求跟踪只对 URL 中包含 .com 的请求有效
 */
@property(nonatomic, copy) NSString *trackingNetworkURLFilter;
@property(nonatomic, copy) NSString *unTrackingNetworkURLFilter;

/**
 * 设置应用版本号，默认自动获取应用的版本号
 */
@property(nonatomic, copy) NSString *version;

/**
 * 设置应用 build，默认自动获取应用的 build
 */
@property(nonatomic, copy) NSString *build;

/**
 禅道域名
 IP or host
 默认： http://39.107.123.15:9091
 */
@property (nonatomic, copy) NSString *zentaoBaseUrl;

/**
 首次启动App，如果登录失效，自动弹出登录框
 默认NO
 */
@property (nonatomic, assign) BOOL autoPresentLogin;

/**
 index.php 路径
 默认： /index.php
 Demo: /index.php or /zentaopms98/www/index.php
 */
@property (nonatomic, copy) NSString *zentaoIndexUrl;

/**
 禅道产品名
 */
@property (nonatomic, copy) NSString *zentaoProductName;
@end


@interface MLSBugReporterManager : NSObject

/**
 开启
 */
+ (void)startWithInvocationEvent:(MLSInvocationEvent)invocationEvent;
+ (void)startWithInvocationEvent:(MLSInvocationEvent)invocationEvent options:(MLSBugReporterOptions *)options;


// 自定义日志打印
+ (void)log:(NSString *)content;

/**
 * 设置是否收集 Crash 信息
 * @param trackingCrashes - 默认 YES
 */
+ (void)setTrackingCrashes:(BOOL)trackingCrashes;

/// 是否手机WIFI 名称
/// @param getWifiName 是否搜集Wifi名称
/// 注意: 开启此选项需要配置 Wireless Accessory Configuration 权限
/// 默认: NO
+ (void)setGetWifiName:(BOOL)getWifiName;

/**
 * 设置是否跟踪用户操作步骤
 * 如果集成了 友盟，在友盟配置后，再设置为YES
 * @param trackingUserSteps - 默认 NO
 */
+ (void)setTrackingUserSteps:(BOOL)trackingUserSteps;

/**
 * 设置是否收集控制台日志
 * @param trackingConsoleLog - 默认 YES
 */
+ (void)setTrackingConsoleLog:(BOOL)trackingConsoleLog;

/**
 * 设置是否跟踪网络请求，只跟踪 HTTP / HTTPS 请求
 * 强烈建议同时设置 trackingNetworkURLFilter 对需要跟踪的网络请求进行过滤
 * @param trackingNetwork - 默认 NO
 */
+ (void)setTrackingNetwork:(BOOL)trackingNetwork;

/**
 配置追踪网络的过滤器
 默认全部追踪
 @param trackingNetworkURLFilter 过滤器，多个使用 | 分开
 */
+ (void)setTrackingNetworkURLFilter:(NSString *)trackingNetworkURLFilter;
// 默认会忽略禅道的网络请求，如果想要追踪禅道的网络请求，配置 trackingNetworkURLFilter 即可
+ (void)setUnTrackingNetworkURLFilter:(NSString *)unTrackingNetworkURLFilter;

/**
 配置网络请求日志中，response 最大字符串长度

 @param maxLength 最大长度
 */
+ (void)setNetworkResponseMaxLength:(NSUInteger)maxLength;

/**
 设置崩溃日志格式

 @param fmt 格式
 */
+ (void)setCrashlogFmt:(MLSCrashLogFormat)fmt;

/**
 是否把所有日志都输出到一个文件内

 @param combineAllLog 是否合并日志文件
 */
+ (void)setCombineAllLog:(BOOL)combineAllLog;
/**
 * 设置自定义数据，会与问题一起提交
 * @param data - 用户数据
 * @param key - key
 */
+ (void)setUserData:(NSString *)data forKey:(NSString *)key;

/**
 * 移除指定 key 的自定义数据
 * @param key - key
 */
+ (void)removeUserDataForKey:(NSString *)key;

/**
 * 移除所有自定义数据
 */
+ (void)removeAllUserData;

/**
 配置禅道域名

 @param zentaoBaseUrl 禅道域名
 */
+ (void)setZenTaoBaseUrl:(NSString *)zentaoBaseUrl;

/**
 配置禅道index.php 路径

 @param zentaoIndexUrl index.php 路径
 */
+ (void)setZenTaoIndexUrl:(NSString *)zentaoIndexUrl;

/**
 配置禅道产品名

 @param productName 产品名
 */
+ (void)setZenTaoProductName:(NSString *)productName;
@end

NS_ASSUME_NONNULL_END
