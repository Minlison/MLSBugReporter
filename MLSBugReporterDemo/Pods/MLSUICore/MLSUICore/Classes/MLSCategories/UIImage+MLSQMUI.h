//
//  UIImage+MLSQMUI.h
//  MLSUICore
//
//  Created by minlison on 2019/3/9.
//



NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MLSQMUI)

/**
 绘制箭头

 @param strokeColor 外描边颜色
 @param size 大小
 @param lineWidth 线宽
 @param addClip clip
 @return image
 */
+ (UIImage *)qmui_arrowImageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size lineWidth:(CGFloat)lineWidth addClip:(BOOL)addClip;

/**
 绘制箭头
 
 @param fillColor 填充色
 @param size 大小
 @param path 路径
 @return image
 */
+ (UIImage *)qmui_imageWithFillColor:(UIColor *)fillColor size:(CGSize)size path:(UIBezierPath *)path;

/**
 绘制箭头

 @param fillColor 填充色
 @param size 大小
 @return img
 */
+ (UIImage *)qmui_arrowImageWithFillColor:(UIColor *)fillColor size:(CGSize)size;
- (UIImage *)qmui_imageByRotateLeft90;
- (UIImage *)qmui_imageByRotateRight90;
- (UIImage *)qmui_imageByRotate180;
- (UIImage *)qmui_imageByFlipVertical;
- (UIImage *)qmui_imageByFlipHorizontal;
@end

NS_ASSUME_NONNULL_END
