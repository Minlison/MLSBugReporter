//
//  BaseTableViewCell.h
//  MinLison
//
//  Created by MinLison on 2017/10/27.
//  Copyright © 2017年 minlison. All rights reserved.
//

#if __has_include(<QMUIKit/QMUIKit.h>)
#import <QMUIKit/QMUIKit.h>
#else
#import "QMUIKit.h"
#endif
/**
 // Do nothing
 */
@interface MLSBaseTableViewCell : QMUITableViewCell
/**
 当前 cell 的索引位置
 */
@property(nonatomic, strong) NSIndexPath *indexPath;
/**
 配置视图
 */
- (void)setupView NS_REQUIRES_SUPER;

/**
 更新内容
 */
- (void)updateContent;
@end
