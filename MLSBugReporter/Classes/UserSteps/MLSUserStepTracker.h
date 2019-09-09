//
//  MLSUserStepTracker.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLSUserStepTracker : NSObject
+ (void)install;
+ (void)unInstall;
+ (NSString *)getLoggFile;
@end

NS_ASSUME_NONNULL_END
