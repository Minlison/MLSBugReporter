//
//  MLSZentaoConfigModel.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSBugReporterBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLSZentaoConfigModel : MLSBugReporterBaseModel
@property (nonatomic , assign) NSInteger random;
@property (nonatomic , copy) NSString    * version;
@property (nonatomic , copy) NSString    * expiredTime;
@property (nonatomic , copy) NSString    * sessionVar;
@property (nonatomic , copy) NSString    * sessionName;
@property (nonatomic , copy) NSString    * requestFix;
@property (nonatomic , assign) NSInteger    rand;
@property (nonatomic , copy) NSString    * methodVar;
@property (nonatomic , copy) NSString    * requestType;
@property (nonatomic , assign) NSInteger    serverTime;
@property (nonatomic , copy) NSString    * viewVar;
@property (nonatomic , copy) NSString    * moduleVar;
@property (nonatomic , copy) NSString    * sessionID;
@end

NS_ASSUME_NONNULL_END
