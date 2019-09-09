//
//  MLSBaseCollectionViewController.h
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//

#if __has_include(<QMUIKit/QMUIKit.h>)
#import <QMUIKit/QMUIKit.h>
#else
#import "QMUIKit.h"
#endif
#import "MLSBaseCollectionView.h"
#import "MLSBaseViewController.h"
NS_ASSUME_NONNULL_BEGIN
@interface MLSBaseCollectionViewController : MLSBaseViewController <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

/**
 布局信息
 可以重置
 */
@property (strong, nonatomic) UICollectionViewLayout *layout;

/**
 初始化控制器
 
 @param layout 布局信息
 @return 控制器
 */
- (instancetype)initWithCollectionViewLayout:(nullable UICollectionViewLayout *)layout;

/**
 创建flowLayout
 
 @return layout布局
 */
- (UICollectionViewFlowLayout *)createFlowLayout;

/**
 初始化成功
 
 @param layout 布局
 */
- (void)didInitializedWithLayout:(UICollectionViewLayout *)layout;


/**
 获取当前的 collectionView
 */
@property(nonatomic, strong, readonly) IBOutlet MLSBaseCollectionView *collectionView;


@end

@interface MLSBaseCollectionViewController (SubclassingHooks)

/**
 *  初始化tableView，在initSubViews的时候被自动调用。
 *
 *  一般情况下，有关tableView的设置属性的代码都应该写在这里。
 */
- (void)initCollectionView;

@end
NS_ASSUME_NONNULL_END
