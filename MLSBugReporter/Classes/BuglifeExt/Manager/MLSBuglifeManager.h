//
//  MLSBuglifeManager.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/24.
//

#import <Foundation/Foundation.h>
#import "Buglife.h"
NS_ASSUME_NONNULL_BEGIN

@interface MLSBuglifeManager : NSObject
+ (void)installWithOptions:(LIFEInvocationOptions)options;
@end

NS_ASSUME_NONNULL_END
