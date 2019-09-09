//
//  MLSBaseCollectionViewController.m
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//

#import "MLSBaseCollectionViewController.h"
#import "MLSBaseCollectionViewCell.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
@interface MLSBaseCollectionViewController ()
@property(nonatomic, strong, readwrite) IBOutlet MLSBaseCollectionView *collectionView;
@end

@implementation MLSBaseCollectionViewController

- (instancetype)initWithRouteParam:(NSDictionary *)param {
    if (self = [self init]) {
        self.routeParam = param;
        [self didInitializedWithLayout:[self createFlowLayout]];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithCollectionViewLayout:nil];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitializedWithLayout:[self createFlowLayout]];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self didInitializedWithLayout:layout ?:[self createFlowLayout]];
    }
    return self;
}
- (UICollectionViewFlowLayout *)createFlowLayout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(80, 80);
    flowLayout.minimumLineSpacing = 8;
    flowLayout.minimumInteritemSpacing = 8;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.headerReferenceSize = CGSizeZero;
    flowLayout.footerReferenceSize = CGSizeZero;
    self.layout = flowLayout;
    return flowLayout;
}
- (void)didInitializedWithLayout:(UICollectionViewLayout *)layout {
    self.layout = layout;
}

- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    if (@available(iOS 11.0, *)) {
    } else {
        [_collectionView removeObserver:self forKeyPath:@"contentInset"];
    }
}


- (NSString *)description {
#ifdef DEBUG
    if (![self isViewLoaded]) {
        return [super description];
    }
    
    NSString *result = [NSString stringWithFormat:@"%@\ncollectionView:\t\t\t\t%@", [super description], self.collectionView];
    if ([self.collectionView.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        NSInteger sections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
        if (sections > 0) {
            NSMutableString *sectionCountString = [[NSMutableString alloc] init];
            [sectionCountString appendFormat:@"\ndataCount(%@):\t\t\t\t(\n", @(sections)];
            NSInteger sections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
            for (NSInteger i = 0; i < sections; i++) {
                NSInteger rows = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:i];
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
}

- (void)initSubviews {
    [super initSubviews];
    [self initCollectionView];
    [self layoutCollectionView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutEmptyView];
}
- (void)layoutCollectionView {
    BOOL showComment = [self alwaysShowCommentView];
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
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
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context  {
    if (object == self && [keyPath isEqualToString:@"contentInset"]) {
        [self handleCollectionViewContentInsetChangeEvent];
    }
}

#pragma mark - 工具方法
- (MLSBaseCollectionView *)collectionView {
    if (!_collectionView) {
        [self loadViewIfNeeded];
    }
    return _collectionView;
}

- (void)contentSizeCategoryDidChanged:(NSNotification *)notification {
    [super contentSizeCategoryDidChanged:notification];
    [self.collectionView reloadData];
}



#pragma mark - 空列表视图 QMUIEmptyView

- (void)handleCollectionViewContentInsetChangeEvent {
    if (self.isEmptyViewShowing) {
        [self layoutEmptyView];
    }
}

- (void)showEmptyView {
    if (!self.emptyView) {
        self.emptyView = [[QMUIEmptyView alloc] init];
    }
    [self.collectionView addSubview:self.emptyView];
    [self layoutEmptyView];
}

- (void)hideEmptyView {
    [self.emptyView removeFromSuperview];
}

// 注意，emptyView 的布局依赖于 collectionView.contentInset，因此我们必须监听 collectionView.contentInset 的变化以及时更新 emptyView 的布局
- (BOOL)layoutEmptyView {
    if (!self.emptyView || !self.emptyView.superview) {
        return NO;
    }
    
    UIEdgeInsets insets = self.collectionView.contentInset;
    if (@available(iOS 11, *)) {
        if (self.collectionView.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
            insets = self.collectionView.adjustedContentInset;
        }
    }
    
    self.emptyView.frame = CGRectMake(0, 0, CGRectGetWidth(self.collectionView.bounds) - UIEdgeInsetsGetHorizontalValue(insets), CGRectGetHeight(self.collectionView.bounds) - UIEdgeInsetsGetVerticalValue(insets));
    return YES;
}


/**
 *  监听 contentInset 的变化以及时更新 emptyView 的布局，详见 layoutEmptyView 方法的注释
 *  该 delegate 方法仅在 iOS 11 及之后存在，之前的 iOS 版本使用 KVO 的方式实现监听，详见 initTableView 方法里的相关代码
 */
- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    [self handleCollectionViewContentInsetChangeEvent];
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [[UICollectionViewCell alloc] init];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

@end

@implementation MLSBaseCollectionViewController (SubclassingHooks)
- (void)initCollectionView {
    if (!_collectionView) {
        _collectionView = [[MLSBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.backgroundColor = self.view.backgroundColor;
        
        if (@available(iOS 11, *)) {
        } else {
            /**
             *  监听 contentInset 的变化以及时更新 emptyView 的布局，详见 layoutEmptyView 方法的注释
             *  iOS 11 及之后使用 UIScrollViewDelegate 的 scrollViewDidChangeAdjustedContentInset: 来监听
             */
            [self.collectionView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
        }
    }
}
@end
