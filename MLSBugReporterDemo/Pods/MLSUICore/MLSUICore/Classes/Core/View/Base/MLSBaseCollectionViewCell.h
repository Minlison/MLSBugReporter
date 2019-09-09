//
//  MLSBaseCollectionViewCell.h
//  MLSUICore
//
//  Created by minlison on 2018/6/8.
//

#import <UIKit/UIKit.h>

@interface MLSBaseCollectionViewCell : UICollectionViewCell
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

/**
 获取最大值
 会出去collectionView的inset
 flowLayout的 sectionInset
 
 @return 最大值
 */
+ (CGSize)getMaxSizeInCollectionView:(UICollectionView *)collectionView inSection:(NSInteger)section;

/**
 获取最小行间距
 
 @param collectionView collectionview
 @param section section
 @return 最小行间距
 */
+ (CGFloat)getMinLineSpacingMarginInCollectionView:(UICollectionView *)collectionView inSection:(NSInteger)section;

/**
 获取最小item间距
 
 @param collectionView collectionView description
 @param section section description
 @return 最小item间距
 */
+ (CGFloat)getMinItemMarginInCollectionView:(UICollectionView *)collectionView inSection:(NSInteger)section;

/**
 是否允许自动计算高度
 
 @return 是否允许自动计算高度
 */
- (BOOL)needAutoHeight;
@end
