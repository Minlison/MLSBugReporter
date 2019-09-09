//
//  MLSTipLittleLoadingView.m
//  MLSUICore
//
//  Created by minlison on 2018/7/6.
//
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#import "MLSTipLittleLoadingView.h"
#import "MLSUICore.h"
@interface MLSTipLittleLoadingView ()
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *iconImgView;
@end
@implementation MLSTipLittleLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setSuccess:(BOOL)success {
    _success = success;
    self.iconImgView.hidden = !success;
    self.indicator.hidden = success;
    success ? [self stopIndicator] : [self.indicator startAnimating];
}

- (void)setTitle:(NSString *)title {
    _title = title.copy;
    self.textLabel.text = title;
}

+ (instancetype)tipLittlLoadingViewWithTitle:(NSString *)title success:(BOOL)success {
    MLSTipLittleLoadingView *view = [[MLSTipLittleLoadingView alloc] init];
    view.title = title;
    view.success = success;
    return view;
}

- (void)stopIndicator {
    [self.indicator stopAnimating];
//    [self.indicator removeFromSuperview];
}

- (void)setupView {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.indicator = indicator;
    self.indicator.hidden = self.success;;
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = [UIFont systemFontOfSize:16];
    self.textLabel.text = self.title;
    
    self.iconImgView = [[UIImageView alloc] initWithImage:MLSUICoreBuldleImage(@"content_button_success")];
    self.iconImgView.hidden = !self.success;
    
    [self addSubview:self.textLabel];
    [self addSubview:self.indicator];
    [self addSubview:self.iconImgView];
    
    [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).mas_offset(__MLSWidth(0));
        make.left.equalTo(self).mas_offset(__MLSWidth(0));
        make.bottom.equalTo(self).mas_offset(-__MLSWidth(0));
    }];
    
    [@[self.indicator,self.iconImgView] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textLabel.mas_right).offset(__MLSWidth(8));
        make.centerY.equalTo(self.textLabel.mas_centerY);
        make.right.equalTo(self).mas_offset(-__MLSWidth(0));
        make.width.height.mas_equalTo(__MLSWidth(14));
    }];
    
    
    self.success ? [self stopIndicator] : [indicator startAnimating];
}


@end
