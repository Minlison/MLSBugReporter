//
//  MLSZenTaoOSListModel.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSBugReporterBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLSZenTaoFieldListModel : MLSBugReporterBaseModel
@property (nonatomic , copy) NSString    * module;
@property (nonatomic , assign) BOOL       canAdd;
@property (nonatomic , copy) NSString    * currentLang;
@property (nonatomic , copy) NSString    * lang2Set;
@property (nonatomic , copy) NSString    * title;
@property (nonatomic , copy) NSString    * field;
@property (nonatomic , strong) NSDictionary <NSString *, NSString *> * fieldList;
@property (nonatomic , copy) NSString    * pager;
@end

NS_ASSUME_NONNULL_END
