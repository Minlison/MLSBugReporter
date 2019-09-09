//
//  MLSZenTaoBugModel.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/16.
//

#import "MLSBugReporterBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLSZenTaoBugModel : MLSBugReporterBaseModel
@property (nonatomic , assign) NSInteger              runID;
@property (nonatomic , copy) NSDictionary<NSString *, NSString *>  * moduleOptionMenu;
@property (nonatomic , assign) NSInteger              severity;
// key: yuanhang value:Y:yuanhang
@property (nonatomic , strong) NSDictionary <NSString *, NSString *>* users;
@property (nonatomic , copy) NSString              * steps;
@property (nonatomic , assign) NSInteger              caseID;
// key:trunk value:主干
@property (nonatomic , strong) NSDictionary              <NSString *, NSString *>* builds;
// key:project value:所属项目
@property (nonatomic , strong) NSDictionary              * customFields;
@property (nonatomic , assign) NSInteger              testtask;
@property (nonatomic , assign) NSInteger              taskID;
@property (nonatomic , assign) NSInteger              version;
// 项目内成员 key:yuanhang value:Y:yuanhang
@property (nonatomic , strong) NSDictionary              <NSString *, NSString *>* projectMembers;
@property (nonatomic , copy) NSString              * type;
@property (nonatomic , copy) NSString              * pager;
@property (nonatomic , strong) NSDictionary              * projects;
@property (nonatomic , assign) NSInteger              storyID;
@property (nonatomic , assign) NSInteger              branch;
@property (nonatomic , copy) NSString              * browser;
@property (nonatomic , copy) NSString              * showFields;
@property (nonatomic , copy) NSArray<NSString *>   * branches;
@property (nonatomic , copy) NSString              * color;
@property (nonatomic , assign) NSInteger              projectID;
@property (nonatomic , copy) NSString              * os;
@property (nonatomic , assign) NSInteger              productID;
@property (nonatomic , copy) NSString              * pri;
@property (nonatomic , copy) NSString              * productName;
@property (nonatomic , copy) NSString              * mailto;
@property (nonatomic , copy) NSArray<NSString *>   * stories;
@property (nonatomic , copy) NSString              * keywords;
// key:1 value:NCEE
@property (nonatomic , strong) NSDictionary        <NSString *, NSString *>* products;
@property (nonatomic , copy) NSString              * assignedTo;
@property (nonatomic , copy) NSString              * title;
@property (nonatomic , assign) NSInteger              buildID;
@property (nonatomic , copy) NSString              * bugTitle;
@property (nonatomic , copy) NSString              * deadline;
@property (nonatomic , assign) NSInteger              moduleID;
// 影响版本
@property (nonatomic, copy) NSString *openedBuild;
// bug 类型
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *bugtypes;
// bug 优先级
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *priList;
// bug 严重程度列表
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *severityList;
@end

NS_ASSUME_NONNULL_END
