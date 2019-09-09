//
//  MLSZenTaoGetAllBuildsReq.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/17.
//

#import "MLSBugReportReq.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLSZenTaoGetAllBuildsReq : MLSBugReportReq
+ (instancetype)requestWithProductID:(NSString *)productID;
@end

NS_ASSUME_NONNULL_END
