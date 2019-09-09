//
//  MLSBaseTableViewController.m
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//

#import "MLSBaseTableViewController.h"
#import "MLSBaseTableViewCell.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
@interface MLSBaseTableViewController ()
@property (nonatomic, strong ) MLSBaseTableViewDelegate *privateDelegate;
@property(nonatomic, strong, readwrite) MLSBaseTableView *tableView;
@property(nonatomic, assign) BOOL hasSetInitialContentInset;
@property(nonatomic, assign) BOOL hasHideTableHeaderViewInitial;
@property(nonatomic, assign) NSTimeInterval lastLoadingTimeInterval;
@end

@implementation MLSBaseTableViewController

- (instancetype)initWithRouteParam:(NSDictionary *)param {
    if (self = [self init]) {
        self.routeParam = param;
        [self didInitializedWithStyle:UITableViewStyleGrouped];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self didInitializedWithStyle:style];
    }
    return self;
}

- (instancetype)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitializedWithStyle:UITableViewStyleGrouped];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
}


- (void)didInitializedWithStyle:(UITableViewStyle)style {
    _style = style;
    self.hasHideTableHeaderViewInitial = NO;
}

/// MARK: - QMUIKit
- (void)dealloc {
    // 用下划线而不是self.xxx来访问tableView，避免dealloc时self.view尚未被加载，此时调用self.tableView反而会触发loadView
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    if (@available(iOS 11.0, *)) {
    } else {
        [_tableView removeObserver:self forKeyPath:@"contentInset"];
    }
}

- (NSString *)description {
#ifdef DEBUG
    if (![self isViewLoaded]) {
        return [super description];
    }
    
    NSString *result = [NSString stringWithFormat:@"%@\ntableView:\t\t\t\t%@", [super description], self.tableView];
    if ([self.tableView.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        NSInteger sections = [self.tableView.dataSource numberOfSectionsInTableView:self.tableView];
        if (sections > 0) {
            NSMutableString *sectionCountString = [[NSMutableString alloc] init];
            [sectionCountString appendFormat:@"\ndataCount(%@):\t\t\t\t(\n", @(sections)];
            NSInteger sections = [self.tableView.dataSource numberOfSectionsInTableView:self.tableView];
            for (NSInteger i = 0; i < sections; i++) {
                NSInteger rows = [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:i];
                [sectionCountString appendFormat:@"\t\t\t\t\t\t\tsection%@ - rows%@%@\n", @(i), @(rows), i < sections - 1 ? @"," : @""];
            }
            [sectionCountString appendString:@"\t\t\t\t\t\t)"];
            result = [result stringByAppendingString:sectionCountString];
        }
    }
    
    return result;
#else
    return [super description];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *backgroundColor = nil;
    if (self.style == UITableViewStylePlain) {
        backgroundColor = TableViewBackgroundColor;
    } else {
        backgroundColor = TableViewGroupedBackgroundColor;
    }
    if (backgroundColor) {
        self.view.backgroundColor = backgroundColor;
    }
}

- (void)initSubviews {
    [super initSubviews];
    [self initTableView];
    [self layoutTableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self hideTableHeaderViewInitialIfCanWithAnimated:NO force:NO];
    
    [self layoutEmptyView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context  {
    if ([keyPath isEqualToString:@"contentInset"]) {
        [self handleTableViewContentInsetChangeEvent];
    }
}

#pragma mark - Setter
- (void)setDelegate:(id<QMUITableViewDelegate>)delegate {
    _delegate = delegate;
    self.privateDelegate.receiver = delegate;
}

- (void)setDataSource:(id<QMUITableViewDataSource>)dataSource {
    _dataSource = dataSource;
    self.tableView.dataSource = dataSource;
}

#pragma mark - getter
- (MLSBaseTableViewDelegate *)privateDelegate {
    if (!_privateDelegate) {
        _privateDelegate = [[MLSBaseTableViewDelegate alloc] initWithReceiver:self];
    }
    return _privateDelegate;
}

#pragma mark - 工具方法
- (QMUITableView *)tableView {
    if (!_tableView) {
        [self loadViewIfNeeded];
    }
    return _tableView;
}

- (void)hideTableHeaderViewInitialIfCanWithAnimated:(BOOL)animated force:(BOOL)force {
    if (self.tableView.tableHeaderView && [self shouldHideTableHeaderViewInitial] && (force || !self.hasHideTableHeaderViewInitial)) {
        CGPoint contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + CGRectGetHeight(self.tableView.tableHeaderView.frame));
        [self.tableView setContentOffset:contentOffset animated:animated];
        self.hasHideTableHeaderViewInitial = YES;
    }
}

- (void)contentSizeCategoryDidChanged:(NSNotification *)notification {
    [super contentSizeCategoryDidChanged:notification];
    [self.tableView reloadData];
}


#pragma mark - 空列表视图 QMUIEmptyView

- (void)handleTableViewContentInsetChangeEvent {
    if (self.isEmptyViewShowing) {
        [self layoutEmptyView];
    }
}

- (void)showEmptyView {
    if (!self.emptyView) {
        self.emptyView = [[QMUIEmptyView alloc] init];
    }
    [self.tableView addSubview:self.emptyView];
    [self layoutEmptyView];
}

- (void)hideEmptyView {
    [self.emptyView removeFromSuperview];
}

// 注意，emptyView 的布局依赖于 tableView.contentInset，因此我们必须监听 tableView.contentInset 的变化以及时更新 emptyView 的布局
- (BOOL)layoutEmptyView {
    if (!self.emptyView || !self.emptyView.superview) {
        return NO;
    }
    
    UIEdgeInsets insets = self.tableView.contentInset;
    if (@available(iOS 11, *)) {
        if (self.tableView.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
            insets = self.tableView.adjustedContentInset;
        }
    }
    
    // 当存在 tableHeaderView 时，emptyView 的高度为 tableView 的高度减去 headerView 的高度
    if (self.tableView.tableHeaderView) {
        self.emptyView.frame = CGRectMake(0, CGRectGetMaxY(self.tableView.tableHeaderView.frame), CGRectGetWidth(self.tableView.bounds) - UIEdgeInsetsGetHorizontalValue(insets), CGRectGetHeight(self.tableView.bounds) - UIEdgeInsetsGetVerticalValue(insets) - CGRectGetMaxY(self.tableView.tableHeaderView.frame));
    } else {
        self.emptyView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds) - UIEdgeInsetsGetHorizontalValue(insets), CGRectGetHeight(self.tableView.bounds) - UIEdgeInsetsGetVerticalValue(insets));
    }
    return YES;
}


/**
 *  监听 contentInset 的变化以及时更新 emptyView 的布局，详见 layoutEmptyView 方法的注释
 *  该 delegate 方法仅在 iOS 11 及之后存在，之前的 iOS 版本使用 KVO 的方式实现监听，详见 initTableView 方法里的相关代码
 */
- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView {
    if (scrollView != self.tableView) {
        return;
    }
    [self handleTableViewContentInsetChangeEvent];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] init];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end


@implementation MLSBaseTableViewController (SubclassingHooks)

- (void)initTableView {
    if (!_tableView) {
        _tableView = [[MLSBaseTableView alloc] initWithFrame:self.view.bounds style:self.style];
    }
    _tableView.delegate = self.privateDelegate;
    _tableView.dataSource = self;
    if (@available(iOS 11, *)) {
    } else {
        /**
         *  监听 contentInset 的变化以及时更新 emptyView 的布局，详见 layoutEmptyView 方法的注释
         *  iOS 11 及之后使用 UIScrollViewDelegate 的 scrollViewDidChangeAdjustedContentInset: 来监听
         */
        [self.tableView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)layoutTableView {
    BOOL showComment = [self alwaysShowCommentView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0,*)) {
            if (showComment) {
                make.bottom.equalTo(self.commentToolBar.mas_safeAreaLayoutGuideTop);
            } else {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        } else {
            if (showComment) {
                make.bottom.equalTo(self.commentToolBar.mas_top);
            } else {
                make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
            }
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.right.equalTo(self.view);
        }
    }];
}

- (BOOL)shouldHideTableHeaderViewInitial {
    return NO;
}

@end
