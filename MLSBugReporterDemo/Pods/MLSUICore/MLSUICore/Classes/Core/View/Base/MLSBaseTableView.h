//
//  MLSBaseTableView.h
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//


#if __has_include(<QMUIKit/QMUIKit.h>)
#import <QMUIKit/QMUIKit.h>
#else
#import "QMUIKit.h"
#endif
@interface MLSBaseTableView : QMUITableView

/**
 是否自动调整 header 动画效果
 */
@property(nonatomic, assign) BOOL enableAutoAdjustHeader;

/**
 缩放 header 的背景视图
 默认是与 tableViewHeader bounds 相等的 view
 如果设置不为空 enableAutoAdjustHeader 自动设置成 YES，如果为空 enableAutoAdjustHeader 设置成 NO
 */
@property(nonatomic, strong) UIView *autoAdjustView;

/**
 获取截图

 @return 整个tableView的截图
 */
- (UIImage *)getTableFullSnapimage;
@end
