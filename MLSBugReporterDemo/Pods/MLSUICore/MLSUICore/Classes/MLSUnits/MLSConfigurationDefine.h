//
//  BBMarcoDefine.h
//  BangBang
//
//  Created by qcm on 16/12/15.
//  Copyright © 2016年 . All rights reserved.
//

#ifndef MLSConfigurationDefine_h
#define MLSConfigurationDefine_h
#import <Foundation/Foundation.h>
#import <QMUIKit/QMUICommonDefines.h>
#import <QMUIKit/UIColor+QMUI.h>
#import <QMUIKit/QMUIConfigurationMacros.h>
/// MAKR: - 空字符串判断
#define NULLString(string) ((string == nil) || ([string isKindOfClass:[NSNull class]]) || (![string isKindOfClass:[NSString class]])||[string isEqualToString:@""] || [string isEqualToString:@"<null>"] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]== 0 )


/// MAKR: - 空对象判断
#define NULLObject(obj) (obj == nil || obj == [NSNull null] || ([obj isKindOfClass:[NSString class]] && NULLString((NSString *)obj)))

/// MAKR: - 快速创建 NSError
#define ERROR_DES(des) [NSError errorWithDomain:NSURLErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : des}]

/// MARK: - 字符串处理
#define INTEGRE_TO_STRING(A)			[NSString stringWithFormat:@"%ld",(long)(A)]
#define UINTEGRE_TO_STRING(A)			[NSString stringWithFormat:@"%lu",(unsigned long)(A)]
#define INT_TO_STRING(A)			[NSString stringWithFormat:@"%d",(int)(A)]
#define FLOAT_TO_STR(A)				[NSString stringWithFormat:@"%.2f",(double)(A)]
#define NUM_TO_STR(A)				[NSString stringWithFormat:@"%@",NULLString(A) ? @(0) : A]
#define NONNULL_STR(A)				[NSString stringWithFormat:@"%@",NULLString(A) ? @"" : A]
#define NONNULL_STR_DEFAULT(A,D)		[NSString stringWithFormat:@"%@",NULLString(A) ? D : A]

#define COMBAIN_STRING(A,B) [NSString stringWithFormat:@"%@%@",A,B]
#define INSERT_FIRST(A,B) COMBAIN_STRING((A),(B))
#define FORMAT_STR(fmt,...) [NSString stringWithFormat:fmt,##__VA_ARGS__]
#define NO_ZERO(A) MAX((A),0)

#define NOT_NULL_STRING(str, default) (NULLString(str)?default:str)
#define NOT_NULL_STRING_DEFAULT_EMPTY(str) NOT_NULL_STRING(str,@"")


/// MARK: -- 获取window
#define __CURRENT_WINDOW__  [[[UIApplication sharedApplication] delegate] window]
#define __KEY_WINDOW__  [[UIApplication sharedApplication] keyWindow]


/// MARK: -- 屏幕宽高
#define __MAIN_SCREEN_HEIGHT__      SCREEN_HEIGHT
#define __MAIN_SCREEN_WIDTH__       SCREEN_WIDTH
#define __MAIN_SCREEN_BOUNDS__      [[UIScreen mainScreen] bounds]


/// MARK: -- StatusBar 高度
#define __STATUS_BAR_HEIGHT__   (StatusBarHeight?:([CoBaseUtils isPhoneType:(iPhoneTypeX)] ? 44: 20))


/// MARK: -- 导航栏高度
#define __NAV_BAR_HEIGHT__      NavigationBarHeight


/// MARK: -- TabBar高度
#define __TAB_BAR_HEIGHT__      TabBarHeight
/// MARK: -- 屏幕适配
#define __MLSWidth(w)      (IS_IPHONE ? ((w/375.0)*__MAIN_SCREEN_WIDTH__) : ((w/900.0)*__MAIN_SCREEN_HEIGHT__))
//#define __MLSHeight(h)     (IS_IPHONE ? ((h/667.0)*__MAIN_SCREEN_HEIGHT__) : ((h/1024.0)*__MAIN_SCREEN_HEIGHT__))
#define __MLSHeight(h)     __MLSWidth(h)

/// MARK: -- 版本判断
#define IOS_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define IOS_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IOS_VERSION_LESS_THAN(v)                ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define IOS_VERSION_LESS_THAN_OR_EQUAL_TO(v)    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


/// MARK: - Color
#ifndef UIColorHex
#define UIColorHex(_hex_)   [UIColor qmui_colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#endif

#ifndef UIColorHexAlpha
#define UIColorHexAlpha(_hex_,_alpha_)   [UIColorHex(_hex_) colorWithAlphaComponent:_alpha_]
#endif

/// Common Color
/// 音标颜色
#define UIColorSymbolColor UIColorHex(0x9B9B9B)
/// 单词颜色
#define UIColorWordColor UIColorHex(0x333333)

#define MLSUICoreMainBundle [NSBundle bundleForClass:[self class]]
#define MLSUICoreBundlePath [MLSUICoreMainBundle pathForResource:@"MLSUICore" ofType:@"bundle"]
#define MLSUICoreBundle [NSBundle bundleWithPath:MLSUICoreBundlePath]
#define MLSUICoreBuldleImage(img) [UIImage imageNamed:img inBundle:MLSUICoreBundle compatibleWithTraitCollection:nil]


/// MARK: -- Assert
#ifdef DEBUG

#define DebugAssert(condition, desc, ...) NSAssert(condition, desc, ##__VA_ARGS__)

#else

#define DebugAssert(condition, desc, ...)

#endif

#endif /* BBMarcoDefine_h */
