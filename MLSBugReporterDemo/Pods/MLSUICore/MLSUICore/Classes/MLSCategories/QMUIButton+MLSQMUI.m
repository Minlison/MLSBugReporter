//
//  QMUIButton+MLSQMUI.m
//  MLSUICore
//
//  Created by minlison on 2019/3/6.
//

#import "QMUIButton+MLSQMUI.h"
@interface QMUIButton_MLSQMUI : NSObject
@end
@implementation QMUIButton_MLSQMUI
@end
@implementation QMUIButton (MLSQMUI)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 使用 [UIColor colorWithRed:green:blue:alpha:] 或 [UIColor colorWithHue:saturation:brightness:alpha:] 方法创建的颜色是 UIDeviceRGBColor 类型的而不是 UIColor 类型的
        ExchangeImplementations(QMUIButton.class, @selector(sizeThatFits:), @selector(MLS_sizeThatFits:));
    });
}
- (CGSize)MLS_sizeThatFits:(CGSize)size {
    CGSize qmui_size = [self MLS_sizeThatFits:size];
    // 弥补QMUIButton 没有计算背景图片大小
    CGSize super_size = [super sizeThatFits:size];
    return CGSizeMake(MAX(qmui_size.width, super_size.width), MAX(qmui_size.height, super_size.height));
}
@end
