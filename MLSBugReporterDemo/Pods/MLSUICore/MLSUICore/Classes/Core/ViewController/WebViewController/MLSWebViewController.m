//
//  LNWebViewController.m
//  MinLison
//
//  Created by MinLison on 2017/9/7.
//  Copyright © 2017年 minlison. All rights reserved.
//

#import "MLSWebViewController.h"
#import "TURLSessionProtocol.h"
#import "IMYWebView.h"
#import "MLSConfigurationDefine.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
@interface MLSWebViewController () <IMYWebViewDelegate>
@property(nonatomic, strong) NSURL *url;
@property(nonatomic, strong, readwrite) IMYWebView *webView;
@end

@implementation MLSWebViewController
- (instancetype)initWithRouteParam:(NSDictionary *)param {
    NSString *urlString = [param objectForKey:@"url"];
    if ( NULLString(urlString)) {
        return nil;
    }
    if (self = [super init] ) {
        self.url = [NSURL URLWithString:urlString];
    }
    return self;
}
+ (instancetype)webViewControllerWithUrlString:(NSString *)urlString {
    return [self webViewControllerWithUrl:[NSURL URLWithString:NOT_NULL_STRING_DEFAULT_EMPTY(urlString)]];
}
+ (instancetype)webViewControllerWithUrl:(NSURL *)url {
    MLSWebViewController *vc = [[MLSWebViewController alloc] init];
    vc.url = url;
    vc.hidesBottomBarWhenPushed = YES;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.url)
    {
        [self setError:[NSError errorWithDomain:NSURLErrorDomain code:-1 userInfo:@{
                                                                                    NSLocalizedDescriptionKey : @"地址不存在"
                                                                                    }]];
        return;
    }
    BOOL customCached =[TURLSessionProtocol isCachedForUrl:self.url.absoluteString];
    BOOL urlCache = [[NSURLCache sharedURLCache] cachedResponseForRequest:[NSURLRequest requestWithURL:self.url]] != nil;
    if ( !customCached && !urlCache)
    {
        [self setLoading:YES animation:YES];
    }
    else
    {
        [self loadData];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstAppear)
    {
        [self loadData];
    }
}
- (void)reloadData {
    [self loadData];
}
- (void)loadData {
    [self setLoading:YES animation:YES];
    if (!self.url)
    {
        [self setError:[NSError errorWithDomain:NSURLErrorDomain code:-1 userInfo:@{
                                                                                    NSLocalizedDescriptionKey : @"地址不存在"
                                                                                    }]];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [self loadUrl:self.url success:^(BOOL success, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf setSuccess];
    } failed:^(BOOL success, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf setError:error];
    }];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self loadUrl:self.url success:nil failed:nil];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)loadUrlString:(NSString *)urlString success:(MLSWebViewLoadCompletionBlock)success failed:(MLSWebViewLoadCompletionBlock)failed {
    [self loadUrl:[NSURL URLWithString:NOT_NULL_STRING_DEFAULT_EMPTY(urlString)] success:success failed:failed];
}
- (void)loadUrl:(NSURL *)url success:(MLSWebViewLoadCompletionBlock)success failed:(MLSWebViewLoadCompletionBlock)failed {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"1" forHTTPHeaderField:KProtocolHttpHeadKey];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [request setValue:version forHTTPHeaderField:@"Version"];
    [request setValue:@"MLSUA" forHTTPHeaderField:@"Identifier"];
    [request setValue:@"iOS" forHTTPHeaderField:@"Platform"];
    [self.webView loadRequest:request];
    self.successCallBack = success;
    self.failedCallBack = failed;
}


- (void)webViewDidFinishLoad:(IMYWebView *)webView {
    if (self.successCallBack) {
        self.successCallBack(YES, nil);
    }
    [self cleanBlock];
}

- (void)webView:(IMYWebView *)webView didFailLoadWithError:(NSError *)error {
    /// ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 204) 表示插件加载错误，不处理
    if(error.code == NSURLErrorCancelled)
    {
        return;
    }
    if (([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 204))
    {
        if (self.successCallBack)
        {
            self.successCallBack(YES, nil);
        }
    }
    else
    {
        if (self.failedCallBack)
        {
            self.failedCallBack(NO, [NSError errorWithDomain:NSURLErrorDomain code:-1 userInfo:nil]);
        }
        [self cleanBlock];
    }
    
}
- (void)cleanBlock {
    self.failedCallBack = nil;
    self.successCallBack = nil;
}
/// MARK: - Super method
- (void)setupWebView {
    //        [super setupView];
    self.webView = [[IMYWebView alloc] initWithFrame:self.view.bounds usingUIWebView:YES]; // 暂时直接使用 UIWebView
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0,*))
        {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else
        {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }
    }];
}

- (NSString *)getNowTimeTimestamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    return timeSp;
    
}

@end
