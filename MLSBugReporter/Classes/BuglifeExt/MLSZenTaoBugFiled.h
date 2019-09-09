//
//  MLSZenTaoBugFiled.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "LIFETextInputField.h"

/**
 输入框类型

 - MLSZenTaoBugFiledTypeProduct: 所属产品
 - MLSZenTaoBugFiledTypeModule: 所属模块
 - MLSZenTaoBugFiledTypeProject: 所属项目
 - MLSZenTaoBugFiledTypeBuild: 影响版本
 - MLSZenTaoBugFiledTypeAsignTo: 当前指派人
 - MLSZenTaoBugFiledTypeEndTime: 截止日期
 - MLSZenTaoBugFiledTypeBugType: Bug 类型
 - MLSZenTaoBugFiledTypeOSType: 系统类型
 - MLSZenTaoBugFiledTypeBrowserType: 浏览器类型
 - MLSZenTaoBugFiledTypeBugTitle: Bug 标题
 - MLSZenTaoBugFiledTypeBugLevel: Bug 严重级别
 - MLSZenTaoBugFiledTypeBugPriority: Bug 优先级
 - MLSZenTaoBugFiledTypeBugSteps: Bug 重现步骤
 - MLSZenTaoBugFiledTypeCopyTo: 抄送
 - MLSZenTaoBugFiledTypeKeyWords: 关键词
 */
typedef NS_ENUM(NSInteger, MLSZenTaoBugFiledType) {
    MLSZenTaoBugFiledTypeProduct,
    MLSZenTaoBugFiledTypeModule,
    MLSZenTaoBugFiledTypeProject,
    MLSZenTaoBugFiledTypeBuild,
    MLSZenTaoBugFiledTypeAsignTo,
    MLSZenTaoBugFiledTypeEndTime,
    MLSZenTaoBugFiledTypeBugType,
    MLSZenTaoBugFiledTypeOSType,
    MLSZenTaoBugFiledTypeBrowserType,
    MLSZenTaoBugFiledTypeBugTitle,
    MLSZenTaoBugFiledTypeBugLevel,
    MLSZenTaoBugFiledTypeBugPriority,
    MLSZenTaoBugFiledTypeBugSteps,
    MLSZenTaoBugFiledTypeCopyTo,
    MLSZenTaoBugFiledTypeKeyWords,
};

NS_ASSUME_NONNULL_BEGIN

@interface MLSZenTaoBugFiled : LIFETextInputField
@property (nonatomic, assign) MLSZenTaoBugFiledType fieldType;
- (instancetype)initWithType:(MLSZenTaoBugFiledType)type;
@end

NS_ASSUME_NONNULL_END
