//
//  MLSBugReportCreateBugReq.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/15.
//

#import "MLSBugReportReq.h"
#import "MLSZenTaoBugModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLSBugReportCreateBugReq : MLSBugReportReq <MLSZenTaoBugModel *>

/**
 创建Bug

 @param productID 产品id，如果为空，则返回全部产品列表
 @param params 附加参数，如果附加参数为空，则返回全部产品列表
 @return req
 */
+ (instancetype)requestWithProductID:(nullable NSString *)productID params:(nullable NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
