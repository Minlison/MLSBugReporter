//
//  MLSBaseTabbarViewController.m
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//

#import "MLSBaseTabbarViewController.h"

@interface MLSBaseTabbarViewController ()

@end

@implementation MLSBaseTabbarViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tabBar.translucent = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)didInitialize {
    [super didInitialize];
    self.tabBar.translucent = NO;
}

// 把statusBar的控制权交给栈顶控制器
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.selectedViewController.preferredStatusBarStyle;
}
- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.selectedViewController;
}
- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return self.selectedViewController;
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
    return self.selectedViewController.prefersStatusBarHidden;
}

@end
