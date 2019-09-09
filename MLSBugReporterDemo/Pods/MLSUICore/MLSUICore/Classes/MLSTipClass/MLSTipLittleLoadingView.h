//
//  MLSTipLittleLoadingView.h
//  MLSUICore
//
//  Created by minlison on 2018/7/6.
//

#import <UIKit/UIKit.h>

/**
 测评中心加载视图
 */
@interface MLSTipLittleLoadingView : UIView

/**
 文字
 */
@property (nonatomic, copy) NSString *title;

/**
 是否成功
 */
@property (nonatomic, assign) BOOL success;

/**
 创建加载视图

 @param title 文字
 @param success 是否成功
 @return MLSTipLittleLoadingView
 */
+ (instancetype)tipLittlLoadingViewWithTitle:(NSString *)title success:(BOOL)success;
@end
