//
//  MLSCrashTracker.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLSCrashTracker : NSObject
+ (MLSCrashTracker *)sharedInstance;
+ (void)install;
+ (void)unInstall;
@end

NS_ASSUME_NONNULL_END
