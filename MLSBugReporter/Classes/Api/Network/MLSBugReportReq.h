//
//  MLSBugReportReq.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All rights reserved.
//

#import <MLSNetwork/MLSNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLSBugReportReq <__covariant ContentType> : MLSNetworkRequest <ContentType>
- (NSString *)modlueName;
- (NSString *)methodName;
- (NSDictionary *)otherQueryParams;
@end

NS_ASSUME_NONNULL_END
