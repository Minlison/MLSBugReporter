//
//  MLSTipClass.m
//  MinLison
//
//  Created by minlison on 2017/10/11.
//  Copyright © 2017年 minlison. All rights reserved.
//

#import "MLSTipClass.h"
#import "MLSTipLittleLoadingView.h"
#define WGTipHideDelay 1.5

@implementation MLSTipClass
+ (QMUITips *)showText:(nullable NSString *)text inView:(nullable UIView *)view position:(QMUIToastViewPosition)position {
    QMUITips *tips = [self createTipsToView:[self getNotNullViewForView:view]];
    tips.toastPosition = position;
    [tips showWithText:text detailText:nil hideAfterDelay:WGTipHideDelay];
    return tips;
}
+ (QMUITips *)showText:(NSString *)text inView:(UIView *)view {
        return [QMUITips showWithText:text inView:[self getNotNullViewForView:view] hideAfterDelay:WGTipHideDelay];
}

+ (UIView *)getNotNullViewForView:(nullable UIView *)view {
        UIView *showView = view ?:[UIApplication sharedApplication].keyWindow;
        [QMUITips hideAllToastInView:showView animated:NO];
        return showView;
}
+ (QMUITips *)showTipsWithText:(nullable NSString *)text inView:(nullable UIView *)view {
    return [QMUITips showInfo:text inView:[self getNotNullViewForView:view] hideAfterDelay:WGTipHideDelay];
}
+ (QMUITips *)showText:(NSString *)text {
        return [self showText:text inView:nil];
}
+ (QMUITips *)showLoading {
    return [self showLoadingInView:nil];
}
+ (void)hideLoading {
    return [self hideLoadingInView:nil];
}
+ (QMUITips *)showLoadingInView:(nullable UIView *)view {
        return [QMUITips showLoadingInView:[self getNotNullViewForView:view]];
}
+ (QMUITips *)showNormalLoadingInView:( nullable UIView *)view withText:(NSString *)text {
    return [QMUITips showLoading:text inView:[self getNotNullViewForView:view]];
}
+ (QMUITips *)showNormalSuccessWithText:(nullable NSString *)text inView:(nullable UIView *)view {
    return [QMUITips showSucceed:text inView:[self getNotNullViewForView:view] hideAfterDelay:WGTipHideDelay];
}
+ (QMUITips *)showLoadingInView:(nullable UIView * )view withText:(NSString *)text {
    QMUITips *tips = [self createTipsToView:[self getNotNullViewForView:view]];
    MLSTipLittleLoadingView *loadView = [MLSTipLittleLoadingView tipLittlLoadingViewWithTitle:text success:NO];
    CGRect frame = CGRectZero;
    frame.size = [loadView systemLayoutSizeFittingSize:CGSizeMax];
    loadView.frame = frame;
    QMUIToastContentView *contentView = (QMUIToastContentView *)tips.contentView;
    contentView.customView = loadView;
    contentView.textLabelText = @"";
    contentView.detailTextLabelText = @"";
    [tips showAnimated:YES];
    return tips;
}

+ (QMUITips *)showSuccessWithText:(nullable NSString *)text inView:(nullable UIView *)view {
    QMUITips *tips = [self createTipsToView:[self getNotNullViewForView:view]];
    MLSTipLittleLoadingView *loadView = [MLSTipLittleLoadingView tipLittlLoadingViewWithTitle:text success:YES];
    CGRect frame = CGRectZero;
    frame.size = [loadView systemLayoutSizeFittingSize:CGSizeMax];
    loadView.frame = frame;
    QMUIToastContentView *contentView = (QMUIToastContentView *)tips.contentView;
    contentView.customView = loadView;
    contentView.textLabelText = @"";
    contentView.detailTextLabelText = @"";
    [tips showAnimated:YES];
    [tips hideAnimated:YES afterDelay:WGTipHideDelay];
    return tips;
}

+ (QMUITips *)showErrorWithText:(nullable NSString *)text inView:(nullable UIView *)view {
        return [QMUITips showError:text inView:[self getNotNullViewForView:view] hideAfterDelay:WGTipHideDelay];
}

+ (void)hideLoadingInView:(nullable UIView *)view {
      [QMUITips hideAllToastInView:[self getNotNullViewForView:view] animated:YES];
}

+ (QMUITips *)showLoading:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    QMUITips *tips = [self createTipsToView:view];
    [tips showLoading:text detailText:detailText hideAfterDelay:delay];
    return tips;
}

+ (QMUITips *)createTipsToView:(UIView *)view {
    QMUITips *tips = [[QMUITips alloc] initWithView:view];
    [view addSubview:tips];
    tips.removeFromSuperViewWhenHide = YES;
    return tips;
}

@end
