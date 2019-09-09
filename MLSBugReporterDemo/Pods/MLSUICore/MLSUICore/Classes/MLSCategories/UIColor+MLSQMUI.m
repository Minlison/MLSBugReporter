//
//  UIColor+QMUI.m
//  MLSSpecialExerciseDemo
//
//  Created by minlison on 2019/2/27.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "UIColor+MLSQMUI.h"
#import <MLSUICore/MLSUICore.h>
#import <QMUIKit/QMUIKit.h>
#import <objc/runtime.h>
@interface UIColor_MLSQMUI : NSObject
@end
@implementation UIColor_MLSQMUI
@end
@implementation UIColor (MLSQMUI)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 使用 [UIColor colorWithRed:green:blue:alpha:] 或 [UIColor colorWithHue:saturation:brightness:alpha:] 方法创建的颜色是 UIDeviceRGBColor 类型的而不是 UIColor 类型的
        ExchangeImplementations(object_getClass(UIColor.class), @selector(qmui_colorWithHexString:), @selector(MLS_qmui_colorWithHexString:));
    });
}
+ (instancetype)qmui_colorWithHexString:(NSString *)hex alpha:(CGFloat)alpha {
    return [[self qmui_colorWithHexString:hex] colorWithAlphaComponent:alpha];
}
+ (UIColor *)MLS_qmui_colorWithHexString:(NSString *)hexString {
    hexString = [hexString stringByReplacingOccurrencesOfString:@"0x" withString:@"#"];
    hexString = [hexString stringByReplacingOccurrencesOfString:@"0X" withString:@"#"];
    return [self MLS_qmui_colorWithHexString:hexString];
}
@end
