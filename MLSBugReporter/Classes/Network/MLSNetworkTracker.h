//
//  MLSNetworkTracker.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLSNetworkTracker : NSObject
+ (void)install;
+ (void)uninstall;
+ (void)setResponseMaxLength:(NSUInteger)maxLength;
+ (void)setTrackingNetworkURLFilter:(NSString *)trackingNetworkURLFilter;
+ (void)setUnTrackingNetworkURLFilter:(NSString *)unTrackingNetworkURLFilter;
@end

NS_ASSUME_NONNULL_END
