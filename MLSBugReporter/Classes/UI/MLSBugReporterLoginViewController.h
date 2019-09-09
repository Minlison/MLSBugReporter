//
//  MLSBugReporterLoginViewController.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/15.
//

#import <MLSUICore/MLSUICore.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLSBugReporterLoginViewController : MLSBaseViewController
+ (void)showIfNeed;
+ (void)showIfNeedAndLoginCompletion:(void (^)(BOOL success, NSError *error))completion;
+ (void)getBugProductID:(void (^)(BOOL success, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
