//
//  MLSBaseCommentToolBarProtocol.h
//  minlison
//
//  Created by minlison on 2018/5/7.
//  Copyright © 2018年 minlison. All rights reserved.
//

#ifndef MLSBaseCommentToolBarProtocol_h
#define MLSBaseCommentToolBarProtocol_h

@protocol MLSBaseCommentToolBarProtocol;
typedef NS_ENUM(NSInteger,MLSBaseCommentToolBarActionType ) {
        /// 发送
        MLSBaseCommentToolBarActionTypeSend,
        /// 表情符号键盘显示
        MLSBaseCommentToolBarActionTypeShowEmotion,
        /// 表情符号键盘隐藏
        MLSBaseCommentToolBarActionTypeHideEmotion,
        /// 文字无效
        MLSBaseCommentToolBarActionTypeTextNotValid,
};

typedef void (^MLSBaseCommentToolBarActionBlock)(MLSBaseCommentToolBarActionType type, id <MLSBaseCommentToolBarProtocol> tooBar);

@protocol MLSBaseCommentToolBarDelegate <NSObject>

/**
 将要弹出

 @param commentTooBar  commentToolBar
 @return  是否允许弹出
 */
- (BOOL)commentToolBarWillShow:(UIView <MLSBaseCommentToolBarProtocol>*)commentTooBar;

/**
 将要隐藏

 @param commentTooBar commentToolBar
 @return  是否允许隐藏
 */
- (BOOL)commentToolBarWillHide:(UIView <MLSBaseCommentToolBarProtocol>*)commentTooBar;

@end


@protocol MLSBaseCommentToolBarProtocol <NSObject>

/**
 显示文字的视图
 */

#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_10_0
@property(nonatomic, strong, readonly) UIView <UITextInput, UIContentSizeCategoryAdjusting>* realTextView;
#else
@property(nonatomic, strong, readonly) UIView <UITextInput>* realTextView;
#endif

/**
 代理
 */
@property(nonatomic, weak) id <MLSBaseCommentToolBarDelegate> delegate;

/**
 文字
 */
@property(nonatomic, copy) NSString *text;

/**
 是否正在显示表情
 */
@property(nonatomic, assign, getter=isShowingEmotion, readonly) BOOL showingEmotion;

/**
 点击事件
 */
- (void)setToolBarActionBlock:(MLSBaseCommentToolBarActionBlock)actionBlock;

/**
 是否可自动增加高度
 */
- (void)setAutoResizable:(BOOL)autoResizable;

/**
 设置占位字符

 @param placeHolder 占位字符 可以是 NSString，或者是 NSAttributeString
 */
- (void)setPlaceHolder:(id)placeHolder;

/**
 设置最大的高度（自增高的时候才会使用）

 @param maxExpandHeight 最大的高度
 */
- (void)setMaxExpandHeight:(CGFloat)maxExpandHeight;

@end

#endif /* MLSBaseCommentToolBarProtocol_h */
