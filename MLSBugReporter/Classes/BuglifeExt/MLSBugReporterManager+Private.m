//
//  MLSBugReporterManager+Private.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/24.
//

#import "MLSBugReporterManager+Private.h"
#import "LIFESwizzler.h"
#import "LIFEReportOwner.h"
#import <objc/runtime.h>
@interface Buglife (MLSProvicer)
@end


@implementation Buglife (MLSProvicer)

+ (void)load {
    [LIFESwizzler instanceSwizzleFromClass:Buglife.class andMethod:@selector(dataProvider) toClass:Buglife.class andMethod:@selector(zentaoDataProvider)];
}

- (MLSZentaoDataProvider *)zentaoDataProvider {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj ) {
        return obj;
    }
    LIFEReportOwner *owner = [LIFEReportOwner reportOwnerWithEmail:@"yuanhang@minlison.com"];
    MLSZentaoDataProvider *provider = [[MLSZentaoDataProvider alloc] initWithReportOwner:owner SDKVersion:[Buglife sharedBuglife].version];
    objc_setAssociatedObject(self, _cmd, provider, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return obj;
}

@end
