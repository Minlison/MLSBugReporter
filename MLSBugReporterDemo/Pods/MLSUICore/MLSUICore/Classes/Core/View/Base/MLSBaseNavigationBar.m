//
//  MLSBaseNavigationBar.m
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//

#import "MLSBaseNavigationBar.h"
#if __has_include(<QMUIKit/QMUIKit.h>)
#import <QMUIKit/QMUIKit.h>
#else
#import "QMUIKit.h"
#endif
@interface MLSBaseNavigationBar ()
@property(nonatomic, strong) UIImageView *navBackGroundView;
@property(nonatomic, strong) UIImageView *splitLine;
@end
@implementation MLSBaseNavigationBar



- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.frame.size.width, NavigationBarHeight);
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.barStyle    = UIBarStyleDefault;
        
        _splitLine = [[UIImageView alloc] init];
        _splitLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_splitLine];
    }
    
    return self;
}

- (void)setBottomLineColor:(UIColor *)bottomLineColor {
    _splitLine.backgroundColor = bottomLineColor;
}

- (UIColor *)bottomLineColor {
    return _splitLine.backgroundColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _splitLine.frame = CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), 0.5f);
}

- (UIImageView *)navBackGroundView {
    if (_navBackGroundView == nil) {
        _navBackGroundView = [[UIImageView alloc] init];
        _navBackGroundView.contentMode = UIViewContentModeScaleToFill;
    }
    return _navBackGroundView;
}


@end
