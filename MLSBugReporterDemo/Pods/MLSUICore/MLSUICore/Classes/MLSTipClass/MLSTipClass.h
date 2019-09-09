//
//  MLSTipClass.h
//  MinLison
//
//  Created by minlison on 2017/10/11.
//  Copyright © 2017年 minlison. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<QMUIKit/QMUIKit.h>)
#import <QMUIKit/QMUIKit.h>
#else
#import "QMUIKit.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface MLSTipClass : NSObject

/**
 显示提示文字

 @param text 文字
 @param view 在哪个View 中显示，如果为空，默认为 Window
 @param position 位置
 @return QMUITips
 */
+ (QMUITips *)showText:(nullable NSString *)text inView:(nullable UIView *)view position:(QMUIToastViewPosition)position;

/**
 显示提示文字

 @param text 文字
 @param view 在哪个View 中显示，如果为空，默认为 Window
 @return QMUITips
 */
+ (QMUITips *)showText:(nullable NSString *)text inView:(nullable UIView *)view;

/**
 显示提示文字

 @param text 文字
 @return QMUITips
 */
+ (QMUITips *)showText:(nullable NSString *)text;

/**
 显示加载菊花

 @return QMUITips
 */
+ (QMUITips *)showLoading;

/**
 隐藏 loading
 */
+ (void)hideLoading;

/**
 大菊花加载视图

 @param view 在哪个视图中显示，如果为空，默认为 Window
 @return QMUITips
 */
+ (QMUITips *)showLoadingInView:( nullable UIView *)view;

/**
 显示大菊花加载视图，并且附带文字

 @param view 在哪个视图中显示，如果为空，默认为 Window
 @param text 文字
 @return QMUITips
 */
+ (QMUITips *)showNormalLoadingInView:( nullable UIView *)view withText:(NSString *)text;

/**
 显示小菊花加载视图
 
 @param view 在哪个视图中展示，如果为空，默认为 Window
 @param text 文字
 @return QMUITips
 */
+ (QMUITips *)showLoadingInView:( nullable UIView *)view withText:(NSString *)text;

/**
 显示成功的大对号

 @param text 文字
 @param view 在哪个视图中显示，如果为空，默认为 Window
 @return QMUITips
 */
+ (QMUITips *)showNormalSuccessWithText:(nullable NSString *)text inView:(nullable UIView *)view;

/**
 显示成功小对号
 
 @param text 文字
 @param view 在哪个视图中展示，如果为空，默认为 Window
 @return QMUITips
 */
+ (QMUITips *)showSuccessWithText:(nullable NSString *)text inView:(nullable UIView *)view;

/**
 显示提示文字

 @param text 文字
 @param view 在哪个视图中显示，如果为空，默认为 Window
 @return QMUITips
 */
+ (QMUITips *)showTipsWithText:(nullable NSString *)text inView:(nullable UIView *)view;

/**
 显示错误提示

 @param text 文字
 @param view 在哪个视图中显示，如果为空，默认为 Window
 @return QMUITips
 */
+ (QMUITips *)showErrorWithText:(nullable NSString *)text inView:(nullable UIView *)view;

/**
 隐藏视图

 @param view 在哪个视图中隐藏，如果为空，默认为 Window
 */
+ (void)hideLoadingInView:(nullable UIView *)view;
@end

NS_ASSUME_NONNULL_END
