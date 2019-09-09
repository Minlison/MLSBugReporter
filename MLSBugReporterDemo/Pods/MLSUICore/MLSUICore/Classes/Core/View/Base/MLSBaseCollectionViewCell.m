//
//  MLSBaseCollectionViewCell.m
//  MLSUICore
//
//  Created by minlison on 2018/6/8.
//

#import "MLSBaseCollectionViewCell.h"

@implementation MLSBaseCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.clipsToBounds = YES;
        self.clipsToBounds = YES;
        self.contentView.backgroundColor = self.backgroundColor ?:[UIColor whiteColor];
        [self setupView];
    }
    return self;
}
+ (CGFloat)getMinLineSpacingMarginInCollectionView:(UICollectionView *)collectionView inSection:(NSInteger)section {
    UICollectionViewFlowLayout *flowLayout = nil;
    CGFloat minLineSpacing = 0;
    if ([collectionView.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
        minLineSpacing = flowLayout.minimumLineSpacing;
        if ([collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
            minLineSpacing = [(id <UICollectionViewDelegateFlowLayout>)collectionView.delegate collectionView:collectionView layout:flowLayout minimumLineSpacingForSectionAtIndex:section];
        }
    }
    return minLineSpacing;
}


+ (CGFloat)getMinItemMarginInCollectionView:(UICollectionView *)collectionView inSection:(NSInteger)section {
    UICollectionViewFlowLayout *flowLayout = nil;
    CGFloat minInterItemSpacing = 0;
    if ([collectionView.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
        minInterItemSpacing = flowLayout.minimumInteritemSpacing;
        if ([collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
            minInterItemSpacing = [(id <UICollectionViewDelegateFlowLayout>)collectionView.delegate collectionView:collectionView layout:flowLayout minimumInteritemSpacingForSectionAtIndex:section];
        }
    }
    return minInterItemSpacing;
}

+ (CGSize)getMaxSizeInCollectionView:(UICollectionView *)collectionView inSection:(NSInteger)section {
    UICollectionViewFlowLayout *flowLayout = nil;
    UIEdgeInsets sectionInset = UIEdgeInsetsZero;
    if ([collectionView.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
        sectionInset = flowLayout.sectionInset;
        if ([collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)])
        {
            sectionInset = [(id <UICollectionViewDelegateFlowLayout>)collectionView.delegate collectionView:collectionView layout:flowLayout insetForSectionAtIndex:section];
        }
    }
    CGFloat height = CGRectGetHeight(collectionView.bounds) - collectionView.contentInset.top - collectionView.contentInset.bottom;
    CGFloat width = CGRectGetWidth(collectionView.bounds) - collectionView.contentInset.left - collectionView.contentInset.right;
    if (flowLayout) {
        height = height - sectionInset.top - sectionInset.bottom;
        width = width - sectionInset.left - sectionInset.right;
    }
    return CGSizeMake(width-1, height);
    
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    if (![self needAutoHeight]) {
        return layoutAttributes;
    }
    [self setNeedsLayout];
    
    [self layoutIfNeeded];
    
    CGSize size = [self.contentView systemLayoutSizeFittingSize:layoutAttributes.size];
    
    CGRect cellFrame = layoutAttributes.frame;
    
    cellFrame.size.height = size.height;
    
    layoutAttributes.frame = cellFrame;
    
    return layoutAttributes;
}

- (CGSize)getMaxSizeInCollectionView:(UICollectionView *)collectionView inSection:(NSInteger)section {
    return [[self class] getMaxSizeInCollectionView:collectionView inSection:section];
}

- (void)setupView {
    // Do nothing subclass hold
}

- (BOOL)needAutoHeight {
    return NO;
}

- (void)updateContent {
    // Do nothing subclass hold
}
@end
