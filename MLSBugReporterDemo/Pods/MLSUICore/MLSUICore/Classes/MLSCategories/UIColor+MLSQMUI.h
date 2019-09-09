//
//  UIColor+QMUI.h
//  MLSSpecialExerciseDemo
//
//  Created by minlison on 2019/2/27.
//  Copyright © 2019 minlison. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (MLSQMUI)
+ (instancetype)qmui_colorWithHexString:(NSString *)hex alpha:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
