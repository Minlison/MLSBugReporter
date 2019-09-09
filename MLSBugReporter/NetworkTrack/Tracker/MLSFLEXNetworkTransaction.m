//
//  MLSFLEXNetworkTransaction.m
//  Flipboard
//
//  Created by Ryan Olson on 2/8/15.
//  Copyright (c) 2015 Flipboard. All rights reserved.
//

#import "MLSFLEXNetworkTransaction.h"
#import "MLSFLEXUtility.h"
#import "MLSFLEXNetworkRecorder.h"
@interface MLSFLEXNetworkTransaction ()

@property (nonatomic, strong, readwrite) NSData *cachedRequestBody;
@end

@implementation MLSFLEXNetworkTransaction
- (NSString *)jsonString {
    return [[NSString alloc] initWithData:self.jsonData encoding:NSUTF8StringEncoding];
}
- (NSData *)jsonData {
    return [NSJSONSerialization dataWithJSONObject:self.jsonObject options:(NSJSONWritingPrettyPrinted) error:nil];
}
- (NSDictionary *)jsonObject {
    NSDateFormatter *startTimeFormatter = [[NSDateFormatter alloc] init];
    startTimeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    return @{
             @"requestID" : self.requestID?:@"",
             @"requestURL" : self.request.URL.absoluteString?:@"",
             @"requestMethod" : self.request.HTTPMethod?:@"",
             @"timout" : @(self.request.timeoutInterval),
             @"requestHeader" : self.request.allHTTPHeaderFields?:@{},
             @"requestBody" : [self postBodyObject],
             @"mime" : self.response.MIMEType?:@"",
             @"mechanism" : self.requestMechanism?:@"",
             @"startTime" : [startTimeFormatter stringFromDate:self.startTime],
             @"timeInterval" : [NSString stringWithFormat:@"%f", [self.startTime timeIntervalSince1970]],
             @"duration" : [MLSFLEXUtility stringFromRequestDuration:self.duration],
             @"latency" : [MLSFLEXUtility stringFromRequestDuration:self.latency],
             @"receivedDataLength" : @(self.receivedDataLength),
             @"error" : self.error?:@"",
             @"responseBody" : [self responseBodyJsonObject]
             };
}
- (NSData *)logData {
    return [self.logString dataUsingEncoding:NSUTF8StringEncoding];
}
- (NSString *)logString {
    NSDateFormatter *startTimeFormatter = [[NSDateFormatter alloc] init];
    startTimeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    return [NSString stringWithFormat:@"{ URL: %@ } \n{ method: %@ } \n{ header: %@} \n{startTime: %@} \n{ duration: %@ } \n{ timout: %@ } \n{ arguments: %@ } \n{ result: %@ } \n\n", self.request.URL, self.request.HTTPMethod, self.request.allHTTPHeaderFields, [startTimeFormatter stringFromDate:self.startTime], [MLSFLEXUtility stringFromRequestDuration:self.duration], @(self.request.timeoutInterval), [self postBodyObject], [self maxResponseJsonString]];
}
- (NSString *)maxResponseJsonString {
    NSString *jsonString = [NSString stringWithFormat:@"%@",self.responseBodyJsonObject];
    NSUInteger maxLength = self.responseMaxLength ?:1024;
    if (jsonString.length > maxLength) {
        return [jsonString substringToIndex:maxLength];
    }
    return jsonString;
}
- (id)responseBodyJsonObject {
    NSUInteger maxLength = self.responseMaxLength ?:1024;
    NSData *data = [[MLSFLEXNetworkRecorder defaultRecorder] cachedResponseBodyForTransaction:self];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([NSJSONSerialization isValidJSONObject:jsonString] ) {
        NSError *error = nil;
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!error) {
            return jsonObject;
        }
        if (jsonString.length > maxLength) {
            return [jsonString substringToIndex:maxLength];
        }
        return jsonString;
    }
    if (jsonString.length > maxLength) {
        return [jsonString substringToIndex:maxLength];
    }
    return jsonString;
}
- (NSDictionary *)postBodyObject {
    if ([self.cachedRequestBody length] > 0) {
        NSString *contentType = [self.request valueForHTTPHeaderField:@"Content-Type"];
        if ([contentType hasPrefix:@"application/x-www-form-urlencoded"]) {
            NSString *bodyString = [[NSString alloc] initWithData:[self postBodyData] encoding:NSUTF8StringEncoding];
            NSDictionary *bodyDict = [MLSFLEXUtility dictionaryFromQuery:bodyString];
            return bodyDict;
        }
    }
    return @{};
}

- (NSData *)postBodyData
{
    NSData *bodyData = self.cachedRequestBody;
    if ([bodyData length] > 0) {
        NSString *contentEncoding = [self.request valueForHTTPHeaderField:@"Content-Encoding"];
        if ([contentEncoding rangeOfString:@"deflate" options:NSCaseInsensitiveSearch].length > 0 || [contentEncoding rangeOfString:@"gzip" options:NSCaseInsensitiveSearch].length > 0) {
            bodyData = [MLSFLEXUtility inflatedDataFromCompressedData:bodyData];
        }
    }
    return bodyData;
}
- (NSString *)description
{
    NSString *description = [super description];

    description = [description stringByAppendingFormat:@" id = %@;", self.requestID];
    description = [description stringByAppendingFormat:@" url = %@;", self.request.URL];
    description = [description stringByAppendingFormat:@" duration = %f;", self.duration];
    description = [description stringByAppendingFormat:@" receivedDataLength = %lld", self.receivedDataLength];

    return description;
}

- (NSData *)cachedRequestBody {
    if (!_cachedRequestBody) {
        if (self.request.HTTPBody != nil) {
            _cachedRequestBody = self.request.HTTPBody;
        } else if ([self.request.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
            NSInputStream *bodyStream = [self.request.HTTPBodyStream copy];
            const NSUInteger bufferSize = 1024;
            uint8_t buffer[bufferSize];
            NSMutableData *data = [NSMutableData data];
            [bodyStream open];
            NSInteger readBytes = 0;
            do {
                readBytes = [bodyStream read:buffer maxLength:bufferSize];
                [data appendBytes:buffer length:readBytes];
            } while (readBytes > 0);
            [bodyStream close];
            _cachedRequestBody = data;
        }
    }
    return _cachedRequestBody;
}

+ (NSString *)readableStringFromTransactionState:(MLSFLEXNetworkTransactionState)state
{
    NSString *readableString = nil;
    switch (state) {
        case MLSFLEXNetworkTransactionStateUnstarted:
            readableString = @"Unstarted";
            break;

        case MLSFLEXNetworkTransactionStateAwaitingResponse:
            readableString = @"Awaiting Response";
            break;

        case MLSFLEXNetworkTransactionStateReceivingData:
            readableString = @"Receiving Data";
            break;

        case MLSFLEXNetworkTransactionStateFinished:
            readableString = @"Finished";
            break;

        case MLSFLEXNetworkTransactionStateFailed:
            readableString = @"Failed";
            break;
    }
    return readableString;
}

@end
