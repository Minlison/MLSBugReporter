//
//  MLSBugRepotRootModel.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/15.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSBugReporterBaseModel.h"
#import <MLSNetwork/MLSNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLSBugRepotRootModel : MLSBugReporterBaseModel <MLSNetworkRootDataProtocol>

/**
 错误码 （服务器返回）
 */
@property (nonatomic, assign) NSInteger code;

/**
 HTTP 错误码 （request 内部会对其赋值）
 */
@property (nonatomic, assign) NSInteger responseHeaderStatusCode;

/**
 提示信息
 */
@property (nonatomic, copy) NSString *message;

/**
 日志信息
 */
@property (nonatomic, copy) NSString *remark;

/**
 数据内容
 */
@property (nonatomic, strong) id data;
@property (nonatomic, copy) NSString *status;


/**
 data 的 md5 值
 */
@property (nonatomic, copy) NSString *md5;

@end

NS_ASSUME_NONNULL_END
