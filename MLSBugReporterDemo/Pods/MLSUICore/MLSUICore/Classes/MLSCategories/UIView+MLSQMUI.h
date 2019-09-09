//
//  UIView+QMUI.h
//  MLSSpecialExerciseDemo
//
//  Created by minlison on 2019/2/27.
//  Copyright © 2019 minlison. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (MLSQMUI)
/// 等价于 CGRectGetWidth(frame)
@property(nonatomic, assign) CGSize qmui_size;
@property(nonatomic, assign) CGFloat qmui_centerY;
@property(nonatomic, assign) CGFloat qmui_centerX;

@end

@interface UIView (MLSQMUIShadow)
/// 边框是否是阴影渐变
@property(nonatomic, assign) BOOL qmui_enableShadow;
/// 阴影透明度
@property(nonatomic, assign) CGFloat qmui_shadowOpacity;
/// 阴影颜色
@property(nonatomic, strong) UIColor *qmui_shadowColor;
/// 阴影宽度
@property (nonatomic, assign) CGFloat qmui_shadowWidth;
// 阴影角度
@property (nonatomic, assign) CGFloat qmui_shadowRadius;
@end
NS_ASSUME_NONNULL_END
