//
//  MLSBugRepotRootModel.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/15.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSBugRepotRootModel.h"

@implementation MLSBugRepotRootModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"message" : @[@"message", @"reason"], @"data" : @[@"data", @"user"]};
}
- (BOOL)isValid {
    return [self responseHeaderStatusCodeIsValid];
}
- (id)data {
    if (self.md5.length > 0 && [_data isKindOfClass:NSString.class]) {
        NSError *error = nil;
        id obj = [NSJSONSerialization JSONObjectWithData:[_data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (!error && obj) {
            _data = obj;
        }
    }
    return _data;
}

- (BOOL)responseHeaderStatusCodeIsValid {
    return self.responseHeaderStatusCode == 200;
}

- (nullable NSError *)validError {
    return [NSError errorWithDomain:@"com.minlison.bugreport" code:self.code userInfo:@{NSLocalizedDescriptionKey : self.message?:@""}];
}

- (BOOL)needRetryPreRequest {
    return NO;
}

- (BOOL)needRetry {
    return NO;
}

- (nullable id <MLSRetryPreRequestProtocol> )retryPreRequest {
    return nil;
}
@end
