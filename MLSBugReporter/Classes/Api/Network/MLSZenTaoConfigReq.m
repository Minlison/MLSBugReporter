//
//  MLSZenTaoConfigReq.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSZenTaoConfigReq.h"

@implementation MLSZenTaoConfigReq
- (NSDictionary *)otherQueryParams {
    return @{@"mode" : @"getconfig"};
}
- (Class)modelClass {
    return MLSZentaoConfigModel.class;
}
@end
