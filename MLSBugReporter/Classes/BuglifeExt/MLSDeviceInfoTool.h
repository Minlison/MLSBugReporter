//
//  MLSDeviceInfoTool.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLSDeviceInfoTool : NSObject
+ (void)appendApplicaitonInfo:(NSMutableString *)string;
+ (NSString *)getApplicationInfo;
@end

NS_ASSUME_NONNULL_END
