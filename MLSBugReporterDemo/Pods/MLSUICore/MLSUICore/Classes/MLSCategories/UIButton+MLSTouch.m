//
//  UIButton+touch.m
//  RMRuntime
//
//  Created by Raymon on 16/6/8.
//  Copyright © 2016年 Raymon. All rights reserved.
//

#import "UIButton+MLSTouch.h"
#import <objc/runtime.h>
@interface UIButton_MLSTouch : NSObject
@end
@implementation UIButton_MLSTouch
@end
@interface UIButton ()
/**
 *  bool 设置是否执行触及事件方法
 */
@property (nonatomic, assign) BOOL isExcuteEvent;
@end
@implementation UIButton (MLSTouch)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL oldSel = @selector(sendAction:to:forEvent:);
        SEL newSel = @selector(newSendAction:to:forEvent:);
        // 获取到上面新建的oldsel方法
        Method oldMethod = class_getInstanceMethod(self, oldSel);
        // 获取到上面新建的newsel方法
        Method newMethod = class_getInstanceMethod(self, newSel);
        // IMP 指方法实现的指针,每个方法都有一个对应的IMP,调用方法的IMP指针避免方法调用出现死循环问题
        /**
         *  给oldSel添加方法
         *
         *   self      被添加方法的类
         *   oldSel    被添加方法的方法名
         *   newMethod 实现这个方法的函数
         *  (@types 定义该函数返回值类型和参数类型的字符串)
         *   return 是否添加成功
         想了解的可以查看下:
         http://blog.csdn.net/lvmaker/article/details/32396167
         */
        BOOL isAdd = class_addMethod(self, oldSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
        if (isAdd) {
            // 将newSel替换成oldMethod
            class_replaceMethod(self, newSel, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
        }else{
            // 给两个方法互换实现
            method_exchangeImplementations(oldMethod, newMethod);
        }
    });
}

- (void)newSendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if ([self isKindOfClass:UIButton.class] && self.enableDelayTouch) {
        if (self.isExcuteEvent == 0) {
            self.delayTimeInterVal = self.delayTimeInterVal == 0 ? MLSTouchDefaultInterval : self.delayTimeInterVal;
        }
        if (self.isExcuteEvent) return;
        if (self.delayTimeInterVal > 0) {
            self.isExcuteEvent = YES;
            [self performSelector:@selector(setIsExcuteEvent:) withObject:nil afterDelay:self.delayTimeInterVal];
        }
    }
    [self newSendAction:action to:target forEvent:event];
}

- (void)setEnableDelayTouch:(BOOL)enableDelayTouch {
    objc_setAssociatedObject(self, @selector(enableDelayTouch), @(enableDelayTouch), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)enableDelayTouch {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (NSTimeInterval)delayTimeInterVal {
    // 动态获取关联对象
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

- (void)setDelayTimeInterVal:(NSTimeInterval)delayTimeInterVal {
    // 动态设置关联对象
    objc_setAssociatedObject(self, @selector(delayTimeInterVal), @(delayTimeInterVal), OBJC_ASSOCIATION_ASSIGN);
}

- (void)setIsExcuteEvent:(BOOL)isExcuteEvent {
    // 动态设置关联对象
    objc_setAssociatedObject(self, @selector(isExcuteEvent), @(isExcuteEvent), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isExcuteEvent {
    // 动态获取关联对象
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
