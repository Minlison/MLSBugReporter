//
//  MLSBugReporterManager+Private.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/18.
//

#ifndef MLSBugReporterManager_Private_h
#define MLSBugReporterManager_Private_h
#import "MLSBugReporterManager.h"
#import "KSCrashReportFilter.h"
#import "Buglife.h"
#import "MLSZentaoDataProvider.h"
#import "Matrix.h"
@interface MLSBugReporterManager (Private)
@property (nonatomic, strong) MatrixIssue *matrixIssue;
@property (nonatomic, strong) MLSZentaoDataProvider *dataProvider;
+ (instancetype)sharedInstance;
@end

FOUNDATION_EXTERN const LIFEInvocationOptions LIFEInvocationOptionsCrashReport;
@interface Buglife (Private)
- (void)_presentReporterFromInvocation:(LIFEInvocationOptions)invocation withScreenshot:(UIImage *)screenshot animated:(BOOL)animated;
- (void)_presentAlertControllerForInvocation:(LIFEInvocationOptions)invocation withScreenshot:(UIImage *)screenshot;
@end
#endif /* MLSBugReporterManager_Private_h */
