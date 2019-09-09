//
//  MLSZenTaoLoginReq.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSBugReportReq.h"
#import "MLSZenTaoUserModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MLSZenTaoLoginReq : MLSBugReportReq <MLSZenTaoUserModel *>
+ (instancetype)requestWithFormParams:(NSDictionary <NSString *,NSString *>*)formParams;
@end

NS_ASSUME_NONNULL_END
