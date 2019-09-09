//
//  MLSBugReportNetworkModelManager.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSBugReportNetworkModelManager.h"
#import <MLSModel/MLSModel.h>
#import "MLSBugRepotRootModel.h"
@implementation MLSBugReportNetworkModelManager
+ (id)modelWithClass:(Class)modelClass isArray:(BOOL)isArray withJSON:(id)json {
    if (!json) {
        return nil;
    }
    if (modelClass == MLSBugRepotRootModel.class && [json isKindOfClass:NSDictionary.class] && [json objectForKey:@"status"] == nil) {
        MLSBugRepotRootModel *model = [[MLSBugRepotRootModel alloc] init];
        model.data = json;
        model.responseHeaderStatusCode = 200;
        model.status = @"success";
        return model;
    }
    if (isArray) {
        return [NSArray mls_modelArrayWithClass:modelClass json:json];
    }
    return [modelClass mls_modelWithJSON:json];
}
@end
