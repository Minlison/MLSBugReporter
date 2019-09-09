//
//  MLSZenTaoLoginReq.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSZenTaoLoginReq.h"
#import "MLSBugReporterOptions.h"
#import <AFNetworking/AFNetworking.h>
@implementation MLSZenTaoLoginReq
+ (instancetype)requestWithFormParams:(NSDictionary <NSString *,NSString *>*)formParams {
    MLSZenTaoLoginReq *req = [self requestWithParam:formParams];
    req.constructingBodyBlock = ^(id<AFMultipartFormData> formData) {
        [formParams enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [formData appendPartWithFormData:[[NSString stringWithFormat:@"%@",obj] dataUsingEncoding:NSUTF8StringEncoding] name:key];
        }];
    };
    return req;
}

- (NSString *)modlueName {
    return @"user";
}
- (NSString *)methodName {
    return @"login";
}

- (Class)modelClass {
    return MLSZenTaoUserModel.class;
}
- (MLSRequestMethod)requestMethod {
    return MLSRequestMethodPOST;
}
@end
