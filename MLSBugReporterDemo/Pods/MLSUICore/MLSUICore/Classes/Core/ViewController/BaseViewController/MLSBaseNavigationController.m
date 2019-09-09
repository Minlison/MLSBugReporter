//
//  MLSBaseNavigationController.m
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//

#import "MLSBaseNavigationController.h"
#import "MLSBaseNavigationBar.h"
#import "MLSWebViewController.h"
#import "IMYWebView.h"
@interface MLSBaseNavigationController ()
/**
 *  由于 popViewController 会触发 shouldPopItems，因此用该布尔值记录是否应该正确 popItems
 */
@property BOOL shouldPopItemAfterPopViewController;
@end

@implementation MLSBaseNavigationController

- (void)didInitialize {
    [super didInitialize];
    @try {
        [self setValue:[[MLSBaseNavigationBar alloc] init] forKey:@"navigationBar"];
    }
    @catch (NSException * __unused exception) {}
    self.shouldPopItemAfterPopViewController = NO;
    self.navigationBar.shadowImage = [UIImage qmui_imageWithColor:QMUICMI.whiteColor];
    self.navigationBar.backgroundColor = QMUICMI.whiteColor;
    self.navigationBar.translucent = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super willShowViewController:viewController animated:animated];
//    if ([viewController respondsToSelector:@selector(configNavigationBar:)]) {
//        [((UIViewController <MLSBaseControllerProtocol> *)viewController) configNavigationBar:(MLSBaseNavigationBar *)self.navigationBar];
//    }
}
- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super didShowViewController:viewController animated:animated];
}


//- (BOOL)shouldCustomNavigationBarTransitionWhenPushAppearing
//{
//        return YES;
//}
//
//- (BOOL)shouldCustomNavigationBarTransitionWhenPushDisappearing
//{
//        return YES;
//}
//- (BOOL)shouldCustomNavigationBarTransitionWhenPopAppearing
//{
//        return YES;
//}
//
//- (BOOL)shouldCustomNavigationBarTransitionWhenPopDisappearing
//{
//        return YES;
//}
//- (BOOL)shouldCustomNavigationBarTransitionIfBarHiddenable
//{
//        return YES;
//}

/// MARK: - 把statusBar的控制权交给栈顶控制器
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}
- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
- (BOOL)shouldAutorotate {
    return YES;
}
- (BOOL)prefersStatusBarHidden {
    return self.topViewController.prefersStatusBarHidden;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}


-(UIViewController*)popViewControllerAnimated:(BOOL)animated{
    self.shouldPopItemAfterPopViewController = YES;
    return [super popViewControllerAnimated:animated];
}

-(NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    self.shouldPopItemAfterPopViewController = YES;
    return [super popToViewController:viewController animated:animated];
}

-(NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated{
    self.shouldPopItemAfterPopViewController = YES;
    return [super popToRootViewControllerAnimated:animated];
}
-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    
    //! 如果应该pop，说明是在 popViewController 之后，应该直接 popItems
    if (self.shouldPopItemAfterPopViewController) {
        self.shouldPopItemAfterPopViewController = NO;
        return YES;
    }
    
    //! 如果不应该 pop，说明是点击了导航栏的返回，这时候则要做出判断区分是不是在 webview 中
    if ([self.topViewController isKindOfClass:MLSWebViewController.class]) {
        MLSWebViewController* webVC = (MLSWebViewController*)self.viewControllers.lastObject;
        if (webVC.webView.canGoBack) {
            [webVC.webView goBack];
            
            //!make sure the back indicator view alpha back to 1
            self.shouldPopItemAfterPopViewController = NO;
            [[self.navigationBar subviews] lastObject].alpha = 1;
            return NO;
        }else{
            [self popViewControllerAnimated:YES];
            return NO;
        }
    }else{
        [self popViewControllerAnimated:YES];
        return NO;
    }
}

@end
