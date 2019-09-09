//
//  BaseTableViewCell.m
//  MinLison
//
//  Created by MinLison on 2017/10/27.
//  Copyright © 2017年 minlison. All rights reserved.
//

#import "MLSBaseTableViewCell.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
@interface MLSBaseTableViewCell ()
@property (nonatomic, strong) UIView *privateContentView;
@end
@implementation MLSBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.clipsToBounds = YES;
        self.clipsToBounds = YES;
        self.privateContentView = [[UIView alloc] init];
        [self.contentView addSubview:self.privateContentView];
        self.privateContentView.backgroundColor = [UIColor clearColor];
        [self.privateContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
}
- (void)updateContent {
}
@end
