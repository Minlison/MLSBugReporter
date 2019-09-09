//
//  UIButton+touch.h
//  RMRuntime
//
//  Created by Raymon on 16/6/8.
//  Copyright © 2016年 Raymon. All rights reserved.
//

#import <UIKit/UIKit.h>
#define MLSTouchDefaultInterval 0.3// 默认间隔时间
@interface UIButton (MLSTouch)
/**
 *  设置点击时间间隔
 */
@property (nonatomic, assign) NSTimeInterval delayTimeInterVal;

/**
 是否开启默认时间段内只允许点击一次，默认 NO
 */
@property (nonatomic, assign) BOOL enableDelayTouch;
@end
