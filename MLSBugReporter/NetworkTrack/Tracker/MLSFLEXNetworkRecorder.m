//
//  MLSFLEXNetworkRecorder.m
//  Flipboard
//
//  Created by Ryan Olson on 2/4/15.
//  Copyright (c) 2015 Flipboard. All rights reserved.
//

#import "MLSFLEXNetworkRecorder.h"
#import "MLSFLEXNetworkTransaction.h"
#import "MLSFLEXUtility.h"
#import "MLSBugLogger.h"
#import "MLSFLEXNetworkObserver.h"
NSString *const kMLSFLEXNetworkRecorderNewTransactionNotification = @"kMLSFLEXNetworkRecorderNewTransactionNotification";
NSString *const kMLSFLEXNetworkRecorderTransactionUpdatedNotification = @"kMLSFLEXNetworkRecorderTransactionUpdatedNotification";
NSString *const kMLSFLEXNetworkRecorderUserInfoTransactionKey = @"transaction";
NSString *const kMLSFLEXNetworkRecorderTransactionsClearedNotification = @"kMLSFLEXNetworkRecorderTransactionsClearedNotification";

NSString *const kMLSFLEXNetworkRecorderResponseCacheLimitDefaultsKey = @"com.flex.responseCacheLimit";

@interface MLSFLEXNetworkRecorder ()

@property (nonatomic, strong) NSCache *responseCache;
@property (nonatomic, strong) NSMutableArray<MLSFLEXNetworkTransaction *> *orderedTransactions;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLSFLEXNetworkTransaction *> *networkTransactionsForRequestIdentifiers;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, copy, readwrite) NSString *localLogFile;
@end

@implementation MLSFLEXNetworkRecorder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.responseCache = [[NSCache alloc] init];
        NSUInteger responseCacheLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:kMLSFLEXNetworkRecorderResponseCacheLimitDefaultsKey] unsignedIntegerValue];
        if (responseCacheLimit) {
            [self.responseCache setTotalCostLimit:responseCacheLimit];
        } else {
            // Default to 25 MB max. The cache will purge earlier if there is memory pressure.
            [self.responseCache setTotalCostLimit:25 * 1024 * 1024];
        }
        self.orderedTransactions = [NSMutableArray array];
        self.networkTransactionsForRequestIdentifiers = [NSMutableDictionary dictionary];
        self.maxTrackCount = 200;
        self.shouldCacheMediaResponses = NO;
        self.responseMaxLength = 1024;
        // Serial queue used because we use mutable objects that are not thread safe
        self.queue = dispatch_queue_create("com.flex.MLSFLEXNetworkRecorder", DISPATCH_QUEUE_SERIAL);
        NSString *logFile = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
        logFile = [logFile stringByAppendingPathComponent:@".MLStracknetwork.log"];
        self.localLogFile = logFile;
    }
    return self;
}

+ (instancetype)defaultRecorder
{
    static MLSFLEXNetworkRecorder *defaultRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRecorder = [[[self class] alloc] init];
    });
    return defaultRecorder;
}
+ (void)setEnabled:(BOOL)enabled {
    [MLSFLEXNetworkObserver setEnabled:enabled];
}
+ (BOOL)isEnabled {
    return [MLSFLEXNetworkObserver isEnabled];
}
#pragma mark - Public Data Access

- (NSUInteger)responseCacheByteLimit
{
    return [self.responseCache totalCostLimit];
}

- (void)setResponseCacheByteLimit:(NSUInteger)responseCacheByteLimit
{
    [self.responseCache setTotalCostLimit:responseCacheByteLimit];
    [[NSUserDefaults standardUserDefaults] setObject:@(responseCacheByteLimit) forKey:kMLSFLEXNetworkRecorderResponseCacheLimitDefaultsKey];
}

- (NSArray<MLSFLEXNetworkTransaction *> *)networkTransactions
{
    __block NSArray<MLSFLEXNetworkTransaction *> *transactions = nil;
    dispatch_sync(self.queue, ^{
        transactions = [self.orderedTransactions copy];
    });
    return transactions;
}

- (NSData *)cachedResponseBodyForTransaction:(MLSFLEXNetworkTransaction *)transaction
{
    return [self.responseCache objectForKey:transaction.requestID];
}
- (void)writeLocalFile {
    NSArray<MLSFLEXNetworkTransaction *> *networkTransactions = [[MLSFLEXNetworkRecorder defaultRecorder] networkTransactions];
    if ([NSFileManager.defaultManager fileExistsAtPath:self.localLogFile]) {
        [NSFileManager.defaultManager removeItemAtPath:self.localLogFile error:nil];
    }
    [NSFileManager.defaultManager createFileAtPath:self.localLogFile contents:nil attributes:nil];
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:self.localLogFile append:YES];
    [outputStream open];
    for (MLSFLEXNetworkTransaction *trans in networkTransactions) {
        NSData *logData = trans.logData;
        [outputStream write:logData.bytes maxLength:logData.length];
    }
    [outputStream close];
}
- (void)getLocalFileAsync:(BOOL)async completion:(void (^)(NSString *logFile))completion {
    if (async) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self writeLocalFile];
            if (completion) {
                completion(self.localLogFile);
            }
        });
    } else {
        [self writeLocalFile];
        completion(self.localLogFile);
    }
}
- (void)clearRecordedActivity
{
    dispatch_async(self.queue, ^{
        [self.responseCache removeAllObjects];
        [self.orderedTransactions removeAllObjects];
        [self.networkTransactionsForRequestIdentifiers removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kMLSFLEXNetworkRecorderTransactionsClearedNotification object:self];
        });
    });
}

#pragma mark - Network Events
- (BOOL)canHandleRequest:(NSURLRequest *)request {
    if (request.URL == nil || request.URL.host == nil) {
        return NO;
    }
    NSString *trackFilter = [self trackingNetworkURLFilter];
    
    if (trackFilter.length > 0) {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:trackFilter options:0 error:&error];
        if (error) {
            return NO;
        }
        NSUInteger matchCount = [regex numberOfMatchesInString:request.URL.host options:0 range:NSMakeRange(0, request.URL.host.length)];
        return matchCount > 0;
    }
    
    NSString *unTrackFilter = [self unTrackingNetworkURLFilter];
    if (unTrackFilter.length > 0) {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:unTrackFilter options:0 error:&error];
        if (error) {
            return NO;
        }
        NSUInteger matchCount = [regex numberOfMatchesInString:request.URL.host options:0 range:NSMakeRange(0, request.URL.host.length)];
        return matchCount == 0;
    }
    return YES;
}
- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID request:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
//    for (NSString *host in self.hostBlacklist) {
//        if ([request.URL.host hasSuffix:host]) {
//            return;
//        }
//    }
    if (![self canHandleRequest:request]) {
        return;
    }
    
    NSDate *startDate = [NSDate date];

    if (redirectResponse) {
        [self recordResponseReceivedWithRequestID:requestID response:redirectResponse];
        [self recordLoadingFinishedWithRequestID:requestID responseBody:nil];
    }

    dispatch_async(self.queue, ^{
        MLSFLEXNetworkTransaction *transaction = [[MLSFLEXNetworkTransaction alloc] init];
        transaction.requestID = requestID;
        transaction.request = request;
        transaction.startTime = startDate;
        transaction.responseMaxLength = self.responseMaxLength;
        // 不能超出最大界限
        if (self.orderedTransactions.count > self.maxTrackCount) {
            MLSFLEXNetworkTransaction *lastTrans = self.orderedTransactions.lastObject;
            [self.networkTransactionsForRequestIdentifiers removeObjectForKey:lastTrans.requestID];
            [self.responseCache removeObjectForKey:lastTrans.requestID];
            [self.orderedTransactions removeObject:lastTrans];
        }
        [self.orderedTransactions insertObject:transaction atIndex:0];
        [self.networkTransactionsForRequestIdentifiers setObject:transaction forKey:requestID];
        transaction.transactionState = MLSFLEXNetworkTransactionStateAwaitingResponse;
//        MLSBugLogNetwork(@"%@ -- %@", [MLSFLEXNetworkTransaction readableStringFromTransactionState:transaction.transactionState],transaction.logString);
        [self postNewTransactionNotificationWithTransaction:transaction];
    });
}

- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response
{
    NSDate *responseDate = [NSDate date];

    dispatch_async(self.queue, ^{
        MLSFLEXNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.response = response;
        transaction.transactionState = MLSFLEXNetworkTransactionStateReceivingData;
        transaction.latency = -[transaction.startTime timeIntervalSinceDate:responseDate];
//        MLSBugLogNetwork(@"%@ -- %@", [MLSFLEXNetworkTransaction readableStringFromTransactionState:transaction.transactionState],transaction.logString);
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength
{
    dispatch_async(self.queue, ^{
        MLSFLEXNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.receivedDataLength += dataLength;
//        MLSBugLogNetwork(@"%@ -- %@", [MLSFLEXNetworkTransaction readableStringFromTransactionState:transaction.transactionState],transaction.logString);
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData *)responseBody
{
    NSDate *finishedDate = [NSDate date];

    dispatch_async(self.queue, ^{
        MLSFLEXNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.transactionState = MLSFLEXNetworkTransactionStateFinished;
        transaction.duration = -[transaction.startTime timeIntervalSinceDate:finishedDate];

        BOOL shouldCache = [responseBody length] > 0;
        if (!self.shouldCacheMediaResponses) {
            NSArray<NSString *> *ignoredMIMETypePrefixes = @[ @"audio", @"image", @"video" ];
            for (NSString *ignoredPrefix in ignoredMIMETypePrefixes) {
                shouldCache = shouldCache && ![transaction.response.MIMEType hasPrefix:ignoredPrefix];
            }
        }
        
        if (shouldCache) {
            [self.responseCache setObject:responseBody forKey:requestID cost:[responseBody length]];
        }

        NSString *mimeType = transaction.response.MIMEType;
//        if ([mimeType hasPrefix:@"image/"] && [responseBody length] > 0) {
//            // Thumbnail image previews on a separate background queue
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSInteger maxPixelDimension = [[UIScreen mainScreen] scale] * 32.0;
//                transaction.responseThumbnail = [MLSFLEXUtility thumbnailedImageWithMaxPixelDimension:maxPixelDimension fromImageData:responseBody];
//                [self postUpdateNotificationForTransaction:transaction];
//            });
//        } else if ([mimeType isEqual:@"application/json"]) {
//            transaction.responseThumbnail = [MLSFLEXResources jsonIcon];
//        } else if ([mimeType isEqual:@"text/plain"]){
//            transaction.responseThumbnail = [MLSFLEXResources textPlainIcon];
//        } else if ([mimeType isEqual:@"text/html"]) {
//            transaction.responseThumbnail = [MLSFLEXResources htmlIcon];
//        } else if ([mimeType isEqual:@"application/x-plist"]) {
//            transaction.responseThumbnail = [MLSFLEXResources plistIcon];
//        } else if ([mimeType isEqual:@"application/octet-stream"] || [mimeType isEqual:@"application/binary"]) {
//            transaction.responseThumbnail = [MLSFLEXResources binaryIcon];
//        } else if ([mimeType rangeOfString:@"javascript"].length > 0) {
//            transaction.responseThumbnail = [MLSFLEXResources jsIcon];
//        } else if ([mimeType rangeOfString:@"xml"].length > 0) {
//            transaction.responseThumbnail = [MLSFLEXResources xmlIcon];
//        } else if ([mimeType hasPrefix:@"audio"]) {
//            transaction.responseThumbnail = [MLSFLEXResources audioIcon];
//        } else if ([mimeType hasPrefix:@"video"]) {
//            transaction.responseThumbnail = [MLSFLEXResources videoIcon];
//        } else if ([mimeType hasPrefix:@"text"]) {
//            transaction.responseThumbnail = [MLSFLEXResources textIcon];
//        }
        MLSBugLogNetwork(@"%@ -- %@", [MLSFLEXNetworkTransaction readableStringFromTransactionState:transaction.transactionState],transaction.logString);
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error
{
    dispatch_async(self.queue, ^{
        MLSFLEXNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.transactionState = MLSFLEXNetworkTransactionStateFailed;
        transaction.duration = -[transaction.startTime timeIntervalSinceNow];
        transaction.error = error;
        MLSBugLogNetwork(@"%@ -- %@", [MLSFLEXNetworkTransaction readableStringFromTransactionState:transaction.transactionState],transaction.logString);
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID
{
    dispatch_async(self.queue, ^{
        MLSFLEXNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.requestMechanism = mechanism;
//        MLSBugLogNetwork(@"%@ -- %@", [MLSFLEXNetworkTransaction readableStringFromTransactionState:transaction.transactionState],transaction.logString);
        [self postUpdateNotificationForTransaction:transaction];
    });
}

#pragma mark Notification Posting

- (void)postNewTransactionNotificationWithTransaction:(MLSFLEXNetworkTransaction *)transaction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary<NSString *, id> *userInfo = @{ kMLSFLEXNetworkRecorderUserInfoTransactionKey : transaction };
        [[NSNotificationCenter defaultCenter] postNotificationName:kMLSFLEXNetworkRecorderNewTransactionNotification object:self userInfo:userInfo];
    });
}

- (void)postUpdateNotificationForTransaction:(MLSFLEXNetworkTransaction *)transaction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary<NSString *, id> *userInfo = @{ kMLSFLEXNetworkRecorderUserInfoTransactionKey : transaction };
        [[NSNotificationCenter defaultCenter] postNotificationName:kMLSFLEXNetworkRecorderTransactionUpdatedNotification object:self userInfo:userInfo];
    });
}

@end
