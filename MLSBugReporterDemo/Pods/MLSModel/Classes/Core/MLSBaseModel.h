//
//  MLSBaseModel.h
//  Pods-MLSModel
//
//  Created by MinLison on 2018/5/8.
//

#import <Foundation/Foundation.h>
#if __has_include(<MLSModel/MLSModel.h>)
    #import <MLSModel/NSObject+MLSYYModel.h>
#else
    #import "NSObject+MLSYYModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN
/**
 校验该模型本身是否可用
 */
@protocol MLSModelValidProtocol <NSObject>

/**
 是否有效
 
 @return 是否有效
 */
- (BOOL)isValid;

/**
 错误信息
 */
- (nullable NSError *)validError;

/**
 不允许为空的属性
 
 @return 如果 key 为空，则取对应 key 的默认 value 赋值
 */
- (nullable NSDictionary <NSString *,id>*)nonnullDefaultValueProperties;

@end

/**
 Model 基类，所有继承置该基类的模型，均可自动归解档
 */
@interface MLSBaseModel : NSObject <MLSYYModel, MLSModelValidProtocol>

@end


@interface MLSBaseModel (AutoCoding) <NSSecureCoding>

/**
 可归解档属性字典
 key 为属性名
 value 为属性 Class
 @return 属性字典
 */
+ (NSDictionary *)mls_codableProperties;
- (NSDictionary *)mls_codableProperties;

/**
 根据归档数据解档并赋值
 
 @param aDecoder 解档数据
 */
- (void)mls_setWithCoder:(NSCoder *)aDecoder;

/**
 对象序列化为字典
 
 @return 对象字典
 */
- (NSDictionary *)mls_dictionaryRepresentation;

/**
 通过 plist文件创建对象
 
 @param path 文件路径
 @return 创建好并赋值后的对象
 */
+ (nullable instancetype)mls_objectWithContentsOfFile:(NSString *)path;

/**
 写入到本地文件系统中
 
 @param filePath 文件路径
 @param useAuxiliaryFile 是否是原子性
 @return 是否写入成功
 */
- (BOOL)mls_writeToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile;
@end
NS_ASSUME_NONNULL_END
