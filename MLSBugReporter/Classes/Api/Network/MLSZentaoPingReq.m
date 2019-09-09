//
//  MLSZentaoPingReq.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/16.
//

#import "MLSZentaoPingReq.h"

@implementation MLSZentaoPingReq
- (NSString *)modlueName {
    return @"misc";
}
- (NSString *)methodName {
    return @"ping";
}
- (MLSResponseSerializerType)responseSerializerType {
    return MLSResponseSerializerTypeHTTP;
}
@end
