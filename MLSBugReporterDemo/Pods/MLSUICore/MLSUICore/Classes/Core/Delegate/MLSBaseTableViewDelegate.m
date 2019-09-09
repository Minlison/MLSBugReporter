//
//  BaseTableViewDelegate.m
//  MinLison
//
//  Created by MinLison on 2017/11/7.
//  Copyright © 2017年 minlison. All rights reserved.
//

#import "MLSBaseTableViewDelegate.h"
const NSInteger kBaseSectionHeaderFooterLabelTag = 1024;

@interface MLSBaseTableViewDelegate ()
@end

@implementation MLSBaseTableViewDelegate

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.receiver respondsToSelector:aSelector]) {
        return self.receiver;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.receiver respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}
- (instancetype)init {
    return [self initWithReceiver:nil];
}
- (instancetype)initWithReceiver:(nullable id<QMUITableViewDelegate>)receiver {
    if (self = [super init]) {
        self.receiver = receiver;
    }
    return self;
}
// 默认拿title来构建一个view然后添加到viewForHeaderInSection里面，如果业务重写了viewForHeaderInSection，则titleForHeaderInSection被覆盖
// viewForFooterInSection同上
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.receiver respondsToSelector:_cmd]) {
        return [self.receiver tableView:tableView viewForHeaderInSection:section];
    }
    NSString *title = [self tableView:tableView realTitleForHeaderInSection:section];
    if (title) {
        UITableViewHeaderFooterView *headerFooterView = [self tableHeaderFooterLabelInTableView:tableView identifier:@"headerTitle"];
        UILabel *label = (UILabel *)[headerFooterView.contentView viewWithTag:kBaseSectionHeaderFooterLabelTag];
        label.text = title;
        label.font = tableView.style == UITableViewStylePlain ? TableViewSectionHeaderFont : TableViewGroupedSectionHeaderFont;
        label.textColor = tableView.style == UITableViewStylePlain ? TableViewSectionHeaderTextColor : TableViewGroupedSectionHeaderTextColor;
        label.backgroundColor = tableView.style == UITableViewStylePlain ? TableViewSectionHeaderBackgroundColor : UIColorClear;
        CGFloat labelLimitWidth = CGRectGetWidth(tableView.bounds) - UIEdgeInsetsGetHorizontalValue(tableView.contentInset);
        CGSize labelSize = [label sizeThatFits:CGSizeMake(labelLimitWidth, CGFLOAT_MAX)];
        UIEdgeInsets contentInset = tableView.style == UITableViewStylePlain ? TableViewSectionFooterContentInset : TableViewGroupedSectionFooterContentInset;;
        label.frame = CGRectMake(contentInset.left, contentInset.top, labelLimitWidth - contentInset.left - contentInset.right, labelSize.height - contentInset.top - contentInset.bottom);
        return label;
    }
    return [self tableHeaderFooterTableView:tableView identifier:@"EmptyHeaderFooter"];
}

// 同viewForHeaderInSection
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.receiver respondsToSelector:_cmd]) {
        return [self.receiver tableView:tableView viewForFooterInSection:section];
    }
    NSString *title = [self tableView:tableView realTitleForFooterInSection:section];
    if (title) {
        UITableViewHeaderFooterView *headerFooterView = [self tableHeaderFooterLabelInTableView:tableView identifier:@"footerTitle"];
        UILabel *label = (UILabel *)[headerFooterView.contentView viewWithTag:kBaseSectionHeaderFooterLabelTag];
        label.text = title;
        //                label.contentEdgeInsets = tableView.style == UITableViewStylePlain ? TableViewSectionFooterContentInset : TableViewGroupedSectionFooterContentInset;
        label.font = tableView.style == UITableViewStylePlain ? TableViewSectionFooterFont : TableViewGroupedSectionFooterFont;
        label.textColor = tableView.style == UITableViewStylePlain ? TableViewSectionFooterTextColor : TableViewGroupedSectionFooterTextColor;
        label.backgroundColor = tableView.style == UITableViewStylePlain ? TableViewSectionFooterBackgroundColor : UIColorClear;
        CGFloat labelLimitWidth = CGRectGetWidth(tableView.bounds) - UIEdgeInsetsGetHorizontalValue(tableView.contentInset);
        CGSize labelSize = [label sizeThatFits:CGSizeMake(labelLimitWidth, CGFLOAT_MAX)];
        UIEdgeInsets contentInset = tableView.style == UITableViewStylePlain ? TableViewSectionFooterContentInset : TableViewGroupedSectionFooterContentInset;;
        label.frame = CGRectMake(contentInset.left, contentInset.top, labelLimitWidth - contentInset.left - contentInset.right, labelSize.height - contentInset.top - contentInset.bottom);
        return label;
    }
    return [self tableHeaderFooterTableView:tableView identifier:@"EmptyHeaderFooter"];
}

- (UITableViewHeaderFooterView *)tableHeaderFooterLabelInTableView:(UITableView *)tableView identifier:(NSString *)identifier {
    
    UITableViewHeaderFooterView *headerFooterView = [self tableHeaderFooterTableView:tableView identifier:identifier];
    UILabel *label = [[UILabel alloc] init];
    label.tag = kBaseSectionHeaderFooterLabelTag;
    label.numberOfLines = 0;
    [headerFooterView.contentView addSubview:label];
    return headerFooterView;
}

- (UITableViewHeaderFooterView *)tableHeaderFooterTableView:(UITableView *)tableView identifier:(NSString *)identifier {
    
    UITableViewHeaderFooterView *headerFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!headerFooterView) {
        headerFooterView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:identifier];
        headerFooterView.contentView.backgroundColor = tableView.backgroundColor;
    }
    return headerFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.receiver respondsToSelector:_cmd]) {
        return [self.receiver tableView:tableView heightForHeaderInSection:section];
    }
    // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
    if (@available(iOS 11, *)) {
        return CGFLOAT_MIN;
    }
    //    return 0.0f;
    return tableView.style == UITableViewStylePlain ? 0.001f : CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.receiver respondsToSelector:_cmd]) {
        return [self.receiver tableView:tableView heightForFooterInSection:section];
    }
    if (@available(iOS 11, *)) {
        return CGFLOAT_MIN;
    }
    //    return 0.0f;
    // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
    return tableView.style == UITableViewStylePlain ? 0.001f : CGFLOAT_MIN;
}

// 是否有定义某个section的header title
- (NSString *)tableView:(UITableView *)tableView realTitleForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        NSString *sectionTitle = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
        if (sectionTitle && sectionTitle.length > 0) {
            return sectionTitle;
        }
    }
    return nil;
}

// 是否有定义某个section的footer title
- (NSString *)tableView:(UITableView *)tableView realTitleForFooterInSection:(NSInteger)section {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        NSString *sectionFooter = [tableView.dataSource tableView:tableView titleForFooterInSection:section];
        if (sectionFooter && sectionFooter.length > 0) {
            return sectionFooter;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.receiver respondsToSelector:_cmd]) {
        return [self.receiver tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([self.receiver respondsToSelector:_cmd]) {
        return [self.receiver tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    return UITableViewAutomaticDimension;
}

#pragma mark - 兼容 MLSPlayer 的Method Hock

- (BOOL)shouldForwardSelector:(SEL)selector {
    struct objc_method_description description;
    description = protocol_getMethodDescription(@protocol(QMUITableViewDelegate), selector, NO, YES);
    return (description.name != NULL && description.types != NULL);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self shouldForwardSelector:@selector(scrollViewDidEndDecelerating:)]) {
        if ([self.receiver respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
            [self.receiver scrollViewDidEndDecelerating:scrollView];
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self shouldForwardSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        if ([self.receiver respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
            [self.receiver scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
        }
    }
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if ([self shouldForwardSelector:@selector(scrollViewDidScrollToTop:)]) {
        if ([self.receiver respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
            [self.receiver scrollViewDidScrollToTop:scrollView];
        }
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self shouldForwardSelector:@selector(scrollViewWillBeginDragging:)]) {
        if ([self.receiver respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
            [self.receiver scrollViewWillBeginDragging:scrollView];
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self shouldForwardSelector:@selector(scrollViewDidScroll:)]) {
        if ([self.receiver respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [self.receiver scrollViewDidScroll:scrollView];
        }
    }
}
@end
