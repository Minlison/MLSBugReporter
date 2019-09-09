//
//  MLSZenTaoBugModel.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/16.
//

#import "MLSZenTaoBugModel.h"

@implementation MLSZenTaoBugModel
- (NSDictionary<NSString *,NSString *> *)bugtypes {
    if (!_bugtypes) {
        _bugtypes = @{
                      @"codeerror": @"代码错误",
                      @"interface": @"界面优化",
                      @"config": @"配置相关",
                      @"install": @"安装部署",
                      @"security": @"安全相关",
                      @"performance": @"性能问题",
                      @"standard": @"标准规范",
                      @"automation": @"测试脚本",
                      @"others": @"其他",
                      @"designdefect": @"设计缺陷"
                      };
    }
    return _bugtypes;
}
- (NSDictionary<NSString *,NSString *> *)moduleOptionMenu {
    if (!_moduleOptionMenu || [_moduleOptionMenu.allKeys.firstObject isEqualToString:@""]) {
        _moduleOptionMenu = @{@"0" : @"/"};
    }
    return _moduleOptionMenu;
}
- (NSDictionary *)projects {
    if (!_projects || [_projects.allKeys.firstObject isEqualToString:@""]) {
        _projects = @{@"0": @"/"};
    }
    return _projects;
}
- (NSDictionary<NSString *,NSString *> *)builds {
    if (!_builds || [_builds.allKeys.firstObject isEqualToString:@""]) {
        _builds = @{@"0": @"/"};
    }
    return _builds;
}
- (NSDictionary<NSString *,NSString *> *)projectMembers {
    if (!_projectMembers) {
        _projectMembers = @{@"0" : @"/"};
    }
    return _projectMembers;
}

- (NSDictionary<NSString *,NSString *> *)priList {
    if (!_priList) {
        _priList = @{
            @"1": @"1",
            @"2": @"2",
            @"3": @"3",
            @"4": @"4"
        };
    }
    return _priList;
}
- (NSDictionary<NSString *,NSString *> *)severityList {
    if (!_severityList) {
        _severityList = @{
                     @"1": @"1",
                     @"2": @"2",
                     @"3": @"3",
                     @"4": @"4",
                     @"5" : @"优化",
                     @"6" : @"UI"
                     };
    }
    return _severityList;
}
- (NSString *)os {
    if (!_os || _os.length == 0) {
        _os = @"ios";
    }
    return _os;
}
@end
