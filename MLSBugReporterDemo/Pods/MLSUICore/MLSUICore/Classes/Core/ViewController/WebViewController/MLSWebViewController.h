//
//  LNWebViewController.h
//  MinLison
//
//  Created by MinLison on 2017/9/7.
//  Copyright © 2017年 minlison. All rights reserved.
//
#import "MLSBaseViewController.h"
/**
 加载完成回调
 
 @param success 是否成功
 @param error 错误信息
 */
typedef void (^MLSWebViewLoadCompletionBlock)(BOOL success, NSError *error);

@class IMYWebView;
@interface MLSWebViewController : MLSBaseViewController

/**
 webView
 */
@property(nonatomic, strong, readonly) IMYWebView *webView;

/**
 加载成功回调
 */
@property(nonatomic, copy) MLSWebViewLoadCompletionBlock successCallBack;

/**
 加载失败回调s
 */
@property(nonatomic, copy) MLSWebViewLoadCompletionBlock failedCallBack;

/**
 创建控制器

 @param url  网页地址
 
 @return 控制器
 */
+ (instancetype)webViewControllerWithUrl:(NSURL *)url;
+ (instancetype)webViewControllerWithUrlString:(NSString *)urlString;
@end
