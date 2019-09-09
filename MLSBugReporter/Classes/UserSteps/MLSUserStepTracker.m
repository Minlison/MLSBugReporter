//
//  MLSUserStepTracker.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/24.
//

#import "MLSUserStepTracker.h"
#import "MLSBugReportAspects.h"
#import "MLSBugLogger.h"
#import "MLSBugReporterOptions.h"
static NSMutableArray <id<MLSBugReportAspectToken>>*MLSUserStepTrackers;
@interface MLSUserStepTracker ()

@end
@implementation MLSUserStepTracker
+ (void)install {
    
    if (MLSUserStepTrackers == nil) {
        MLSUserStepTrackers = [NSMutableArray arrayWithCapacity:5];
    }
    NSError *error = nil;
    id<MLSBugReportAspectToken> token1 = [UIViewController MLS_bug_aspect_hookSelector:@selector(viewWillAppear:) withOptions:(MLSBugReportAspectPositionAfter) usingBlock:^(id <MLSBugReportAspectInfo> info){
        UIViewController *vc = info.instance;
        MLSBugLogUserTrack(@"- viewWillAppear Class:%@ -- Title:%@",NSStringFromClass(vc.class), vc.title);
    } error:nil];
    if (token1) {
        [MLSUserStepTrackers addObject:token1];
    }
    
    id<MLSBugReportAspectToken> token2 = [UIViewController MLS_bug_aspect_hookSelector:@selector(viewDidAppear:) withOptions:(MLSBugReportAspectPositionAfter) usingBlock:^(id <MLSBugReportAspectInfo> info){
        UIViewController *vc = info.instance;
        MLSBugLogUserTrack(@"- viewDidAppear Class:%@ -- Title:%@",NSStringFromClass(vc.class), vc.title);
    } error:nil];
    if (token2) {
        [MLSUserStepTrackers addObject:token2];
    }
    
    id<MLSBugReportAspectToken> token3 = [UIViewController MLS_bug_aspect_hookSelector:@selector(viewWillDisappear:) withOptions:(MLSBugReportAspectPositionAfter) usingBlock:^(id <MLSBugReportAspectInfo> info){
        UIViewController *vc = info.instance;
        MLSBugLogUserTrack(@"- viewWillDisappear Class:%@ -- Title:%@",NSStringFromClass(vc.class), vc.title);
    } error:nil];
    if (token3) {
        [MLSUserStepTrackers addObject:token3];
    }
    
    id<MLSBugReportAspectToken> token4 = [UIViewController MLS_bug_aspect_hookSelector:@selector(viewDidDisappear:) withOptions:(MLSBugReportAspectPositionAfter) usingBlock:^(id <MLSBugReportAspectInfo> info){
        UIViewController *vc = info.instance;
        MLSBugLogUserTrack(@"- viewDidDisappear Class:%@ -- Title:%@",NSStringFromClass(vc.class), vc.title);
    } error:nil];
    if (token4) {
        [MLSUserStepTrackers addObject:token4];
    }
    
    id<MLSBugReportAspectToken> token5 = [UIControl MLS_bug_aspect_hookSelector:@selector(touchesEnded:withEvent:) withOptions:(MLSBugReportAspectPositionAfter) usingBlock:^(id <MLSBugReportAspectInfo> info) {
        [self controlAction:info];
    } error:nil];
    if (token5) {
        [MLSUserStepTrackers addObject:token5];
    }
}

+ (void)controlAction:(id <MLSBugReportAspectInfo>)info {
    UIControl *control = info.instance;
    if ([control isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)control;
        MLSBugLogUserTrack(@"Button tapped: %@", btn.currentTitle ?: btn);
    } else if ([self isKindOfClass:[UIPageControl class]]) {
        UIPageControl *pcSelf = (UIPageControl *)control;
        MLSBugLogUserTrack(@"Page control activated. Current Page: %zd, number of pages: %zd", pcSelf.currentPage, pcSelf.numberOfPages);
    } else if ([self isKindOfClass:[UISwitch class]]) {
        UISwitch *switchSelf = (UISwitch *)control;
        MLSBugLogUserTrack(@"Switch toggled to: %@", switchSelf.on ? @"ON" : @"OFF");
    } else if ([self isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *scSelf = (UISegmentedControl *)control;
        MLSBugLogUserTrack(@"Segmented control index selected: %zd", scSelf.selectedSegmentIndex);
    } else {
        MLSBugLogUserTrack(@"Got an action: %@, arguments: %@ originalInvocation: %@", control, info.arguments, info.originalInvocation);
    }

}

+ (void)unInstall {
    if (MLSUserStepTrackers) {
        [MLSUserStepTrackers enumerateObjectsUsingBlock:^(id<MLSBugReportAspectToken>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj remove];
        }];
        [MLSUserStepTrackers removeAllObjects];
    }
}
+ (NSString *)getLoggFile {
    return [MLSBugLogger getLogPathWithType:(MLSBugLogTypeUserTrack)];
}
@end
