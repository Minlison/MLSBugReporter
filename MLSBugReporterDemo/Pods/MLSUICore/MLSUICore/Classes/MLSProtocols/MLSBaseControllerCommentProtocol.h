//
//  MLSBaseControllerCommentProtocol.h
//  minlison
//
//  Created by minlison on 2018/5/7.
//  Copyright © 2018年 minlison. All rights reserved.
//

#ifndef MLSBaseControllerCommentProtocol_h
#define MLSBaseControllerCommentProtocol_h
#import <UIKit/UIKit.h>
#import "MLSBaseCommentToolBarProtocol.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,MLSBaseCommentToolBarType) {
        // 没有评论框，默认
        MLSBaseCommentToolBarTypeNone,
        /// 普通评论框，默认
        MLSBaseCommentToolBarTypeNormal,
        /// 自动增长高度的评论框
        MLSBaseCommentToolBarTypeAutoHeight,
        /// 拥有表情的评论框
        MLSBaseCommentToolBarTypeEmotion,
        /// 拥有表情并且自动增长高度的评论框
        MLSBaseCommentToolBarTypeEmotionAutoHeight,
};

@protocol MLSBaseControllerCommentProtocol <NSObject>

/**
 获取评论视图
 如果自定义了视图，则 MLSBaseCommentToolBarType 设置无效
 */
- (UIView <MLSBaseCommentToolBarProtocol> *)getCommentView;

/**
 评论框视图
 */
@property(nonatomic, strong, readonly) UIView <MLSBaseCommentToolBarProtocol> *commentToolBar;

/**
 是否在底部常驻评论框
 默认为 NO
 */
- (BOOL)alwaysShowCommentView;

/**
 评论框最大高度
 默认为50
 */
- (CGFloat)expandMaxHeight;

/**
 是否允许自动增长行高

 @return 是否允许
 */
- (BOOL)autoExpandHeight;

/**
 占位字符，可为空，每次响应的时候时候，都会自动调用一次该方法，获取最新的占位字符
 */
- (nullable NSString *)placeHolderString;

/**
 占位属性字符串，可为空，每次响应的时候时候，都会自动调用一次该方法，获取最新的占位字符
 优先级高于 -placeHolderString
 */
- (nullable NSAttributedString *)placeHolderAttributeString;

/**
 评论类型（切换不同评论界面）
 */
- (MLSBaseCommentToolBarType)commentToolBarType;

/**
 评论视图即将显示
 
 @param commentView 评论视图
 @return 是否显示
 */
- (BOOL)commentViewWillShow:(id <MLSBaseCommentToolBarProtocol>)commentView;

/**
 评论视图显示完成
 
 @param commentView 评论视图
 */
- (void)commentViewDidShow:(id <MLSBaseCommentToolBarProtocol>)commentView;

/**
 评论视图将要隐藏
 
 @param commentView 评论视图
 */
- (BOOL)commentViewWillHide:(id <MLSBaseCommentToolBarProtocol>)commentView;

/**
 评论视图已经隐藏
 
 @param commentView 评论视图
 */
- (void)commentViewDidHide:(id <MLSBaseCommentToolBarProtocol>)commentView;

/**
 评论按钮点击
 
 @param commentView 评论视图
 @param hideBlock  隐藏回调，在调用 hideBlock 后才会隐藏键盘视图
 @param cleanTextBlock 清空输入文本回调，调用后，清除文本
 */
- (void)commentViewSendButtonDidClick:(id <MLSBaseCommentToolBarProtocol>)commentView hideBlock:(void (^)(BOOL hide))hideBlock cleanTextBlock:(void (^)(BOOL clean))cleanTextBlock;

/**
 可以主动调用，显示评论框
 @param cleanText 是否清除上次的文字记录
 */
- (void)showCommentViewWithCleanText:(BOOL)cleanText;

/**
 可以主动调用，隐藏评论框，在 viewWillDisappear/applicationWillResignActive 的时候，会自动调用该方法。
 
 @param cleanText 是否清除上次的文字记录
 @param force 是否强制隐藏
 */
- (void)hideCommentViewWithCleanText:(BOOL)cleanText force:(BOOL)force;

/**
 是否一直在最上层，
 默认为 NO，会在 EmptyView 下方
 如果为 YES， 会到 EmptyView 上方
 
 @return 是否在最上层
 */
- (BOOL)commentForceLayoutBringToTop;
@end

NS_ASSUME_NONNULL_END
#endif /* MLSBaseControllerCommentProtocol_h */
