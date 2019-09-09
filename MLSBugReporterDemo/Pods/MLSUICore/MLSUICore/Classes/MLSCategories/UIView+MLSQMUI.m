//
//  UIView+QMUI.m
//  MLSSpecialExerciseDemo
//
//  Created by minlison on 2019/2/27.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "UIView+MLSQMUI.h"
#import <MLSUICore/MLSUICore.h>
#import <QMUIKit/QMUIKit.h>
@interface UIView_MLSQMUI : NSObject
@end
@implementation UIView_MLSQMUI
@end

@implementation UIView (MLSQMUI)
- (void)setQmui_size:(CGSize)qmui_size {
    self.frame = CGRectSetSize(self.frame, qmui_size);
}
- (CGSize)qmui_size {
    return self.frame.size;
}
- (void)setQmui_centerX:(CGFloat)qmui_centerX {
    CGPoint center = self.center;
    center.x = qmui_centerX;
    self.center = center;
}
- (CGFloat)qmui_centerX {
    return self.center.x;
}

- (void)setQmui_centerY:(CGFloat)qmui_centerY {
    CGPoint center = self.center;
    center.y = qmui_centerY;
    self.center = center;
}
- (CGFloat)qmui_centerY {
    return self.center.y;
}
@end
@implementation UIView (MLSQMUIShadow)
QMUISynthesizeIdStrongProperty(qmui_borderLayer, setQmui_borderLayer)
QMUISynthesizeBOOLProperty(qmui_enableShadow, setQmui_enableShadow)
QMUISynthesizeFloatProperty(qmui_shadowOpacity, setQmui_shadowOpacity)
QMUISynthesizeIdStrongProperty(qmui_shadowColor, setQmui_shadowColor)
QMUISynthesizeFloatProperty(qmui_shadowWidth, setQmui_shadowWidth)
QMUISynthesizeFloatProperty(qmui_shadowRadius, setQmui_shadowRadius)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BeginIgnoreClangWarning(-Wundeclared-selector)
        ExchangeImplementations([self class], @selector(QMUIBorder_layoutSublayersOfLayer:), @selector(MLS_QMUIBorder_layoutSublayersOfLayer:));
        EndIgnoreClangWarning
    });
}

- (void)MLS_QMUIBorder_layoutSublayersOfLayer:(CALayer *)layer {
    [self MLS_QMUIBorder_layoutSublayersOfLayer:layer];
    if ((!self.qmui_borderLayer && self.qmui_borderPosition == QMUIViewBorderPositionNone) || (!self.qmui_borderLayer && self.qmui_borderWidth == 0)) {
        [self qmui_drawShadow:layer];
        return;
    }
    
    if (self.qmui_borderLayer && self.qmui_borderPosition == QMUIViewBorderPositionNone && !self.qmui_borderLayer.path) {
        [self qmui_drawShadow:layer];
        return;
    }
    
    if (self.qmui_borderLayer && self.qmui_borderWidth == 0 && self.qmui_borderLayer.lineWidth == 0) {
        [self qmui_drawShadow:layer];
        return;
    }
}
- (void)qmui_drawShadow:(CALayer *)layer {
    if (!self.qmui_enableShadow) {
        return;
    }
    if (!self.qmui_borderLayer) {
        self.qmui_borderLayer = [CAShapeLayer layer];
        [self.qmui_borderLayer qmui_removeDefaultAnimations];
        [self.layer addSublayer:self.qmui_borderLayer];
    }
    self.qmui_borderLayer.frame = self.bounds;
    
    CGFloat shadowWidth = self.qmui_shadowWidth;
    self.qmui_borderLayer.shadowOffset = CGSizeMake(0, 0);
    self.qmui_borderLayer.shadowColor = self.qmui_shadowColor.CGColor;
    self.qmui_borderLayer.shadowRadius = self.qmui_shadowWidth;
    self.qmui_borderLayer.shadowOpacity = self.qmui_shadowOpacity;
    self.qmui_borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.qmui_borderLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.qmui_borderLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInsetEdges(self.bounds, UIEdgeInsetsMake(-shadowWidth, -shadowWidth, -shadowWidth, -shadowWidth)) cornerRadius:self.qmui_shadowRadius].CGPath;
    self.layer.masksToBounds = NO;
    self.clipsToBounds = NO;
}
@end
