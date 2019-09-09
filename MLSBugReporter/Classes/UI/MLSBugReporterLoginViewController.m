//
//  MLSBugReporterLoginViewController.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/15.
//

#import "MLSBugReporterLoginViewController.h"
#import <QMUIKit/QMUIKit.h>
#import <Masonry/Masonry.h>
#import "MLSZenTaoLoginReq.h"
#import "MLSZenTaoConfigReq.h"
#import "MLSBugReportCreateBugReq.h"
#import "MLSBugReporterOptions.h"
#import "MLSZentaoPingReq.h"
#import "MLSZenTaoGetAllUsersReq.h"
#import "MLSZenTaoGetAllBuildsReq.h"
#define MLSBugReportErrorDomain @"com.minlison.bugreport"
#define MLSBugReportErrorWithDes(des) [NSError errorWithDomain:MLSBugReportErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : des}]

@interface MLSBugReporterLoginViewController () <QMUIModalPresentationContentViewControllerProtocol>
@property (nonatomic, strong) UITextField *userNameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *passwordLabel;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIStackView *userNameView;
@property (nonatomic, strong) UIStackView *passwordView;
@property (nonatomic, copy) void (^loginCompletion)(BOOL success, NSError *error);
@end

@implementation MLSBugReporterLoginViewController
static BOOL loginControllerIsShowing = NO;
+ (void)showIfNeed {
    [self showIfNeedAndLoginCompletion:nil];
}
+ (void)showIfNeedAndLoginCompletion:(void (^)(BOOL success, NSError *error))completion {
    MLSZentaoConfigModel *config =  [MLSBugReporterOptions shareOptions].configModel;
    if (config.sessionID == nil && !loginControllerIsShowing) {
        QMUIModalPresentationViewController *modalViewController = [[QMUIModalPresentationViewController alloc] init];
        modalViewController.animationStyle = QMUIModalPresentationAnimationStyleSlide;
        MLSBugReporterLoginViewController *loginVC = [[MLSBugReporterLoginViewController alloc] init];
        loginVC.loginCompletion = completion;
        modalViewController.contentViewController = loginVC;
        loginControllerIsShowing = YES;
        modalViewController.didHideByDimmingViewTappedBlock = ^{
            loginControllerIsShowing = NO;
        };
        [modalViewController showWithAnimated:YES completion:nil];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorWhite;
    self.view.layer.cornerRadius = 6;
    UIEdgeInsets padding = UIEdgeInsetsMake(20, 20, 20, 20);
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.alwaysBounceHorizontal = NO;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.titleLabel = [[UILabel alloc] qmui_initWithFont:[UIFont boldSystemFontOfSize:18] textColor:UIColor.blackColor];
    self.titleLabel.text = @"登录";
    [self.scrollView addSubview:self.titleLabel];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView.mas_top).mas_offset(padding.top);
        make.centerX.equalTo(self.scrollView);
        make.height.mas_equalTo(44);
    }];
    
    self.userNameLabel = [[UILabel alloc] qmui_initWithFont:[UIFont systemFontOfSize:18] textColor:UIColor.blackColor];
    self.userNameLabel.text = @"用户名：";
    [self.userNameLabel sizeToFit];
    [self.scrollView addSubview:self.userNameLabel];
    
    [self.userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).mas_offset(padding.left);
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(20);
        make.width.mas_equalTo(90);
    }];
    
    self.userNameField = [[UITextField alloc] init];
    self.userNameField.font = [UIFont systemFontOfSize:18];
    self.userNameField.textColor = UIColor.blackColor;
    self.userNameField.keyboardType = UIKeyboardTypeDefault;
    self.userNameField.qmui_borderPosition = QMUIViewBorderPositionBottom;
    if (@available(iOS 10, *)) {
        self.userNameField.textContentType = UITextContentTypeUsername;
    }
    self.userNameField.placeholder = @"请输入用户名";
    [self.scrollView addSubview:self.userNameField];
    [self.userNameField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.userNameLabel);
        make.left.equalTo(self.userNameLabel.mas_right).mas_offset(10);
        make.right.equalTo(self.scrollView.mas_right).mas_offset(-padding.right);
        make.right.equalTo(self.view.mas_right).mas_offset(-padding.right);
    }];
    
    
    self.passwordLabel = [[UILabel alloc] qmui_initWithFont:[UIFont systemFontOfSize:18] textColor:UIColor.blackColor];
    self.passwordLabel.text = @"密码：";
    [self.passwordLabel sizeToFit];
    [self.scrollView addSubview:self.passwordLabel];
    
    [self.passwordLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.userNameLabel);
        make.top.equalTo(self.userNameLabel.mas_bottom).mas_offset(20);
        make.width.mas_equalTo(90);
    }];
    
    self.passwordField = [[UITextField alloc] init];
    self.passwordField.keyboardType = UIKeyboardTypeDefault;
    self.passwordField.font = [UIFont systemFontOfSize:18];
    self.passwordField.textColor = UIColor.blackColor;
    self.passwordField.qmui_borderPosition = QMUIViewBorderPositionBottom;
    if (@available(iOS 10, *)) {
        self.passwordField.textContentType = UITextContentTypePassword;
    }
    self.passwordField.placeholder = @"请输入密码";
    self.passwordField.secureTextEntry = YES;
    
    [self.scrollView addSubview:self.passwordField];
    
    [self.passwordField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.passwordLabel);
        make.left.equalTo(self.passwordLabel.mas_right).mas_offset(10);
        make.right.equalTo(self.scrollView.mas_right).mas_offset(-padding.right);
        make.right.equalTo(self.view.mas_right).mas_offset(-padding.right);
    }];
    
    self.loginBtn = [[UIButton alloc] init];
    [self.loginBtn addTarget:self action:@selector(loginAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.loginBtn setTitle:@"登录" forState:(UIControlStateNormal)];
    [self.loginBtn setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
    [self.loginBtn setBackgroundColor:UIColor.lightGrayColor];
    self.loginBtn.layer.cornerRadius = 22;
    self.loginBtn.layer.masksToBounds = YES;
    [self.scrollView addSubview:self.loginBtn];
    [self.loginBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordField.mas_bottom).mas_offset(20);
        make.centerX.equalTo(self.scrollView);
        make.size.mas_equalTo(CGSizeMake(200, 44));
        make.bottom.equalTo(self.scrollView.mas_bottom).mas_offset(-padding.bottom);
    }];
}
- (void)loginAction {
    MLSZentaoConfigModel *config =  [MLSBugReporterOptions shareOptions].configModel;
    if (config == nil || NULLString(config.sessionID)) {
        [self getConfigAndLogin];
    } else {
        [self loginRequest];
    }
}
- (void)getConfigAndLogin {
    [MLSTipClass showLoadingInView:self.view];
    [[MLSZenTaoConfigReq requestWithParam:nil] startWithModelCompletionBlockWithSuccess:^(__kindof MLSNetworkRequest *request, MLSZentaoConfigModel *model) {
        [MLSTipClass hideLoadingInView:self.view];
        MLSBugReporterOptions.shareOptions.configModel = model;
        [self loginRequest];
    } failure:^(__kindof MLSNetworkRequest *request, MLSZentaoConfigModel *model) {
        [MLSTipClass hideLoadingInView:self.view];
        [MLSTipClass showErrorWithText:request.tipString inView:self.view];
    }];
}
- (void)loginRequest {
    if (NULLString(self.userNameField.text) || NULLString(self.passwordField.text)) {
        return;
    }
    [MLSTipClass showLoadingInView:self.view];
    [[MLSZenTaoLoginReq requestWithFormParams:@{@"account" : self.userNameField.text,
                                                @"password" : self.passwordField.text,
                                                @"keepLogin" : @(YES),
                                                }]
     startWithModelCompletionBlockWithSuccess:^(__kindof MLSNetworkRequest *request, MLSZenTaoUserModel *model) {
         [MLSTipClass hideLoadingInView:self.view];
         if (model.account != nil) {
             [self.class getBugProductID:^(BOOL success, NSError * _Nonnull error) {
                 if (success) {
                     [self.qmui_modalPresentationViewController hideWithAnimated:YES completion:^(BOOL finished) {
                         loginControllerIsShowing = NO;
                         if (self.loginCompletion) {
                             self.loginCompletion(YES, nil);
                         }
                     }];
                 } else {
                     if (self.loginCompletion) {
                         self.loginCompletion(NO, error);
                     }
                 }
             }];
             
         } else {
             if (self.loginCompletion) {
                 self.loginCompletion(NO, request.error);
             }
             [MLSTipClass showErrorWithText:[NSString stringWithFormat:@"登录失败-%@", request.tipString] inView:self.view];
         }
     } failure:^(__kindof MLSNetworkRequest *request, MLSZenTaoUserModel *model) {
         [MLSTipClass hideLoadingInView:self.view];
         [MLSTipClass showErrorWithText:request.tipString inView:self.view];
         if (self.loginCompletion) {
             self.loginCompletion(NO, request.error);
         }
     }];
}

+ (void)getBugProductID:(void (^)(BOOL success, NSError *error))completion {
    if (!MLSBugReporterOptions.shareOptions.zentaoProductName) {
        if (completion) {
            completion(NO, MLSBugReportErrorWithDes(@"请配置正确的产品名"));
        }
        return;
    }
    [self _getAllUsers:completion];
}

+ (void)_getAllUsers:(void (^)(BOOL success, NSError *error))completion {
    [[MLSZenTaoGetAllUsersReq requestWithParam:nil] startWithSuccess:^(MLSZenTaoGetAllUsersReq * req, id data, NSError *error) {
        NSDictionary *allUsers = req.responseJSONObject;
        if (allUsers && [allUsers isKindOfClass:NSDictionary.class] && allUsers.count > 0) {
            [self _getBugProductIDWithAllUsers:req.responseJSONObject completion:completion];
        } else {
            if (completion) {
                completion(NO, MLSBugReportErrorWithDes(@"获取用户信息失败，请重试"));
            }
        }
    } failure:^(MLSZenTaoGetAllUsersReq * req, id data, NSError *error) {
        if (completion) {
            completion(NO, error);
        }
    }];
}

+ (void)_getBugProductIDWithAllUsers:(NSDictionary *)allUsers completion:(void (^)(BOOL success, NSError *error))completion {
    
    [[MLSBugReportCreateBugReq requestWithProductID:MLSBugReporterOptions.shareOptions.zentaoProductID params:nil] startWithModelCompletionBlockWithSuccess:^(__kindof MLSNetworkRequest *request, MLSZenTaoBugModel *model) {
        __block BOOL findProduct = NO;
        MLSBugReporterOptions.shareOptions.bugModel = model;
        if (allUsers && [allUsers isKindOfClass:NSDictionary.class]) {
            MLSBugReporterOptions.shareOptions.bugModel.projectMembers = allUsers;
        }
        [model.products enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:MLSBugReporterOptions.shareOptions.zentaoProductName]) {
                MLSBugReporterOptions.shareOptions.zentaoProductID = key;
                findProduct = YES;
                *stop = YES;
            }
        }];
        if (!findProduct) {
            MLSBugReporterOptions.shareOptions.bugModel = nil;
            MLSBugReporterOptions.shareOptions.zentaoProductID = nil;
            [MLSBugReporterOptions.shareOptions saveLocal];
            if (completion) {
                completion(NO, MLSBugReportErrorWithDes(@"没有找到对应产品，请配置正确的产品名称"));
            }
        } else {
            [self _getAllBuids:completion];
        }
        
    } failure:^(__kindof MLSNetworkRequest *request, MLSZenTaoBugModel *model) {
        if (completion) {
            completion(NO, request.error);
        }
    }];
}
+ (void)_getAllBuids:(void (^)(BOOL success, NSError *error))completion {
    [[MLSZenTaoGetAllBuildsReq requestWithProductID:MLSBugReporterOptions.shareOptions.zentaoProductID] startWithSuccess:^(MLSZenTaoGetAllBuildsReq* req, id data, NSError *error) {
        if (req.responseJSONObject) {
            MLSBugReporterOptions.shareOptions.bugModel.builds = req.responseJSONObject;
        }
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(MLSZenTaoGetAllBuildsReq* req, id data, NSError *error) {
        if (completion) {
            completion(NO, req.error);
        }
    }];
}
- (CGSize)preferredContentSizeInModalPresentationViewController:(QMUIModalPresentationViewController *)controller keyboardHeight:(CGFloat)keyboardHeight limitSize:(CGSize)limitSize {
    // 高度无穷大表示不显示高度，则默认情况下会保证你的浮层高度不超过QMUIModalPresentationViewController的高度减去contentViewMargins
    return CGSizeMake(CGRectGetWidth(controller.view.bounds) - UIEdgeInsetsGetHorizontalValue(controller.view.qmui_safeAreaInsets) - UIEdgeInsetsGetHorizontalValue(controller.contentViewMargins), CGRectGetHeight(controller.view.bounds) * 0.3);
}
@end
