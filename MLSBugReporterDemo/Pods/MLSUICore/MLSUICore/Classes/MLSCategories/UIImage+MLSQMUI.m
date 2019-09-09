//
//  UIImage+MLSQMUI.m
//  MLSUICore
//
//  Created by minlison on 2019/3/9.
//

#import "UIImage+MLSQMUI.h"
#import "MLSUICore.h"
#import <ImageIO/ImageIO.h>
#import <Accelerate/Accelerate.h>
#import <QMUIKit/QMUIKit.h>
/// Convert degrees to radians.
static inline CGFloat MLSQMUIDegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}
@implementation UIImage (MLSQMUI)

+ (UIImage *)qmui_arrowImageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size lineWidth:(CGFloat)lineWidth addClip:(BOOL)addClip {
    UIBezierPath *arrowPath = [[UIBezierPath alloc] init];
    [arrowPath moveToPoint:CGPointMake(lineWidth, lineWidth)];
    [arrowPath addLineToPoint:CGPointMake(size.width * 0.5, size.height - lineWidth)];
    [arrowPath addLineToPoint:CGPointMake(size.width - lineWidth, lineWidth)];
    arrowPath.lineWidth = lineWidth;
    return [self qmui_imageWithStrokeColor:strokeColor size:size path:arrowPath addClip:addClip];
}

+ (UIImage *)qmui_imageWithFillColor:(UIColor *)fillColor size:(CGSize)size path:(UIBezierPath *)path {
    size = CGSizeFlatted(size);
    CGContextInspectSize(size);
    UIImage *resultImage = nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextInspectContext(context);
    CGContextSetStrokeColorWithColor(context, fillColor.CGColor);
    [path fill];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

+ (UIImage *)qmui_arrowImageWithFillColor:(UIColor *)fillColor size:(CGSize)size {
    UIBezierPath *arrowPath = [[UIBezierPath alloc] init];
    [arrowPath moveToPoint:CGPointMake(0, 0)];
    [arrowPath addLineToPoint:CGPointMake(size.width * 0.5, size.height)];
    [arrowPath addLineToPoint:CGPointMake(size.width, 0)];
    return [self qmui_imageWithFillColor:fillColor size:size path:arrowPath];
}

- (UIImage *)qmui_imageByRotateLeft90 {
    return [self qmui_imageByRotate:MLSQMUIDegreesToRadians(90) fitSize:YES];
}

- (UIImage *)qmui_imageByRotateRight90 {
    return [self qmui_imageByRotate:MLSQMUIDegreesToRadians(-90) fitSize:YES];
}

- (UIImage *)qmui_imageByRotate180 {
    return [self qmui_flipHorizontal:YES vertical:YES];
}

- (UIImage *)qmui_imageByFlipVertical {
    return [self qmui_flipHorizontal:NO vertical:YES];
}

- (UIImage *)qmui_imageByFlipHorizontal {
    return [self qmui_flipHorizontal:YES vertical:NO];
}
- (UIImage *)qmui_flipHorizontal:(BOOL)horizontal vertical:(BOOL)vertical {
    if (!self.CGImage) return nil;
    size_t width = (size_t)CGImageGetWidth(self.CGImage);
    size_t height = (size_t)CGImageGetHeight(self.CGImage);
    size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    if (!context) return nil;
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
    UInt8 *data = (UInt8 *)CGBitmapContextGetData(context);
    if (!data) {
        CGContextRelease(context);
        return nil;
    }
    vImage_Buffer src = { data, height, width, bytesPerRow };
    vImage_Buffer dest = { data, height, width, bytesPerRow };
    if (vertical) {
        vImageVerticalReflect_ARGB8888(&src, &dest, kvImageBackgroundColorFill);
    }
    if (horizontal) {
        vImageHorizontalReflect_ARGB8888(&src, &dest, kvImageBackgroundColorFill);
    }
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *img = [UIImage imageWithCGImage:imgRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imgRef);
    return img;
}

- (UIImage *)qmui_imageByRotate:(CGFloat)radians fitSize:(BOOL)fitSize {
    size_t width = (size_t)CGImageGetWidth(self.CGImage);
    size_t height = (size_t)CGImageGetHeight(self.CGImage);
    CGRect newRect = CGRectApplyAffineTransform(CGRectMake(0., 0., width, height),
                                                fitSize ? CGAffineTransformMakeRotation(radians) : CGAffineTransformIdentity);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 (size_t)newRect.size.width,
                                                 (size_t)newRect.size.height,
                                                 8,
                                                 (size_t)newRect.size.width * 4,
                                                 colorSpace,
                                                 kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    if (!context) return nil;
    
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextTranslateCTM(context, +(newRect.size.width * 0.5), +(newRect.size.height * 0.5));
    CGContextRotateCTM(context, radians);
    
    CGContextDrawImage(context, CGRectMake(-(width * 0.5), -(height * 0.5), width, height), self.CGImage);
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    UIImage *img = [UIImage imageWithCGImage:imgRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imgRef);
    CGContextRelease(context);
    return img;
}
@end
