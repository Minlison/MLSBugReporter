//
//  MLSZenTaoUserModel.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All MLSBRUserRightsModel reserved.
//

#import "MLSBugReporterBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLSUserRightsDetailModel : MLSBugReporterBaseModel
@property (nonatomic, strong) NSDictionary *action;
@property (nonatomic, strong) NSDictionary *api;
@property (nonatomic, strong) NSDictionary *bug;
@property (nonatomic, strong) NSDictionary *build;
@property (nonatomic, strong) NSDictionary *company;
@property (nonatomic, strong) NSDictionary *doc;
@property (nonatomic, strong) NSDictionary *file;
@property (nonatomic, strong) NSDictionary *git;
@property (nonatomic, strong) NSDictionary *group;
@property (nonatomic, strong) NSDictionary *index;
@property (nonatomic, strong) NSDictionary *misc;
@property (nonatomic, strong) NSDictionary *my;
@property (nonatomic, strong) NSDictionary *product;
@property (nonatomic, strong) NSDictionary *productplan;
@property (nonatomic, strong) NSDictionary *project;
@property (nonatomic, strong) NSDictionary *qa;
@property (nonatomic, strong) NSDictionary *t_release;
@property (nonatomic, strong) NSDictionary *report;
@property (nonatomic, strong) NSDictionary *search;
@property (nonatomic, strong) NSDictionary *story;
@property (nonatomic, strong) NSDictionary *svn;
@property (nonatomic, strong) NSDictionary *task;
@property (nonatomic, strong) NSDictionary *testcase;
@property (nonatomic, strong) NSDictionary *testsuite;
@property (nonatomic, strong) NSDictionary *testtask;
@property (nonatomic, strong) NSDictionary *todo;
@property (nonatomic, strong) NSDictionary *user;
@end

@interface MLSUserRightsAclsModel : MLSBugReporterBaseModel
@property (nonatomic, strong) NSDictionary *products;
@property (nonatomic, strong) NSDictionary *projects;
@property (nonatomic, strong) NSDictionary *views;
@end

@interface MLSBRUserRightsModel : MLSBugReporterBaseModel

@property (nonatomic , strong) MLSUserRightsDetailModel * rights;
@property (nonatomic , strong) MLSUserRightsAclsModel * acls;

@end
@interface MLSZenTaoUserModel : MLSBugReporterBaseModel
@property (nonatomic , copy) NSString              * scoreLevel;
@property (nonatomic , copy) NSString              * id;
@property (nonatomic , copy) NSString              * company;
@property (nonatomic , assign) BOOL              admin;
@property (nonatomic , copy) NSString              * zipcode;
@property (nonatomic , copy) NSString              * address;
@property (nonatomic , copy) NSString              * skype;
@property (nonatomic , copy) NSString              * locked;
@property (nonatomic , copy) NSString              * dept;
@property (nonatomic , copy) NSString              * nickname;
@property (nonatomic , copy) NSString              * realname;
@property (nonatomic , copy) NSString              * account;
@property (nonatomic , copy) NSString              * score;
@property (nonatomic , copy) NSArray <NSString *> * groups;
@property (nonatomic , copy) NSString              * role;
@property (nonatomic , copy) NSString              * yahoo;
@property (nonatomic , copy) NSString              * wangwang;
@property (nonatomic , copy) NSString              * email;
@property (nonatomic , assign) BOOL              modifyPassword;
@property (nonatomic , copy) NSString              * birthday;
@property (nonatomic , copy) NSString              * commiter;
@property (nonatomic , copy) NSString              * join;
@property (nonatomic , strong) MLSBRUserRightsModel      * rights;
@property (nonatomic , copy) NSString              * avatar;
@property (nonatomic , copy) NSString              * mobile;
@property (nonatomic , copy) NSString              * ranzhi;
@property (nonatomic , copy) NSString              * fails;
@property (nonatomic , copy) NSString              * lastTime;
@property (nonatomic , copy) NSString              * gender;
@property (nonatomic , copy) NSString              * qq;
@property (nonatomic , copy) NSString              * gtalk;
@property (nonatomic , copy) NSString              * ip;
@property (nonatomic , copy) NSString              * phone;
@property (nonatomic , copy) NSString              * visits;
@property (nonatomic , copy) NSString              * last;

@end

NS_ASSUME_NONNULL_END
