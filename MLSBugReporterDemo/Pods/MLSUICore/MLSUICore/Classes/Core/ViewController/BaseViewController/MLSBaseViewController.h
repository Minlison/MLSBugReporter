//
//  MLSBaseViewController.h
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//
#if __has_include(<QMUIKit/QMUIKit.h>)
#import <QMUIKit/QMUIKit.h>
#else
#import "QMUIKit.h"
#endif
#import "MLSBaseControllerCommentProtocol.h"


NS_ASSUME_NONNULL_BEGIN
typedef void (^MLSBaseControllerDismissBlock)(void);

FOUNDATION_EXTERN NSString *MLSViewControllerReloadDataNotifaction;
@interface MLSBaseViewController : QMUICommonViewController

/// MARK: - 视图状态
/**
 是否正在显示
 viewWillAppear YES
 viewDidDisAppear NO
 */
@property(nonatomic, assign, readonly, getter=isInDisplay) BOOL inDisplay;
// 设置是否正在显示中
- (void)setInDisplay:(BOOL)inDisplay;

/**
 是否是第一次显示
 viewDidDisAppear 设置为 NO
 */
@property(nonatomic, assign, readonly, getter=isFirstAppear) BOOL firstAppear;
// 设置是否是第一次显示
- (void)setFirstAppear:(BOOL)firstAppear;

/// MARK: - Loading
/**
 是否正在加载内容
 内部根据 ViewModel 处理,如果没有 ViewModel 则需要自己处理
 Use method - setLoading: animation:
 */
@property(nonatomic, assign, readonly, getter=isLoading) BOOL loading;
- (void)setLoading:(BOOL)loading;


/**
 数据是否加载完毕
 */
@property(nonatomic, assign, readonly, getter=isDataLoaded) BOOL dataLoaded;
- (void)setDataLoaded:(BOOL)dataLoaded;


/**
 最小加载时间（防止加载过快，动画闪屏）
 默认 0.5
 */
@property(nonatomic, assign) NSTimeInterval minLoadingTime;

/**
 导航栏是否穿透

 @return 是否穿透
 */
- (BOOL)navigationBarTranslucent;

/**
 导航栏视图是否不透明

 @return 是否不透明
 */
- (BOOL)navigationBarOpaque;

/**
 导航栏背景色

 @return UIColor
 */
- (UIColor *)navigationBarBackgroundColor;

/**
 配置导航栏属性
 */
- (void)configNavigationBar;

/**
 设置是否正在加载内容
 如果 返回的 viewModel 为空的情况下, 需要主动调用
 @param loading 是否正在加载内容
 @param animation 是否显示动画
 */
- (void)setLoading:(BOOL)loading animation:(BOOL)animation;


/**
 表示加载失败
 设置错误信息
 会 隐藏 loading 视图
 
 @param error 错误信息
 */
- (void)setError:(NSError *)error;

/**
 表示加载失败
 设置错误信息
 会 隐藏 loading 视图
 
 @param error  错误信息
 @param completion 状态设置成功回调
 */
- (void)setError:(NSError *)error completion:(nullable void (^)(void))completion;

/**
 表示加载成功
 会 隐藏 loading 视图
 */
- (void)setSuccess;

/**
 表示加载成功
 会 隐藏 loading 视图
 
 @param completion 状态设置成功回调
 */
- (void)setSuccessCompletion:(nullable void (^)(void))completion;

/// SubClass holder
/**
 重新加载数据
 call -(void)loadDataIgnoreCache:YES loadingAnimation:NO
 */
- (void)reloadData;

/**
 加载数据
 call -(void)loadDataIgnoreCache:NO loadingAnimation:YES
 */
- (void)loadData;

/**
 加载数据
 子类可以重写该方法，上面两个方法可以控制该方法的显示，加载
 @param ignoreCache 是否忽略缓存
 @param animation 是否显示动画
 */
- (void)loadDataIgnoreCache:(BOOL)ignoreCache loadingAnimation:(BOOL)animation;

/// CallBack
/**
 回调，在 被 pop 或者 dismiss 的时候回调 中回调
 */
@property(nonatomic, copy) MLSBaseControllerDismissBlock dismissBlock;

/**
 配置导航栏
 viewWillAppear: should call
 @param navigationBar 导航栏
 */
- (void)configNavigationBar:(__kindof UINavigationBar *)navigationBar;

/**
 控制器视图的 View
 
 @return Class
 */
+ (nullable __kindof UIView *)controllerView;

/**
 配置口空状页
 */
- (void)configEmptyView;

/// MARK: - 控制器标识

/**
 控制器的唯一标识符
 */
@property (nonatomic, copy, readonly) NSString *identifier;
- (void)setIdentifier:(NSString * _Nonnull)identifier;

/**
 友盟统计名称
 */
@property (nonatomic, copy, readonly) NSString *mobclick_name;
- (void)setMobclick_name:(NSString * _Nonnull)mobclick_name;


/**
 正在显示时,允许当前操作流程被打断,被任意ViewController覆盖, 默认为YES
 */
@property (nonatomic, assign) BOOL allowsArbitraryPresenting;

/**
 * 正在显示时,允许当前操作流程被打断,被任意ViewController覆盖,
 * arbitraryPresentingEnabled会受到parentViewController或者
 * presentingViewController影响,只要在显示链中有任意一ViewController
 * 不允许被覆盖,则其子ViewController都不允许被覆盖
 */
@property (nonatomic, assign, readonly) BOOL arbitraryPresentingEnabled;

/**
 是否正在被显示
 通过 view 判断视图，与inDisplay 不同
 */
@property (nonatomic, assign, readonly) BOOL isShowing;


/**
 是否正在弹出别的控制器
 */
@property (assign, nonatomic, readonly) BOOL isPresentingOther;

/**
 是否是被别的控制器弹出
 */
@property (assign, nonatomic, readonly) BOOL isPresentedByOther;

/**
 判断是否是present出来的
 
 @return 判断是否是present出来的
 */
- (BOOL)isPresented;

/**
 是否允许直接退出到tabbar 默认为NO
 */
@property (assign, nonatomic, readonly) BOOL allowChoseToTabbar;

/**
 是否允许 push 控制器
 */
@property (assign, nonatomic, readonly) BOOL allowPushIn;

/**
 是否允许手势返回
 */
@property (assign, nonatomic) BOOL enableGesturePop;


/**
 发送全局 reloadata 的通知
 */
- (void)postReloadDataNotifaction;


/**
 视图控制器的 view Class
 会查询 super，直到最底层 class
 @return Class
 */
- (Class)controllerViewClass;


//// MARK: - 路由中心接口

/**
 在路由中心创建控制器
 
 @param param 路由中心传入参数
 @return 如果参数校验不完整，直接返回 nil , 如果参数校验完整，则返回创建好的控制器
 */
- (instancetype)initWithRouteParam:(NSDictionary *)param;

/**
 类方法，创建控制器
 会调用 - initWithRouteParam: 方法创建
 
 @param parameters 参数
 @return VC
 */
+ (nullable UIViewController *)targetControllerWithParams:(nullable NSDictionary *)parameters;

/**
 路由中心参数
 */
@property (nonatomic, strong) NSDictionary *routeParam;



/**
  退出到导航控制器的根视图
 如果最导航控制器的根视图不是 ControllerClass
 则调用 controllerClass 的 alloc init 方法创建新的视图最为导航控制器的根视图

 @param controllerClass 控制器 Class
 */
- (void)popOrCreateIfNeedToRootControllerWithClass:(Class)controllerClass;
- (void)popOrCreateIfNeedToRootController:(UIViewController *)viewController;

- (void)popOrCreateIfNeedToSecondControllerWithClass:(Class)controllerClass;
- (void)popOrCreateIfNeedToSecondController:(UIViewController *)viewController;
@end

/// MARK: - 评论框
/**
 底部评论视图相关
 */
@interface MLSBaseViewController  (MLSComment) <MLSBaseControllerCommentProtocol,MLSBaseCommentToolBarDelegate,QMUIKeyboardManagerDelegate>

/**
 初始化评论视图
 */
- (void)initCommentView;
@end

typedef NS_OPTIONS(NSUInteger, MLSViewControllerMonitorType) {
    MLSViewControllerMonitorTypeActive = 1 << 1,
    MLSViewControllerMonitorTypeResignActive = 1 << 2,
    MLSViewControllerMonitorTypeActiveOrResign = MLSViewControllerMonitorTypeActive | MLSViewControllerMonitorTypeResignActive,
    MLSViewControllerMonitorTypeEnterBackground = 1 << 3,
    MLSViewControllerMonitorTypeEnterForground = 1 << 4,
    MLSViewControllerMonitorTypeEnterBackgroundOrForground = MLSViewControllerMonitorTypeEnterBackground | MLSViewControllerMonitorTypeEnterForground,
    MLSViewControllerMonitorTypeTerminate = 1 << 5,
    MLSViewControllerMonitorTypeAll = MLSViewControllerMonitorTypeActiveOrResign | MLSViewControllerMonitorTypeEnterBackgroundOrForground | MLSViewControllerMonitorTypeTerminate,
};

@interface MLSBaseViewController (MLSActive)

/**
 注册监听

 @param types | 符号相连接
 */
- (void)startApplicationMonitor:(MLSViewControllerMonitorType)types;
/**
 取消监听
 
 @param types | 符号相连接
 */
- (void)stopApplicationMonitor:(MLSViewControllerMonitorType)types;

// SubClassHolder
/**
 激活
 */
- (void)viewControllerDidBecomeActive;

/**
 将要失去活力
 */
- (void)viewControllerWillResignActive;

/**
 进入前台
 */
- (void)viewControllerDidEnterBackground;

/**
 将要进入后台
 */
- (void)viewControllerWillEnterForeground;

/**
 程序将要推出
 */
- (void)viewControllerWillTerminate;
@end


#if __has_include("QMUIScrollAnimator.h") || __has_include(<QMUIKit/QMUIScrollAnimator.h>)
#define QMUI_ENABLE_SCROLLANIMATOR 1
#endif

#ifdef QMUI_ENABLE_SCROLLANIMATOR
@interface MLSBaseViewController (MLSNavigationBar)

/// 如果需要开启本功能，需要依赖 QMUIKit/QMUIComponents/QMUIScrollAnimator
// 导航栏动画管理
@property (nonatomic, strong, readonly) QMUINavigationBarScrollingAnimator *naviBarAnimator;

@property (nonatomic, assign, readonly) BOOL enableNavigationBarAnimator;

/**
 开启导航栏动画
 
 @param scrollView 监听的scrollView
 @param startOffset 开始动画的 contentOffset.y
 @param distanceOffset 结束动画的 contentOffset.y
 */
- (void)enableAnimatorInScrollView:(UIScrollView *)scrollView startOffset:(CGFloat)startOffset distanceOffset:(CGFloat)distanceOffset;

/**
 关闭导航栏动画
 */
- (void)disableAnimator;

/**
 滚动回调
 
 @param animator animator
 @param progres 进度
 */
- (void)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator didAnimationProgress:(float)progres;

/**
 导航栏是否穿透

 @param animator animator
 @param progres 进度
 @return 是否穿透
 */
- (BOOL)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarTranslucentWithProgress:(float)progres;

/**
 导航栏是否不透明

 @param animator animator
 @param progres 进度
 @return 是否不透明
 */
- (BOOL)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarOpaqueWithProgress:(float)progres;

/**
 导航栏背景图片
 
 @param animator animator
 @param progres 进度
 @return 图片
 */
- (UIImage *)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarBackgroundImageWithProgress:(float)progres;

/**
 导航栏shadow 图片
 
 @param animator animator
 @param progres 进度
 @return 图片
 */
- (UIImage *)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarShadowImageWithProgress:(float)progres;

/**
 导航栏 tintColor
 
 @param animator animator
 @param progres 进度
 @return UIColor
 */
- (UIColor *)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarTintColorWithProgress:(float)progres;

/**
 导航栏 titleView  tintColor
 
 @param animator animator
 @param progres 进度
 @return UIColor
 */
- (UIColor *)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarTitleViewTintColorWithProgress:(float)progres;

/**
 状态栏样式
 
 @param animator animator
 @param progres 进度
 @return UIColor
 */
- (UIStatusBarStyle)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator statusBarStyleWithProgress:(float)progres;

/**
 导航栏Bar tintColor
 
 @param animator animator
 @param progres 进度
 @return UIColor
 */
- (UIColor *)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarBarTintColorWithProgress:(float)progres;

/**
 导航栏背景色

 @param animator animator
 @param progres 进度
 @return UIColor
 */
- (UIColor *)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarBackgroundColorWithProgress:(float)progres;

@end

#endif
NS_ASSUME_NONNULL_END
