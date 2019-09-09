//
//  MLSFLEXNetworkRecorder.h
//  Flipboard
//
//  Created by Ryan Olson on 2/4/15.
//  Copyright (c) 2015 Flipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

// Notifications posted when the record is updated
extern NSString *const kMLSFLEXNetworkRecorderNewTransactionNotification;
extern NSString *const kMLSFLEXNetworkRecorderTransactionUpdatedNotification;
extern NSString *const kMLSFLEXNetworkRecorderUserInfoTransactionKey;
extern NSString *const kMLSFLEXNetworkRecorderTransactionsClearedNotification;

@class MLSFLEXNetworkTransaction;

@interface MLSFLEXNetworkRecorder : NSObject

/// In general, it only makes sense to have one recorder for the entire application.
+ (instancetype)defaultRecorder;
+ (void)setEnabled:(BOOL)enabled;
+ (BOOL)isEnabled;
/// Defaults to 25 MB if never set. Values set here are presisted across launches of the app.
@property (nonatomic, assign) NSUInteger responseCacheByteLimit;

/// If NO, the recorder not cache will not cache response for content types with an "image", "video", or "audio" prefix.
@property (nonatomic, assign) BOOL shouldCacheMediaResponses;

// use unTrackingNetworkURLFilter instead
@property (nonatomic, copy) NSArray<NSString *> *hostBlacklist;
// 日志文件
// 需要先调用 - writeLocalFile 写入本地
@property (nonatomic, copy, readonly) NSString *localLogFile;

/**
 配置跟踪的网络请求url
 支持正则表达式
 多个 domain 用 | 分开
 默认支持所有
 */
@property (nonatomic, copy) NSString *trackingNetworkURLFilter;

/**
 配置忽略跟踪的网络请求url
 支持正则表达式
 多个 domain 用 | 分开
 */
@property (nonatomic, copy) NSString *unTrackingNetworkURLFilter;
// 允许最大追踪多少个网络请求
// 默认 200 个
@property (nonatomic, assign) NSUInteger maxTrackCount;
// 网络返回最大长度
// 默认 1024
@property (nonatomic, assign) NSUInteger responseMaxLength;
// Accessing recorded network activity

/// Array of MLSFLEXNetworkTransaction objects ordered by start time with the newest first.
- (NSArray<MLSFLEXNetworkTransaction *> *)networkTransactions;

/// The full response data IFF it hasn't been purged due to memory pressure.
- (NSData *)cachedResponseBodyForTransaction:(MLSFLEXNetworkTransaction *)transaction;

// 日志写入本地
- (void)writeLocalFile;

/**
 // 获取本地日志

 @param async 是否异步
 @param completion 回调，异步回调
 */
- (void)getLocalFileAsync:(BOOL)async completion:(void (^)(NSString *logFile))completion;

/// Dumps all network transactions and cached response bodies.
- (void)clearRecordedActivity;


// Recording network activity

/// Call when app is about to send HTTP request.
- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID request:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;

/// Call when HTTP response is available.
- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response;

/// Call when data chunk is received over the network.
- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength;

/// Call when HTTP request has finished loading.
- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData *)responseBody;

/// Call when HTTP request has failed to load.
- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error;

/// Call to set the request mechanism anytime after recordRequestWillBeSent... has been called.
/// This string can be set to anything useful about the API used to make the request.
- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID;

@end
