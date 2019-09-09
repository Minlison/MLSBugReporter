//
//  MLSBaseViewController.m
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//

#import "MLSBaseViewController.h"
#import "MLSConfigurationDefine.h"
#import "MLSFontUtils.h"
#import "MLSCoBaseUtils.h"
#import "MLSTipClass.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
@interface MLSBaseViewController ()
@property(nonatomic, assign, readwrite, getter=isLoading) BOOL loading;
@property(nonatomic, assign, readwrite, getter=isFirstAppear) BOOL firstAppear;
@property(nonatomic, assign) NSTimeInterval lastLoadingTimeInterval;
@property(nonatomic, strong, readwrite) UIView <MLSBaseCommentToolBarProtocol> *commentToolBar;
@property(nonatomic, strong) UIControl *maskControl;
@property(nonatomic, strong) QMUIKeyboardManager *keyboardManager;
@property(nonatomic, assign, readwrite, getter=isDataLoaded) BOOL dataLoaded;
@property (nonatomic, copy, readwrite) NSString *mobclick_name;
@property (nonatomic, copy, readwrite) NSString *identifier;
@property(nonatomic, assign, readwrite, getter=isInDisplay) BOOL inDisplay;
@end

@implementation MLSBaseViewController
@synthesize inDisplay = _inDisplay;
@synthesize minLoadingTime = _minLoadingTime;
@synthesize routeParam = _routeParam;

/// MARK: - Life cycle begin
- (instancetype)initWithRouteParam:(NSDictionary *)param {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.routeParam = param;
    }
    return self;
}

- (void)didInitialize {
    [super didInitialize];
    if ([self respondsToSelector:@selector(setTransitioningDelegate:)]) {
        self.allowsArbitraryPresenting = YES;
    }
    self.firstAppear = YES;
    
    self.minLoadingTime = 0.1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MLSViewControllerReloadDataNotifaction object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)loadView {
    UIView * _controllerView = [self loadCustomControllerView];
    if (_controllerView) {
        self.view = _controllerView;
    } else {
        [super loadView];
    }
}

- (UIView *)loadCustomControllerView {
    UIView * _controllerView = [[self class] controllerView];
    if (!_controllerView) {
        UIView *view = nil;
        /// Storyboard
        if (self.nibName != nil ) {
            [super loadView];
            _controllerView = (UIView *)self.view;
            return _controllerView;
        }
        /// xib
        NSString *nibPath = [[NSBundle mainBundle] pathForResource:NSStringFromClass(self.class) ofType:@"nib"];
        if (nibPath != nil) {
            _controllerView = [[UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil] instantiateWithOwner:self options:nil].firstObject;
            return _controllerView;
        }
        /// __ViewClass
        Class controllerViewClass = [self controllerViewClass];
        if (!view && controllerViewClass != nil) {
            view = [(UIView *) [controllerViewClass alloc] initWithFrame:[UIScreen mainScreen].bounds];
            _controllerView = (UIView *)view;
        }
    }
    return _controllerView;
}

- (Class)controllerViewClass {
    NSString *controllerClassString = NSStringFromClass([self class]);
    if (![controllerClassString containsString:@"Controller"]) {
        return nil;
    }
    NSString *viewClassName  = [controllerClassString stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
    Class    viewClass       = NSClassFromString(viewClassName);
    if ([viewClass isKindOfClass:UIView.class]) {
        return nil;
    }
    return viewClass;
}

+ (__kindof UIView * _Nullable)controllerView {
    return nil;
}

- (void)initSubviews {
    [super initSubviews];
    [self configEmptyView];
    [self initCommentView];
    self.view.clipsToBounds = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = UIColorForBackground;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNavigationBar];
    [QMUIHelper rotateToDeviceOrientation:(UIDeviceOrientationPortrait)];
}
- (void)applicationWillResignActive {
    if (self.isFirstAppear) {
        self.firstAppear = NO;
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configNavigationBar:self.navigationController.navigationBar];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isFirstAppear) {
        self.firstAppear = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view bringSubviewToFront:self.maskControl];
    
    [self.view bringSubviewToFront:self.commentToolBar];
    if ( self.emptyView && ![self commentForceLayoutBringToTop] ) {
        [self.view bringSubviewToFront:self.emptyView];
    }
    [self.emptyView setNeedsLayout];
    [self.emptyView layoutIfNeeded];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _inDisplay = YES;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _inDisplay = NO;
}
- (UIColor *)titleViewTintColor {
    return QMUICMI.blackColor;
}

- (UIColor *)navigationBarBackgroundColor {
    return UIColor.clearColor;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}


/// MARK: - Life cycle end

/// MARK: - navigation bar
- (void)configNavigationBar:(__kindof UINavigationBar *)navigationBar {
    
}

- (BOOL)shouldHoldBackButtonEvent {
    return NO;
}

/// MARK: - Empty View

- (void)configEmptyView {
    self.emptyView = [[QMUIEmptyView alloc] initWithFrame:self.view.bounds];
    [self configEmptyActionButton];
    self.emptyView.imageViewInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.emptyView.actionButtonInsets = UIEdgeInsetsMake(__MLSHeight(38), 0, 0, 0);
    self.emptyView.contentView.backgroundColor =  [UIColor whiteColor];
    self.emptyView.backgroundColor = [UIColor whiteColor];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    activityView.hidesWhenStopped = YES;
    self.emptyView.loadingView = (UIView <QMUIEmptyViewLoadingViewProtocol> *)activityView;
}

- (void)configEmptyActionButton {
    UIImage *actionBtnBackgroundImg = MLSUICoreBuldleImage(@"reload_button");
    self.emptyView.actionButton.layer.cornerRadius = __MLSHeight(20);
    self.emptyView.actionButton.clipsToBounds = YES;
    self.emptyView.actionButton.backgroundColor = [UIColor whiteColor];
    self.emptyView.actionButton.titleLabel.font = MLSSystem16Font;
    self.emptyView.actionButton.adjustsImageWhenHighlighted = NO;
    [self.emptyView setActionButtonTitleColor:UIColorHex(0xFFFFFF)];
    [self.emptyView setActionButtonFont:MLSSystem14Font];
    [self.emptyView setActionButtonTitle:@"重试"];
    [self.emptyView.actionButton setBackgroundImage:actionBtnBackgroundImg forState:(UIControlStateNormal)];
    
    [self.emptyView setTextLabelTextColor:UIColorHex(0x999999)];
    [self.emptyView setTextLabelFont:MLSSystem14Font];
}
/// Subclass Call Method
- (void)setLoading:(BOOL)loading animation:(BOOL)animation {
    if (!self.emptyView) {
        [self configEmptyView];
    }
    if (self.loading == loading) {
        return;
    }
    self.loading = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setLoading:animation:) object:nil];
    self.lastLoadingTimeInterval = [[NSDate date] timeIntervalSince1970];
    self.loading = loading;
    if (loading) {
        animation ? [self showEmptyViewWithLoading] : [self showEmptyViewWithLoading:NO image:nil text:nil detailText:nil buttonTitle:nil buttonAction:nil];
    } else {
        [self setSuccess];
    }
}
- (void)setError:(NSError *)error {
    [self setError:error completion:nil];
}
- (void)setError:(NSError *)error completion:(void (^)(void))completion {
    self.dataLoaded = YES;
    self.loading = NO;
    self.lastLoadingTimeInterval = [[NSDate date] timeIntervalSince1970];
    [self configEmptyActionButton];
    NSString *errorDes = error.localizedDescription?:@"你的网络好像不太给力，请稍后再试";
    [self showEmptyViewWithLoading:NO image:MLSUICoreBuldleImage(@"empty_img") text:errorDes detailText:nil buttonTitle:@"重试" buttonAction:@selector(loadData)];
    if (completion) {
        completion();
    }
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.tintColor = self.navigationBarTintColor;
    
}
- (void)setSuccess {
    __weak __typeof(self)weakSelf = self;
    [self setSuccessCompletion:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf configNavigationBar];
    }];
}
- (void)setSuccessCompletion:(void (^)(void))completion {
    self.dataLoaded = YES;
    self.loading = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setSuccess) object:nil];
    NSTimeInterval subTimeInterval = [[NSDate date] timeIntervalSince1970] - self.lastLoadingTimeInterval;
    if (subTimeInterval < self.minLoadingTime) {
        __weak __typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((self.minLoadingTime - subTimeInterval + 0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf setSuccessCompletion:completion];
        });
    }
    else {
        self.lastLoadingTimeInterval = [[NSDate date] timeIntervalSince1970];
        [self hideEmptyView];
        if (completion) {
            completion();
        }
        [self setNeedsStatusBarAppearanceUpdate];
        self.navigationController.navigationBar.tintColor = self.navigationBarTintColor;
    }
}
/// Subclass Holder
- (void)loadData {
    if (self.isLoading) {
        return;
    }
    self.dataLoaded = NO;
    [self loadDataIgnoreCache:NO loadingAnimation:YES];
}
- (void)reloadData {
    if (self.isLoading) {
        return;
    }
    self.dataLoaded = NO;
    [self loadDataIgnoreCache:YES loadingAnimation:NO];
}
- (void)loadDataIgnoreCache:(BOOL)ignoreCache loadingAnimation:(BOOL)animation {
    
}
- (void)willPopInNavigationControllerWithAnimated:(BOOL)animated {
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

- (void)configNavigationBar {
    [self setNeedsStatusBarAppearanceUpdate];
    if ([self respondsToSelector:@selector(navigationBarTintColor)]) {
        self.navigationController.navigationBar.tintColor = self.navigationBarTintColor;
    }
    if ([self respondsToSelector:@selector(titleViewTintColor)]) {
        self.titleView.tintColor = [self titleViewTintColor];
    }
    if ([self respondsToSelector:@selector(navigationBarBackgroundImage)]) {
        [self.navigationController.navigationBar setBackgroundImage:[self navigationBarBackgroundImage] forBarMetrics:(UIBarMetricsDefault)];
    }
    if ([self respondsToSelector:@selector(navigationBarShadowImage)]) {
        self.navigationController.navigationBar.shadowImage = [self navigationBarShadowImage];
    }
    if ([self respondsToSelector:@selector(navigationBarTranslucent)]) {
        [self.navigationController.navigationBar setTranslucent:[self navigationBarTranslucent]];
    }
    if ([self respondsToSelector:@selector(navigationBarOpaque)]) {
        self.navigationController.navigationBar.opaque = [self navigationBarOpaque];
    }
    if ([self respondsToSelector:@selector(navigationBarBackgroundColor)]) {
        self.navigationController.navigationBar.backgroundColor = [self navigationBarBackgroundColor];
    }
    BOOL offsetDisable = self.navigationController.navigationBar.translucent || self.navigationController.navigationBar.isHidden;
    self.emptyView.verticalOffset = offsetDisable ? 0 :  -NavigationBarHeight;
}

- (UIImage *)navigationBarBackgroundImage {
    return [UIImage qmui_imageWithColor:QMUICMI.whiteColor];
}
- (UIImage *)navigationBarShadowImage {
    return [UIImage qmui_imageWithColor:[UIColor colorWithWhite:0 alpha:0.1] size:CGSizeMake([UIScreen mainScreen].bounds.size.width, 1) cornerRadius:0];
}
- (UIColor *)navigationBarTintColor {
    return QMUICMI.blackColor;
}

- (BOOL)navigationBarTranslucent {
    return NO;
}

- (BOOL)navigationBarOpaque {
    return NO;
}

- (BOOL)preferredNavigationBarHidden {
    return NO;
}

- (BOOL)shouldCustomizeNavigationBarTransitionIfHideable {
    return YES;
}

- (void)postReloadDataNotifaction {
    NSNotification *noti = [[NSNotification alloc] initWithName:MLSViewControllerReloadDataNotifaction object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:noti];
}
- (void)popOrCreateIfNeedToRootControllerWithClass:(Class)controllerClass {
    if (controllerClass == nil) {
        return;
    }
    if ([self.navigationController.viewControllers.firstObject isKindOfClass:controllerClass]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController setViewControllers:@[[[controllerClass alloc] init]] animated:YES];
    }
}

- (void)popOrCreateIfNeedToRootController:(UIViewController *)viewController {
    if (viewController == nil) {
        return;
    }
    if ([self.navigationController.viewControllers.firstObject isKindOfClass:viewController.class]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController setViewControllers:@[viewController] animated:YES];
    }
}

- (void)popOrCreateIfNeedToSecondControllerWithClass:(Class)controllerClass {
    if (controllerClass == nil) {
        return;
    }
    if ([self.navigationController.viewControllers.firstObject isKindOfClass:controllerClass]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController setViewControllers:@[self.navigationController.viewControllers.firstObject,[[controllerClass alloc] init]] animated:YES];
    }
}
- (void)popOrCreateIfNeedToSecondController:(UIViewController *)viewController {
    if (viewController == nil) {
        return;
    }
    if ([self.navigationController.viewControllers.firstObject isKindOfClass:viewController.class]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        NSMutableArray <UIViewController *>* controllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [controllers removeLastObject];
        [controllers addObject:viewController];
        [self.navigationController setViewControllers:controllers animated:YES];
    }
}

#if MLS_USE_CONTROLLER_TRANSITION
+ (MLSControllerAnimationType)transitionAnimationType {
    return MLSControllerAnimationTypeNone;
}
+ (MLSControllerInteractionType)interactionType {
    return MLSControllerInteractionTypeNone;
}
#endif

/// 路由
+ (nullable UIViewController *)targetControllerWithParams:(nullable NSDictionary *)parameters {
    return [[self alloc] initWithRouteParam:parameters];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MLSViewControllerReloadDataNotifaction object:nil];
#if DEBUG
//    [MLSTipClass showText:[NSString stringWithFormat:@"%@ - dealloc",NSStringFromClass(self.class)]];
    NSLog(@"%@",[NSString stringWithFormat:@"%@ - dealloc",NSStringFromClass(self.class)]);
#endif
}
- (BOOL)isPresented {
    return self.presentingViewController.presentedViewController == self
    || self.navigationController.presentingViewController.presentedViewController == self.navigationController
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

- (NSString *)mobclick_name {
    if (!_mobclick_name) {
        _mobclick_name = [[NSStringFromClass([self class]) stringByReplacingOccurrencesOfString:@"MLS" withString:@""] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
    }
    return _mobclick_name;
}
- (NSString *)identifier {
    if (!_identifier) {
        _identifier = [NSString stringWithFormat:@"%@",[self class]];
    }
    return _identifier;
}

- (BOOL)allowPushIn {
    if ([self isKindOfClass:[UINavigationController class]]) {
        return YES;
    }
    return self.navigationController != nil && self.allowsArbitraryPresenting;
}

- (BOOL)allowChoseToTabbar {
    if ([self isKindOfClass:[UITabBarController class]]) {
        return YES;
    }
    
    if ([self.parentViewController isKindOfClass:[UITabBarController class]]) {
        return YES;
    }
    
    if ([self isKindOfClass:[UINavigationController class]] && [self.parentViewController isKindOfClass:[UITabBarController class]] && [(UINavigationController *)self viewControllers].count == 1) {
        return YES;
    }
    // 普通控制器
    if (self.navigationController != nil && self.navigationController.viewControllers.count == 1 && [self.navigationController.parentViewController isKindOfClass:[UITabBarController class]]) {
        return YES;
    }
    return NO;
}
- ( BOOL )allowsArbitraryPresenting {
    // 没设置过的默认为YES
    return self.allowsArbitraryPresenting;
}

- ( BOOL )arbitraryPresentingEnabled {
    BOOL             result          = self.allowsArbitraryPresenting;
    UIViewController *viewController = self;
    
    // 如果有任意一级不能被打断,则返回 NO
    while ( result ) {
        if ( viewController.parentViewController ) {
            viewController = viewController.parentViewController;
        } else if ( viewController.presentingViewController ) {
            viewController = viewController.presentingViewController;
        } else {
            return YES;
        }
        if ([viewController isKindOfClass:MLSBaseViewController.class]) {
            result = [(MLSBaseViewController *)viewController allowsArbitraryPresenting];
        }
    }
    return result;
}
- (BOOL)isPresentingOther {
    return self.presentedViewController != nil;
}
- (BOOL)isPresentedByOther {
    return self.presentingViewController != nil;
}
- ( BOOL )isShowing {
    UIView *view = self.view;
    
    while ( view && ( view.superview.subviews.lastObject == view || ![self __hasFullScreenViewAboveView:view] ) ) {
        view = view.superview;
        
        if ( [view isKindOfClass:[UIWindow class]] && view == [UIApplication sharedApplication].keyWindow ) {
            return YES;
        }
    }
    
    return NO;
}
// 如果有全屏的View
- ( BOOL )__hasFullScreenViewAboveView:(UIView *)view {
    __block BOOL result = NO;
    
    [view.superview.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:
     ^(UIView *obj, NSUInteger idx, BOOL *stop) {
         if ( obj != view ) {
             //  需要判断这个View是否是响应者，或者视图是否可见
             if ( CGRectEqualToRect( CGRectIntersection( obj.frame, [UIScreen mainScreen].bounds ), [UIScreen mainScreen].bounds ) && obj.isUserInteractionEnabled && obj.alpha != 0 ) {
                 *stop = result = YES;
                 return;
             }
         } else {
             *stop = YES;
             return;
         }
     }];
    
    return result;
}

@end


@implementation MLSBaseViewController (Comment)
- (void)initCommentView {
    self.commentToolBar = [self getCommentView];
//    MLSBaseCommentToolBarType type = [self commentToolBarType];
//    BOOL hasEmotion = (type == MLSBaseCommentToolBarTypeEmotion || type == MLSBaseCommentToolBarTypeEmotionAutoHeight);

    if (!self.commentToolBar) {
        return;
    }

    self.commentToolBar.delegate = self;
    [self.commentToolBar setPlaceHolder:[self placeHolderString]];
    [self.commentToolBar setPlaceHolder:[self placeHolderAttributeString]];
    __weak __typeof(self)weakSelf = self;
    [self.commentToolBar setToolBarActionBlock:^(MLSBaseCommentToolBarActionType type, id<MLSBaseCommentToolBarProtocol> tooBar) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (type == MLSBaseCommentToolBarActionTypeShowEmotion)
        {
            [strongSelf showEmotionView];
        } else if (type == MLSBaseCommentToolBarActionTypeHideEmotion)
        {
            [strongSelf.commentToolBar.realTextView becomeFirstResponder];
        } else if (type == MLSBaseCommentToolBarActionTypeSend)
        {
            [strongSelf commentViewSendButtonDidClick:strongSelf.commentToolBar hideBlock:^(BOOL hide) {
                if (hide) {
                    [strongSelf hide];
                }
            } cleanTextBlock:^(BOOL clean) {
                if (clean) {
                    strongSelf.commentToolBar.text = nil;
                }
            }];
        } else if (type == MLSBaseCommentToolBarActionTypeTextNotValid)
        {
            [MLSTipClass showText:@"输入文字格式不合法" inView:strongSelf.view];
        }
    }];
    
    self.maskControl = [[UIControl alloc] init];
    self.maskControl.backgroundColor = UIColorMask;
    self.maskControl.alpha = 0;
#if MLS_ENABLE_EMOTION_INPUT
    if (hasEmotion) {
        self.qqEmotionManager = [[QMUIEmotionInputManager alloc] init];
        if ([self.commentToolBar.realTextView isKindOfClass:[UITextField class]])
        {
            self.qqEmotionManager.boundTextField = (UITextField *)self.commentToolBar.realTextView;
        } else if ([self.commentToolBar.realTextView isKindOfClass:[UITextView class]])
        {
            self.qqEmotionManager.boundTextView = (UITextView *)self.commentToolBar.realTextView;
        }
        self.qqEmotionManager.emotionView.qmui_borderPosition = QMUIViewBorderPositionTop;
        [self.view addSubview:self.qqEmotionManager.emotionView];
        [self.qqEmotionManager.emotionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0,*))
            {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            }
            else
            {
                make.top.equalTo(self.view.mas_bottom);
                make.left.right.equalTo(self.view);
            }
            make.height.mas_equalTo(kEmotionViewHeight);
        }];
    }
    [self.commentToolBar setEmotionManager:self.qqEmotionManager];
#endif
#if MLS_USE_US2FORMVALIDATOR
    [self.commentToolBar.realTextView setValidator:[self validator]];
#endif
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskControlDidTap:)];
    [self.maskControl addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self.maskControl];
    [self.maskControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.commentToolBar];
    
    [self.commentToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ([self alwaysShowCommentView])
        {
            if (@available(iOS 11.0,*))
            {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }
            else
            {
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
            }
        } else
        {
            make.top.equalTo(self.view.mas_bottom);
            make.left.right.equalTo(self.view);
        }
    }];
    
    self.keyboardManager = [[QMUIKeyboardManager alloc] initWithDelegate:self];
    [self.keyboardManager addTargetResponder:self.commentToolBar.realTextView];

}
- (void)maskControlDidTap:(UITapGestureRecognizer *)tapGesture {
    [self hideCommentViewWithCleanText:NO force:YES];
}
/// MARK: -键盘事件 处理
- (void)keyboardWillChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (!self.commentToolBar.isShowingEmotion) {
        __weak __typeof(self)weakSelf = self;
        [QMUIKeyboardManager handleKeyboardNotificationWithUserInfo:keyboardUserInfo showBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf showToolbarViewWithKeyboardUserInfo:keyboardUserInfo];
        } hideBlock:^(QMUIKeyboardUserInfo *keyboardUserInfo) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf hideToolbarViewWithKeyboardUserInfo:keyboardUserInfo];
        }];
    }
    else {
        [self showToolbarViewWithKeyboardUserInfo:nil];
    }
}

- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view {
    if (view == self.commentToolBar) {
        // 输入框并非撑满 toolbarView 的，所以有可能点击到 toolbarView 里空白的地方，此时保持键盘状态不变
        return NO;
    }
    return NO;
}

- (void)showEmotionView {
#if MLS_ENABLE_EMOTION_INPUT
    [UIView animateWithDuration:0.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
        self.qqEmotionManager.emotionView.layer.transform = CATransform3DMakeTranslation(0, - CGRectGetHeight(self.qqEmotionManager.emotionView.bounds), 0);
    } completion:NULL];
#endif
    [self.commentToolBar.realTextView resignFirstResponder];
    [self showToolbarViewWithKeyboardUserInfo:nil];
}
- (void)showToolbarViewWithKeyboardUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    [self.commentToolBar setPlaceHolder:[self placeHolderAttributeString]];
    [self.commentToolBar setPlaceHolder:[self placeHolderString]];
    if (keyboardUserInfo) {
        // 相对于键盘
        [QMUIKeyboardManager animateWithAnimated:YES keyboardUserInfo:keyboardUserInfo animations:^{
            self.maskControl.alpha = 1;
            CGFloat distanceFromBottom = [QMUIKeyboardManager distanceFromMinYToBottomInView:self.view keyboardRect:keyboardUserInfo.endFrame];
            CGFloat toobarHeight = CGRectGetHeight(self.commentToolBar.bounds);
            if ([self alwaysShowCommentView])
            {
                toobarHeight = 0;
            }
            self.commentToolBar.layer.transform = CATransform3DMakeTranslation(0, - distanceFromBottom - toobarHeight, 0);
#if MLS_ENABLE_EMOTION_INPUT
            self.qqEmotionManager.emotionView.layer.transform = CATransform3DMakeTranslation(0, -distanceFromBottom, 0);
#endif
        } completion:^(BOOL finished) {
            [self commentViewDidShow:self.commentToolBar];
        }];
    } else {
        // 相对于表情面板
        [UIView animateWithDuration:0.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.maskControl.alpha = 1;
            CGFloat toobarHeight = CGRectGetHeight(self.commentToolBar.bounds);
            if ([self alwaysShowCommentView])
            {
                toobarHeight = 0;
            }
#if MLS_ENABLE_EMOTION_INPUT
            self.commentToolBar.layer.transform = CATransform3DMakeTranslation(0, - CGRectGetHeight(self.qqEmotionManager.emotionView.bounds) - toobarHeight, 0);
#else
            self.commentToolBar.layer.transform = CATransform3DMakeTranslation(0, - toobarHeight, 0);
#endif
        } completion:^(BOOL finished) {
            [self commentViewDidShow:self.commentToolBar];
        }];
    }
}

- (void)hideToolbarViewWithKeyboardUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (keyboardUserInfo) {
        [QMUIKeyboardManager animateWithAnimated:YES keyboardUserInfo:keyboardUserInfo animations:^{
            self.commentToolBar.layer.transform = CATransform3DIdentity;
#if MLS_ENABLE_EMOTION_INPUT
            self.qqEmotionManager.emotionView.layer.transform = CATransform3DIdentity;
#endif
            self.maskControl.alpha = 0;
        } completion:^(BOOL finished) {
            [self commentViewDidHide:self.commentToolBar];
        }];
    } else {
        [UIView animateWithDuration:0.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.commentToolBar.layer.transform = CATransform3DIdentity;
#if MLS_ENABLE_EMOTION_INPUT
            self.qqEmotionManager.emotionView.layer.transform = CATransform3DIdentity;
#endif
            self.maskControl.alpha = 0;
        } completion:^(BOOL finished) {
            [self commentViewDidHide:self.commentToolBar];
        }];
    }
}
- (void)hide {
    [self.commentToolBar.realTextView resignFirstResponder];
    [self hideToolbarViewWithKeyboardUserInfo:nil];
}
/// MARK: - CommentToolBar 代理
- (BOOL)commentToolBarWillHide:(UIView<MLSBaseCommentToolBarProtocol> *)commentTooBar {
    return [self commentViewWillHide:commentTooBar];
}
- (BOOL)commentToolBarWillShow:(UIView<MLSBaseCommentToolBarProtocol> *)commentTooBar {
    return [self commentViewWillShow:commentTooBar];
}

/// MARK: - SubClass Holder
- (UIView <MLSBaseCommentToolBarProtocol>*)getCommentView {
    return nil;
}
- (id<UITextInput>)textView {
    return nil;
}
- (BOOL)alwaysShowCommentView {
    return NO;
}
- (CGFloat)expandMaxHeight {
    return 300;
}
- (BOOL)autoExpandHeight {
    return NO;
}

- (NSString *)placeHolderString {
    return @"说点什么";
}

- (NSAttributedString *)placeHolderAttributeString {
    return nil;
}

- (MLSBaseCommentToolBarType)commentToolBarType {
    return MLSBaseCommentToolBarTypeNone;
}
- (BOOL)commentViewWillShow:(id <MLSBaseCommentToolBarProtocol>)commentView {
    return YES;
}
- (void)commentViewDidShow:(id <MLSBaseCommentToolBarProtocol>)commentView {
    
}

- (BOOL)commentViewWillHide:(id <MLSBaseCommentToolBarProtocol>)commentView {
    return YES;
}

- (void)commentViewDidHide:(id <MLSBaseCommentToolBarProtocol>)commentView {
    
}

- (void)commentViewSendButtonDidClick:(id <MLSBaseCommentToolBarProtocol>)commentView hideBlock:(void (^)(BOOL hide))hideBlock cleanTextBlock:(void (^)(BOOL clean))cleanTextBlock {
    hideBlock(YES);
    cleanTextBlock(YES);
}

- (void)showCommentViewWithCleanText:(BOOL)cleanText {
    [self.commentToolBar.realTextView becomeFirstResponder];
    self.maskControl.hidden = NO;
    if (cleanText) {
        self.commentToolBar.text = nil;
    }
}

- (void)hideCommentViewWithCleanText:(BOOL)cleanText force:(BOOL)force {
    [self.commentToolBar.realTextView resignFirstResponder];
    if (cleanText) {
        self.commentToolBar.text = nil;
    }
}
- (BOOL)commentForceLayoutBringToTop {
    return NO;
}

@end
NSString *MLSViewControllerReloadDataNotifaction = @"MLSViewControllerReloadDataNotifaction";


@implementation MLSBaseViewController (MLSActive)

- (void)startApplicationMonitor:(MLSViewControllerMonitorType)types {
    if (types & MLSViewControllerMonitorTypeActive) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewControllerDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    if (types & MLSViewControllerMonitorTypeResignActive) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewControllerWillResignActive)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    if (types & MLSViewControllerMonitorTypeEnterBackground) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewControllerDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    if (types & MLSViewControllerMonitorTypeEnterForground) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewControllerWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    if (types & MLSViewControllerMonitorTypeTerminate) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewControllerWillTerminate)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
   
}
/**
 取消监听
 
 @param types | 符号相连接
 */
- (void)stopApplicationMonitor:(MLSViewControllerMonitorType)types {
    if (types & MLSViewControllerMonitorTypeActive) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    if (types & MLSViewControllerMonitorTypeResignActive) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    }
    if (types & MLSViewControllerMonitorTypeEnterBackground) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    if (types & MLSViewControllerMonitorTypeEnterForground) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    if (types & MLSViewControllerMonitorTypeTerminate) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    }
}

// SubClassHolder
- (void)viewControllerDidBecomeActive {
    
}
- (void)viewControllerWillResignActive {
    
}

- (void)viewControllerDidEnterBackground {
    
}

- (void)viewControllerWillEnterForeground {
    
}

- (void)viewControllerWillTerminate {
    
}

@end



#ifdef QMUI_ENABLE_SCROLLANIMATOR
@implementation MLSBaseViewController (MLSNavigationBar)
QMUISynthesizeIdStrongProperty(naviBarAnimator, setNaviBarAnimator);
QMUISynthesizeBOOLProperty(enableNavigationBarAnimator, setEnableNavigationBarAnimator);
- (void)enableAnimatorInScrollView:(UIScrollView *)scrollView startOffset:(CGFloat)startOffset distanceOffset:(CGFloat)distanceOffset {
    if (!scrollView) {
        return;
    }
    if (self.naviBarAnimator) {
        self.naviBarAnimator.enabled = YES;
        return;
    }
    self.naviBarAnimator = [[QMUINavigationBarScrollingAnimator alloc] init];
    self.naviBarAnimator.scrollView = scrollView;
    self.naviBarAnimator.offsetYToStartAnimation = startOffset;
    self.naviBarAnimator.distanceToStopAnimation = distanceOffset;
    __weak __typeof(self)weakSelf = self;
    self.naviBarAnimator.backgroundImageBlock = ^UIImage * _Nonnull(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress) {
      __strong __typeof(weakSelf)strongSelf = weakSelf;
        return [strongSelf navibarAnimator:animator navigationBarBackgroundImageWithProgress:progress];
    };
    self.naviBarAnimator.shadowImageBlock = ^UIImage * _Nonnull(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        return [strongSelf navibarAnimator:animator navigationBarShadowImageWithProgress:progress];
    };
    self.naviBarAnimator.tintColorBlock = ^UIColor * _Nonnull(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        return [strongSelf navibarAnimator:animator navigationBarTintColorWithProgress:progress];
    };
    self.naviBarAnimator.titleViewTintColorBlock = ^UIColor * _Nonnull(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        return [strongSelf navibarAnimator:animator navigationBarTitleViewTintColorWithProgress:progress];
    };
    self.naviBarAnimator.statusbarStyleBlock = ^UIStatusBarStyle(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        return [strongSelf navibarAnimator:animator statusBarStyleWithProgress:progress];
    };
    self.naviBarAnimator.barTintColorBlock = ^UIColor * _Nonnull(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        return [strongSelf navibarAnimator:animator navigationBarBarTintColorWithProgress:progress];
    };
    
    self.naviBarAnimator.animationBlock = ^(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf callAnimatorBlock:animator progress:progress];
    };
}

- (void)callAnimatorBlock:(QMUINavigationBarScrollingAnimator * _Nonnull )animator progress:(float)progress {
    [self navibarAnimator:animator didAnimationProgress:progress];
    if (animator.backgroundImageBlock) {
        UIImage *backgroundImage = animator.backgroundImageBlock(animator, progress);
        [animator.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    }
    if (animator.shadowImageBlock) {
        UIImage *shadowImage = animator.shadowImageBlock(animator, progress);
        animator.navigationBar.shadowImage = shadowImage;
    }
    if (animator.tintColorBlock) {
        UIColor *tintColor = animator.tintColorBlock(animator, progress);
        animator.navigationBar.tintColor = tintColor;
    }
    if (animator.titleViewTintColorBlock) {
        UIColor *tintColor = animator.titleViewTintColorBlock(animator, progress);
        animator.navigationBar.topItem.titleView.tintColor = tintColor;// TODO: 对 UIViewController 是否生效？
    }
    if (animator.barTintColorBlock) {
        animator.barTintColorBlock(animator, progress);
    }
    if (animator.statusbarStyleBlock) {
        UIStatusBarStyle style = animator.statusbarStyleBlock(animator, progress);
        // 需在项目的 Info.plist 文件内设置字段 “View controller-based status bar appearance” 的值为 NO 才能生效，如果不设置，或者值为 YES，则请自行通过系统提供的 - preferredStatusBarStyle 方法来实现，statusbarStyleBlock 无效
        BeginIgnoreDeprecatedWarning
        if (style >= UIStatusBarStyleLightContent) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
        EndIgnoreDeprecatedWarning
    }
    
    [animator.navigationBar setTranslucent:[self navibarAnimator:animator navigationBarTranslucentWithProgress:progress]];
    [animator.navigationBar setOpaque:[self navibarAnimator:animator navigationBarOpaqueWithProgress:progress]];
    [animator.navigationBar setBackgroundColor:[self navibarAnimator:animator navigationBarBackgroundColorWithProgress:progress]];
}

- (void)disableAnimator {
    self.naviBarAnimator.enabled = NO;
}

#define MLS_RESPONS_SEL(sel, default) [self respondsToSelector:@selector(sel)] ? [self sel] : default

- (void)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator didAnimationProgress:(float)progres {
    
}
- (BOOL)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarTranslucentWithProgress:(float)progres {
    return MLS_RESPONS_SEL(navigationBarTranslucent, NO);
}
- (BOOL)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarOpaqueWithProgress:(float)progres {
    return MLS_RESPONS_SEL(navigationBarOpaque, NO);
}
- (UIImage *)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarBackgroundImageWithProgress:(float)progres {
    return MLS_RESPONS_SEL(navigationBarBackgroundImage, QMUICMI.navBarBackgroundImage);
}

- (UIImage *)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarShadowImageWithProgress:(float)progres {
    return MLS_RESPONS_SEL(navigationBarShadowImage, QMUICMI.navBarShadowImage);
}

- (UIColor *)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarTintColorWithProgress:(float)progres {
    return MLS_RESPONS_SEL(navigationBarTintColor, QMUICMI.navBarTintColor);
}

- (UIColor *)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarTitleViewTintColorWithProgress:(float)progres {
    return MLS_RESPONS_SEL(titleViewTintColor, QMUICMI.navBarTitleColor);
}

- (UIStatusBarStyle)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator statusBarStyleWithProgress:(float)progres {
    return [self preferredStatusBarStyle];
}

- (UIColor *)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarBarTintColorWithProgress:(float)progres {
    return MLS_RESPONS_SEL(navigationBarBarTintColor, QMUICMI.navBarBarTintColor);

}
- (UIColor *)navibarAnimator:(QMUINavigationBarScrollingAnimator *)animator navigationBarBackgroundColorWithProgress:(float)progres {
    return MLS_RESPONS_SEL(navigationBarBackgroundColor, UIColor.clearColor);
}
@end

#endif
