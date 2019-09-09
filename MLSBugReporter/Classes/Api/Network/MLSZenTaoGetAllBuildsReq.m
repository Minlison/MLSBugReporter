//
//  MLSZenTaoGetAllBuildsReq.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/17.
//

#import "MLSZenTaoGetAllBuildsReq.h"
@interface MLSZenTaoGetAllBuildsReq ()
@property (nonatomic, copy) NSString *productID;
@end
@implementation MLSZenTaoGetAllBuildsReq
+ (instancetype)requestWithProductID:(NSString *)productID {
    MLSZenTaoGetAllBuildsReq *req = [self requestWithParam:nil];
    req.productID = productID;
    return req;
}
- (NSString *)modlueName {
    return @"build";
}
- (NSString *)methodName {
    return @"ajaxGetProductBuilds";
}
- (NSDictionary *)otherQueryParams {
    return @{
             @"varName" : @"openedBuild",
             @"productID" : self.productID?:@"0",
             };
}
@end
