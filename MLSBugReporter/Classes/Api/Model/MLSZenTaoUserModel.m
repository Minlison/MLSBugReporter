//
//  MLSZenTaoUserModel.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSZenTaoUserModel.h"
@implementation MLSUserRightsDetailModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"t_release" : @"release"};
}
@end
@implementation MLSUserRightsAclsModel
@end
@implementation MLSBRUserRightsModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"rights" : MLSUserRightsDetailModel.class, @"acls" : MLSUserRightsAclsModel.class };
}
@end
@implementation MLSZenTaoUserModel
+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"rights" : MLSBRUserRightsModel.class};
}
@end
