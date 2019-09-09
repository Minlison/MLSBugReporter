//
//  MLSBaseTableViewController.h
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//
#if __has_include(<QMUIKit/QMUIKit.h>)
#import <QMUIKit/QMUIKit.h>
#else
#import "QMUIKit.h"
#endif
#import "MLSBaseTableView.h"
#import "MLSBaseViewController.h"
#import "MLSBaseTableViewDelegate.h"
NS_ASSUME_NONNULL_BEGIN
@interface MLSBaseTableViewController : MLSBaseViewController <QMUITableViewDelegate, QMUITableViewDataSource>

- (instancetype)initWithStyle:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 *  初始化时调用的方法，会在两个 NS_DESIGNATED_INITIALIZER 方法中被调用，所以子类如果需要同时支持两个 NS_DESIGNATED_INITIALIZER 方法，则建议把初始化时要做的事情放到这个方法里。否则仅需重写要支持的那个 NS_DESIGNATED_INITIALIZER 方法即可。
 */
- (void)didInitializedWithStyle:(UITableViewStyle)style NS_REQUIRES_SUPER;

/// 获取当前的 `UITableViewStyle`
@property(nonatomic, assign, readonly) UITableViewStyle style;

/// 获取当前的 tableView
@property(nonatomic, strong, readonly) IBOutlet MLSBaseTableView *tableView;

/**
 代理,默认 self
 */
@property (nonatomic, weak) id <QMUITableViewDelegate> delegate;

/**
 数据源，默认 self
 */
@property (nonatomic, weak) id <QMUITableViewDataSource> dataSource;
/**
 初试化隐藏tableHeaderView

 @param animated 是否动画
 @param force 是否强制执行
 */
- (void)hideTableHeaderViewInitialIfCanWithAnimated:(BOOL)animated force:(BOOL)force;
@end

@interface MLSBaseTableViewController (SubclassingHooks)

/**
 *  初始化tableView，在initSubViews的时候被自动调用。
 *
 *  一般情况下，有关tableView的设置属性的代码都应该写在这里。
 */
- (void)initTableView;

/**
 *  布局 tableView 的方法独立抽取出来，方便子类在需要自定义 tableView.frame 时能重写并且屏蔽掉 super 的代码。如果不独立一个方法而是放在 viewDidLayoutSubviews 里，子类就很难屏蔽 super 里对 tableView.frame 的修改。
 *  默认的实现是撑满 self.view，如果要自定义，可以写在这里而不调用 super，或者干脆重写这个方法但留空
 */
- (void)layoutTableView;

/**
 *  是否需要在第一次进入界面时将tableHeaderView隐藏（通过调整self.tableView.contentOffset实现）
 *
 *  默认为NO
 *
 *  @see QMUITableViewDelegate
 */
- (BOOL)shouldHideTableHeaderViewInitial;

@end


NS_ASSUME_NONNULL_END
