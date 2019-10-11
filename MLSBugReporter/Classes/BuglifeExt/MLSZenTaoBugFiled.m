//
//  MLSZenTaoBugFiled.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/12.
//  Copyright © 2019 minlison. All rights reserved.
//

#import "MLSZenTaoBugFiled.h"
#import <QMUIKit/QMUIKit.h>
#import "MLSBugReporterOptions.h"
#import "MLSBugReporterLoginViewController.h"
#import "Buglife.h"
#import "LIFEWhatHappenedTextView.h"
#import "LIFETextFieldCell.h"
NSString *zenTaoBugFiledTypeString(MLSZenTaoBugFiledType type);

@interface MLSZenTaoBugFiled () <LIFETextFieldCellDelegate, LIFEWhatHappenedTextViewDelegate>
@property (nonatomic, strong) NSDictionary <NSNumber *, NSString *>*typeAttributeNameDict;
@property (nonatomic, strong) QMUIOrderedDictionary *currentItems;
@property (nonatomic, weak) id<LIFETextFieldCellDelegate> preFieldCellDelegate;
@property (nonatomic, weak) id<LIFEWhatHappenedTextViewDelegate> preTextViewDelegate;
@end
@implementation MLSZenTaoBugFiled

- (instancetype)initWithType:(MLSZenTaoBugFiledType)type {
    if (self = [super initWithAttributeName:zenTaoBugFiledTypeString(type)]) {
        self.fieldType = type;
    }
    return self;
}
- (NSString *)placeholder {
    if (self.fieldType == MLSZenTaoBugFiledTypeBugSteps) {
        return @"[步骤]\n[结果]\n[期望]";
    }
    return zenTaoBugFiledTypeString(self.fieldType);
}
- (void)whatHappenedTextViewDidChange:(nonnull LIFEWhatHappenedTextView *)textView {
    
    if (self.preTextViewDelegate && [self.preTextViewDelegate respondsToSelector:@selector(whatHappenedTextViewDidChange:)]) {
        [self.preTextViewDelegate whatHappenedTextViewDidChange:textView];
    }
    if (self.fieldType == MLSZenTaoBugFiledTypeBugSteps) {
        MLSBugReporterOptions.shareOptions.bugModel.steps = textView.text;
    }
    [Buglife.sharedBuglife setStringValue:MLSBugReporterOptions.shareOptions.bugModel.mls_modelToJSONString forAttribute:@"bugModel"];
}
- (void)textFieldCellDidReturn:(nonnull LIFETextFieldCell *)textFieldCell {
    if (self.preFieldCellDelegate && [self.preFieldCellDelegate respondsToSelector:@selector(textFieldCellDidReturn:)]) {
        [self.preFieldCellDelegate textFieldCellDidReturn:textFieldCell];
    }
    if (self.fieldType == MLSZenTaoBugFiledTypeBugTitle) {
        MLSBugReporterOptions.shareOptions.bugModel.bugTitle = textFieldCell.textField.text;
    }
    [Buglife.sharedBuglife setStringValue:MLSBugReporterOptions.shareOptions.bugModel.mls_modelToJSONString forAttribute:@"bugModel"];
}
- (void)textFieldCellDidChange:(nonnull LIFETextFieldCell *)textFieldCell {
    if (self.preFieldCellDelegate && [self.preFieldCellDelegate respondsToSelector:@selector(textFieldCellDidChange:)]) {
        [self.preFieldCellDelegate textFieldCellDidChange:textFieldCell];
    }
    if (self.fieldType == MLSZenTaoBugFiledTypeBugTitle) {
        MLSBugReporterOptions.shareOptions.bugModel.bugTitle = textFieldCell.textField.text;
    }
    [Buglife.sharedBuglife setStringValue:MLSBugReporterOptions.shareOptions.bugModel.mls_modelToJSONString forAttribute:@"bugModel"];
    
}
- (void)setTextViewCell:(LIFEWhatHappenedTableViewCell *)textViewCell {
    [super setTextViewCell:textViewCell];
    self.preTextViewDelegate = textViewCell.textView.lifeDelegate;
    textViewCell.textView.lifeDelegate = self;
    [self setDefaultValue];
}
- (void)setTextFieldCell:(LIFETextFieldCell *)textFieldCell {
    [super setTextFieldCell:textFieldCell];
    self.preFieldCellDelegate = textFieldCell.delegate;
    textFieldCell.delegate = self;
    [self setDefaultValue];
}
- (BOOL)isRequired {
//    switch (self.fieldType) {
//        case MLSZenTaoBugFiledTypeProduct:
//        case MLSZenTaoBugFiledTypeModule:
//        case MLSZenTaoBugFiledTypeBuild:
//        case MLSZenTaoBugFiledTypeAsignTo:
//        case MLSZenTaoBugFiledTypeBugType:
//        case MLSZenTaoBugFiledTypeBugLevel:
//        case MLSZenTaoBugFiledTypeBugPriority:
//        case MLSZenTaoBugFiledTypeBugTitle:
//            return YES;
//        default:
//            return NO;
//            break;
//    }
    return YES;
}
- (void)setDefaultValue {
    MLSZenTaoBugModel *bugModel = MLSBugReporterOptions.shareOptions.bugModel;
    
    if (!bugModel) {
        return;
    }
    switch (self.fieldType) {
            case MLSZenTaoBugFiledTypeBugTitle: {
                NSString *value = bugModel.bugTitle;
                if (value.length == 0) {
                    break;
                }
                [Buglife.sharedBuglife setStringValue:value forAttribute:zenTaoBugFiledTypeString(self.fieldType)];
                [self setTextFieldValue:value];
                bugModel.productID = MLSBugReporterOptions.shareOptions.zentaoProductID.integerValue;
            }
                break;
        case MLSZenTaoBugFiledTypeProduct: {
            NSString *value = [bugModel.products objectForKey:MLSBugReporterOptions.shareOptions.zentaoProductID];
            [Buglife.sharedBuglife setStringValue:value forAttribute:zenTaoBugFiledTypeString(self.fieldType)];
            [self setTextFieldValue:value];
            bugModel.productID = MLSBugReporterOptions.shareOptions.zentaoProductID.integerValue;
        }
            break;
        case MLSZenTaoBugFiledTypeModule: {
            NSString *value = [bugModel.moduleOptionMenu objectForKey:MLSBugReporterOptions.shareOptions.zentaoModuleID];
            [Buglife.sharedBuglife setStringValue:value forAttribute:zenTaoBugFiledTypeString(self.fieldType)];
            [self setTextFieldValue:value];
            bugModel.moduleID = MLSBugReporterOptions.shareOptions.zentaoModuleID.integerValue;
        }
            break;
        case MLSZenTaoBugFiledTypeProject: {
            NSString *value = [bugModel.projects objectForKey:MLSBugReporterOptions.shareOptions.zentaoProjectID];
            [Buglife.sharedBuglife setStringValue:value forAttribute:zenTaoBugFiledTypeString(self.fieldType)];
            [self setTextFieldValue:value];
            bugModel.projectID = MLSBugReporterOptions.shareOptions.zentaoProjectID.integerValue;
            
        }
            break;
        case MLSZenTaoBugFiledTypeBuild: {
            NSString *value = [bugModel.builds objectForKey:MLSBugReporterOptions.shareOptions.zentaoOpenedBuild];
            [Buglife.sharedBuglife setStringValue:value forAttribute:zenTaoBugFiledTypeString(self.fieldType)];
            [self setTextFieldValue:value];
            bugModel.openedBuild = MLSBugReporterOptions.shareOptions.zentaoOpenedBuild;
        }
            break;
        case MLSZenTaoBugFiledTypeAsignTo: {
            
            NSString *value = [bugModel.projectMembers objectForKey:MLSBugReporterOptions.shareOptions.zentaoAsignUserID];
            [Buglife.sharedBuglife setStringValue:value forAttribute:zenTaoBugFiledTypeString(self.fieldType)];
            [self setTextFieldValue:value];
            bugModel.assignedTo = MLSBugReporterOptions.shareOptions.zentaoAsignUserID;
        }
            break;
        case MLSZenTaoBugFiledTypeBugType: {
            NSString *value = [bugModel.bugtypes objectForKey:MLSBugReporterOptions.shareOptions.zentaoBugTypeID];
            [Buglife.sharedBuglife setStringValue:value forAttribute:zenTaoBugFiledTypeString(self.fieldType)];
            [self setTextFieldValue:value];
            bugModel.type = MLSBugReporterOptions.shareOptions.zentaoBugTypeID;
        }
            break;
        case MLSZenTaoBugFiledTypeBugLevel: {
            NSString *value = [bugModel.severityList objectForKey:MLSBugReporterOptions.shareOptions.zentaoSeverityID];
            [Buglife.sharedBuglife setStringValue:value forAttribute:zenTaoBugFiledTypeString(self.fieldType)];
            [self setTextFieldValue:value];
            bugModel.severity = MLSBugReporterOptions.shareOptions.zentaoSeverityID.integerValue;
            
        }
            break;
        case MLSZenTaoBugFiledTypeBugPriority: {
            NSString *value = [bugModel.priList objectForKey:MLSBugReporterOptions.shareOptions.zentaoBugPriID];
            [Buglife.sharedBuglife setStringValue:value forAttribute:zenTaoBugFiledTypeString(self.fieldType)];
            [self setTextFieldValue:value];
            bugModel.pri = MLSBugReporterOptions.shareOptions.zentaoBugPriID;
        }
            break;
        default:
            break;
    }
}
- (void)endEditing {
    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj endEditing:YES];
    }];
}
- (BOOL)shouldBecomFirstResponsder {
    MLSZenTaoBugModel *bugModel = MLSBugReporterOptions.shareOptions.bugModel;
    if (bugModel == nil) {
        [MLSTipClass showLoadingInView:nil withText:@"更新数据..."];
        [MLSBugReporterLoginViewController getBugProductID:^(BOOL success, NSError *error) {
            if (success) {
                [MLSTipClass showSuccessWithText:@"更新成功..." inView:nil];
            } else {
                [MLSTipClass showErrorWithText:@"更新失败，请重试" inView:nil];
            }
        }];
        [self endEditing];
        return NO;
    }
    switch (self.fieldType) {
        case MLSZenTaoBugFiledTypeProduct: {
            // 选择产品
            self.currentItems = [[QMUIOrderedDictionary alloc] init];
            NSArray <NSString *>*keys = [bugModel.products keysSortedByValueUsingSelector:@selector(compare:)];
            [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.currentItems setObject:key forKey:[bugModel.products objectForKey:key]];
            }];
            NSString *value = [bugModel.products objectForKey:MLSBugReporterOptions.shareOptions.zentaoProductID];
            [self showSelectionWithTitle:@"产品列表" subTitle:@"选择所属产品" multipleSelection:NO selectedIndex:[self.currentItems.allKeys indexOfObject:value] items:self.currentItems.allKeys];
            [self endEditing];
        }
            return NO;
            break;
        case MLSZenTaoBugFiledTypeModule: {
            // 选择模块
            self.currentItems = [[QMUIOrderedDictionary alloc] init];
            NSArray <NSString *>*keys = [bugModel.moduleOptionMenu keysSortedByValueUsingSelector:@selector(compare:)];
            [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.currentItems setObject:key forKey:[bugModel.moduleOptionMenu objectForKey:key]];
            }];
            NSString *value = [bugModel.moduleOptionMenu objectForKey:MLSBugReporterOptions.shareOptions.zentaoModuleID];
            [self showSelectionWithTitle:@"所属模块" subTitle:@"选择模块名" multipleSelection:NO selectedIndex:[self.currentItems.allKeys indexOfObject:value] items:self.currentItems.allKeys];
            [self endEditing];
        }
            return NO;
            break;
        case MLSZenTaoBugFiledTypeProject: {
            // 选择项目
            self.currentItems = [[QMUIOrderedDictionary alloc] init];
            NSArray <NSString *>*keys = [bugModel.projects keysSortedByValueUsingSelector:@selector(compare:)];
            [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.currentItems setObject:key forKey:[bugModel.projects objectForKey:key]];
            }];
            NSString *value = [bugModel.projects objectForKey:MLSBugReporterOptions.shareOptions.zentaoProjectID];
            [self showSelectionWithTitle:@"所属项目" subTitle:@"选择项目名" multipleSelection:NO selectedIndex:[self.currentItems.allKeys indexOfObject:value] items:self.currentItems.allKeys];
            [self endEditing];
        }
            return NO;
            break;
        case MLSZenTaoBugFiledTypeBuild: {
            // 选择分支
            self.currentItems = [[QMUIOrderedDictionary alloc] init];
            NSArray <NSString *>*keys = [bugModel.builds keysSortedByValueUsingSelector:@selector(compare:)];
            [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.currentItems setObject:key forKey:[bugModel.builds objectForKey:key]];
            }];
            NSString *value = [bugModel.builds objectForKey:MLSBugReporterOptions.shareOptions.zentaoOpenedBuild];
            [self showSelectionWithTitle:@"影响版本" subTitle:@"选择版本" multipleSelection:NO selectedIndex:[self.currentItems.allKeys indexOfObject:value]  items:self.currentItems.allKeys];
            [self endEditing];
        }
            return NO;
            break;
        case MLSZenTaoBugFiledTypeAsignTo: {
            // 选择指派用户
            self.currentItems = [[QMUIOrderedDictionary alloc] init];
            NSArray <NSString *>*keys = [bugModel.projectMembers keysSortedByValueUsingSelector:@selector(compare:)];
            [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.currentItems setObject:key forKey:[bugModel.projectMembers objectForKey:key]];
            }];
            NSString *value = [bugModel.projectMembers objectForKey:MLSBugReporterOptions.shareOptions.zentaoAsignUserID];
            [self showSelectionWithTitle:@"当前指派" subTitle:@"指派人" multipleSelection:NO selectedIndex:[self.currentItems.allKeys indexOfObject:value] items:self.currentItems.allKeys];
            [self endEditing];
        }
            return NO;
            break;
        case MLSZenTaoBugFiledTypeBugType: {
            // 选择Bug 类型
            self.currentItems = [[QMUIOrderedDictionary alloc] init];
            
            NSArray <NSString *>*keys = [bugModel.bugtypes keysSortedByValueUsingSelector:@selector(compare:)];
            [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.currentItems setObject:key forKey:[bugModel.bugtypes objectForKey:key]];
            }];
            NSString *value = [bugModel.bugtypes objectForKey:MLSBugReporterOptions.shareOptions.zentaoBugTypeID];
            [self showSelectionWithTitle:@"Bug类型" subTitle:@"Bug类型" multipleSelection:NO selectedIndex:[self.currentItems.allKeys indexOfObject:value] items:self.currentItems.allKeys];
            [self endEditing];
        }
            return NO;
            break;
        case MLSZenTaoBugFiledTypeBugLevel: {
            // 选择 bug 严重程度
            self.currentItems = [[QMUIOrderedDictionary alloc] init];
            NSArray <NSString *>*keys = [bugModel.severityList keysSortedByValueUsingSelector:@selector(compare:)];
            [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.currentItems setObject:key forKey:[bugModel.severityList objectForKey:key]];
            }];
            NSString *value = [bugModel.severityList objectForKey:MLSBugReporterOptions.shareOptions.zentaoSeverityID];
            [self showSelectionWithTitle:@"Bug 严重程度" subTitle:@"Bug 严重程度" multipleSelection:NO selectedIndex:[self.currentItems.allKeys indexOfObject:value]  items:self.currentItems.allKeys];
            [self endEditing];
        }
            return NO;
            break;
        case MLSZenTaoBugFiledTypeBugPriority: {
            // 选择bug优先级
            self.currentItems = [[QMUIOrderedDictionary alloc] init];
            NSArray <NSString *>*keys = [bugModel.priList keysSortedByValueUsingSelector:@selector(compare:)];
            [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.currentItems setObject:key forKey:[bugModel.priList objectForKey:key]];
            }];
            NSString *value = [bugModel.priList objectForKey:MLSBugReporterOptions.shareOptions.zentaoBugPriID];
            [self showSelectionWithTitle:@"Bug 优先级" subTitle:@"Bug 优先级" multipleSelection:NO selectedIndex:[self.currentItems.allKeys indexOfObject:value] items:self.currentItems.allKeys];
            [self endEditing];
        }
            return NO;
            break;
        default:
            break;
    }
    return YES;
}


- (void)showSelectionWithTitle:(NSString *)title subTitle:(NSString *)subTitle multipleSelection:(BOOL)multipleSelection selectedIndex:(NSInteger)selectedIndex items:(NSArray <NSString *>*)items {
    QMUIDialogSelectionViewController *dialogViewController = [[QMUIDialogSelectionViewController alloc] init];
    dialogViewController.titleView.style = QMUINavigationTitleViewStyleSubTitleVertical;
    dialogViewController.title = title;
    dialogViewController.titleView.subtitle = subTitle;
    dialogViewController.allowsMultipleSelection = multipleSelection;// 打开多选
    dialogViewController.items = items;
    dialogViewController.selectedItemIndex = selectedIndex == NSNotFound ? QMUIDialogSelectionViewControllerSelectedItemIndexNone : selectedIndex;
    dialogViewController.didSelectItemBlock = ^(__kindof QMUIDialogSelectionViewController * _Nonnull aDialogViewController, NSUInteger itemIndex) {
        QMUIDialogSelectionViewController *d = (QMUIDialogSelectionViewController *)aDialogViewController;
        NSString *value = d.items[itemIndex];
        switch (self.fieldType) {
            case MLSZenTaoBugFiledTypeProduct: {
                MLSBugReporterOptions.shareOptions.bugModel.productID = [[self.currentItems objectForKey:value] integerValue];
            }
                break;
            case MLSZenTaoBugFiledTypeModule: {
                MLSBugReporterOptions.shareOptions.bugModel.moduleID = [[self.currentItems objectForKey:value] integerValue];
            }
                break;
            case MLSZenTaoBugFiledTypeProject: {
                MLSBugReporterOptions.shareOptions.bugModel.projectID = [[self.currentItems objectForKey:value] integerValue];
            }
                break;
            case MLSZenTaoBugFiledTypeBuild: {
                MLSBugReporterOptions.shareOptions.bugModel.openedBuild = [self.currentItems objectForKey:value];
            }
                break;
            case MLSZenTaoBugFiledTypeAsignTo: {
                MLSBugReporterOptions.shareOptions.bugModel.assignedTo = [self.currentItems objectForKey:value];
            }
                break;
            case MLSZenTaoBugFiledTypeBugType: {
                MLSBugReporterOptions.shareOptions.bugModel.type = [self.currentItems objectForKey:value];
            }
                break;
            case MLSZenTaoBugFiledTypeBugLevel: {
                MLSBugReporterOptions.shareOptions.bugModel.severity = [[self.currentItems objectForKey:value] integerValue];
            }
                break;
            case MLSZenTaoBugFiledTypeBugPriority: {
                MLSBugReporterOptions.shareOptions.bugModel.pri = [self.currentItems objectForKey:value];
            }
                break;
                
            default:
                break;
        }
        [self setTextFieldValue:value];
        [Buglife.sharedBuglife setStringValue:MLSBugReporterOptions.shareOptions.bugModel.mls_modelToJSONString forAttribute:@"bugModel"];
    };
    [dialogViewController addCancelButtonWithText:@"取消" block:nil];
    __weak __typeof(self)weakSelf = self;
    [dialogViewController addSubmitButtonWithText:@"确定" block:^(QMUIDialogViewController *aDialogViewController) {
        QMUIDialogSelectionViewController *d = (QMUIDialogSelectionViewController *)aDialogViewController;
        [d hide];
        
        self.currentItems = nil;
        // 保存当前选择的产品
        switch (self.fieldType) {
            case MLSZenTaoBugFiledTypeProduct: {
                MLSBugReporterOptions.shareOptions.zentaoProductID = @(MLSBugReporterOptions.shareOptions.bugModel.productID).stringValue;
            }
                break;
            case MLSZenTaoBugFiledTypeModule: {
                MLSBugReporterOptions.shareOptions.zentaoModuleID = @(MLSBugReporterOptions.shareOptions.bugModel.moduleID).stringValue;
            }
                break;
            case MLSZenTaoBugFiledTypeProject: {
                MLSBugReporterOptions.shareOptions.zentaoProjectID = @(MLSBugReporterOptions.shareOptions.bugModel.projectID).stringValue;
            }
                break;
            case MLSZenTaoBugFiledTypeBuild: {
                MLSBugReporterOptions.shareOptions.zentaoOpenedBuild = MLSBugReporterOptions.shareOptions.bugModel.openedBuild;
            }
                break;
            case MLSZenTaoBugFiledTypeAsignTo: {
                MLSBugReporterOptions.shareOptions.zentaoAsignUserID = MLSBugReporterOptions.shareOptions.bugModel.assignedTo;
            }
                break;
            case MLSZenTaoBugFiledTypeBugType: {
                MLSBugReporterOptions.shareOptions.zentaoBugTypeID = MLSBugReporterOptions.shareOptions.bugModel.type;
            }
                break;
            case MLSZenTaoBugFiledTypeBugLevel: {
                MLSBugReporterOptions.shareOptions.zentaoSeverityID = @(MLSBugReporterOptions.shareOptions.bugModel.severity).stringValue;
            }
                break;
            case MLSZenTaoBugFiledTypeBugPriority: {
                MLSBugReporterOptions.shareOptions.zentaoBugPriID = MLSBugReporterOptions.shareOptions.bugModel.pri;
            }
                break;
            default:
                break;
        }
        
        [MLSBugReporterOptions.shareOptions saveLocal];
    }];
    [dialogViewController show];
}
- (BOOL)isMultiline {
    return self.fieldType == MLSZenTaoBugFiledTypeBugSteps;
}


- (id)copyWithZone:(NSZone *)zone
{
    MLSZenTaoBugFiled *inputField = [super copyWithZone:zone];
    inputField.fieldType = self.fieldType;
    return inputField;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    MLSZenTaoBugFiled *other = (MLSZenTaoBugFiled *)object;
    
    return ([super isEqual:other]) && (self.fieldType == other.fieldType);
}
@end
NSString *zenTaoBugFiledTypeString(MLSZenTaoBugFiledType type) {
    static NSDictionary <NSNumber *, NSString *>*typeAttributeNameDict;
    if (typeAttributeNameDict == nil) {
        typeAttributeNameDict = @{@(MLSZenTaoBugFiledTypeProduct):@"所属产品",
                                  @(MLSZenTaoBugFiledTypeModule):@"所属模块",
                                  @(MLSZenTaoBugFiledTypeProject):@"所属项目",
                                  @(MLSZenTaoBugFiledTypeBuild):@"影响版本",
                                  @(MLSZenTaoBugFiledTypeAsignTo):@"指派给",
                                  @(MLSZenTaoBugFiledTypeEndTime):@"截止日期",
                                  @(MLSZenTaoBugFiledTypeBugType):@"Bug 类型",
                                  @(MLSZenTaoBugFiledTypeOSType):@"系统类型",
                                  @(MLSZenTaoBugFiledTypeBrowserType):@"浏览器类型",
                                  @(MLSZenTaoBugFiledTypeBugTitle):@"Bug 标题",
                                  @(MLSZenTaoBugFiledTypeBugLevel):@"Bug 严重级别",
                                  @(MLSZenTaoBugFiledTypeBugPriority):@"Bug 优先级",
                                  @(MLSZenTaoBugFiledTypeBugSteps):@"重现步骤",
                                  @(MLSZenTaoBugFiledTypeCopyTo):@"抄送",
                                  @(MLSZenTaoBugFiledTypeKeyWords):@"关键词",
                                  };
    }
    return typeAttributeNameDict[@(type)];
}
