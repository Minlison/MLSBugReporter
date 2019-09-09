//
//  MLSZenTaoUploadFileReq.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/17.
//

#import "MLSZenTaoUploadFileReq.h"

@implementation MLSZenTaoUploadFileReq
- (NSString *)modlueName {
    return @"file";
}
- (NSString *)methodName {
    return @"ajaxUpload";
}
- (NSDictionary *)otherQueryParams {
    return @{
             @"dir" : @"image"
             };
}
- (MLSRequestMethod)requestMethod {
    return MLSRequestMethodPOST;
}
@end
