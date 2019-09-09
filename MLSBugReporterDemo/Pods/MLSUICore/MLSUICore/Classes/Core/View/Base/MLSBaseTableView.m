//
//  MLSBaseTableView.m
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//

#import "MLSBaseTableView.h"
@interface UIView (MLSSameBounds)
- (UIView *)sameBoundsSubView;
@end

@interface MLSBaseTableView ()
@end

@implementation MLSBaseTableView
@synthesize autoAdjustView = _autoAdjustView;
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self _didInitialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _didInitialized];
    }
    return self;
}
- (void)_didInitialized {
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.estimatedSectionFooterHeight = 44;
    self.estimatedSectionHeaderHeight = 44;
    self.estimatedRowHeight = 44;
    self.backgroundColor = UIColorWhite;
    [self addObserver:self forKeyPath:@"contentOffset" options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"] && object == self) {
        [self adjustHeaderView];
    }
}

- (void)adjustHeaderView {
    if (!self.enableAutoAdjustHeader || !self.autoAdjustView) {
        return;
    }
    CGFloat y = self.contentOffset.y;
    
    if (y <= 0) {
        CGFloat height = CGRectGetHeight(self.tableHeaderView.bounds);
        CGFloat scale = 1 - y / height;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 0.50000 * y);
        transform = CGAffineTransformScale(transform, scale, scale);
        self.autoAdjustView.transform = transform;
    }
    else {
        self.autoAdjustView.transform = CGAffineTransformIdentity;
    }
}
- (void)setAutoAdjustView:(UIView *)autoAdjustView {
    _autoAdjustView = autoAdjustView;
    self.enableAutoAdjustHeader = (autoAdjustView != nil);
}
- (UIView *)autoAdjustView {
    if (!_autoAdjustView) {
        _autoAdjustView = [self.tableHeaderView sameBoundsSubView];
    }
    return _autoAdjustView;
}
- (UIImage *)getTableFullSnapimage {
    UIImage *snipImage = nil;
    UITableView *scrollView = self;
    CGPoint savedContentOffset = scrollView.contentOffset;
    CGRect savedFrame = scrollView.frame;
    
    scrollView.contentOffset = CGPointZero;
    scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
    
    snipImage = [self snapshotImageAfterScreenUpdates:YES];
    scrollView.contentOffset = savedContentOffset;
    scrollView.frame = savedFrame;
    
    return snipImage;
}

- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates {
    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        return [self snapshotImage];
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterUpdates];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentOffset"];
}
@end


@implementation UIView (MLSSameBounds)
- (UIView *)sameBoundsSubView {
    __block UIView *view = nil;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectEqualToRect(obj.bounds, self.bounds)) {
            view = obj;
            *stop = YES;
        }
    }];
    return view;
}
@end
