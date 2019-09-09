//
//  MLSBugReportCreateBugReq.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/15.
//

#import "MLSBugReportCreateBugReq.h"
#import "MLSBugReporterOptions.h"
@interface MLSBugReportCreateBugReq ()
@property (nonatomic, copy) NSString *productID;
@property (nonatomic, strong) NSDictionary *t_params;
@end
@implementation MLSBugReportCreateBugReq
+ (instancetype)requestWithProductID:(NSString *)productID params:(NSDictionary *)params {
    MLSBugReportCreateBugReq *req = [MLSBugReportCreateBugReq requestWithParam:params];
    req.productID = productID;
    req.t_params = params;
    return req;
}
- (NSString *)modlueName {
    return @"bug";
}
- (NSString *)methodName {
    return @"create";
}
- (NSDictionary *)otherQueryParams {
    return @{@"productID" : self.productID?:@(0)};
}

- (MLSRequestMethod)requestMethod {
    return MLSRequestMethodPOST;
}
- (Class)modelClass {
    return MLSZenTaoBugModel.class;
}
@end
