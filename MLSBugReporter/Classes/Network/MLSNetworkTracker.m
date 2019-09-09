//
//  MLSNetworkTracker.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/26.
//

#import "MLSNetworkTracker.h"
#import "MLSFLEXNetworkRecorder.h"
#import "MLSBugReporterManager.h"
#import "MLSBugReporterOptions.h"
@implementation MLSNetworkTracker
+ (void)install {
    [self setUnTrackingNetworkURLFilter:[MLSBugReporterOptions shareOptions].unTrackingNetworkURLFilter];
    [MLSFLEXNetworkRecorder defaultRecorder].responseMaxLength = [MLSBugReporterOptions shareOptions].ressponseMaxLength;
    [MLSFLEXNetworkRecorder setEnabled:YES];
}
+ (void)uninstall {
    [MLSFLEXNetworkRecorder setEnabled:NO];
}
+ (void)setResponseMaxLength:(NSUInteger)maxLength {
    [MLSFLEXNetworkRecorder defaultRecorder].responseMaxLength = maxLength;
}
+ (void)setUnTrackingNetworkURLFilter:(NSString *)unTrackingNetworkURLFilter {
    NSMutableString *unTrackFilter = @"".mutableCopy;
    if (unTrackingNetworkURLFilter) {
        [unTrackFilter appendString:unTrackingNetworkURLFilter];
    }
    if (MLSBugReporterOptions.shareOptions.zentaoBaseUrl) {
        NSString *host = [NSURL URLWithString:MLSBugReporterOptions.shareOptions.zentaoBaseUrl].host;
        if (host && ![unTrackFilter containsString:host]) {
            unTrackFilter.length > 0 ? [unTrackFilter appendFormat:@"|%@",host] : [unTrackFilter appendString:host];
        }
    }
    [MLSFLEXNetworkRecorder defaultRecorder].unTrackingNetworkURLFilter = unTrackFilter;
}
+ (void)setTrackingNetworkURLFilter:(NSString *)trackingNetworkURLFilter {
    [MLSFLEXNetworkRecorder defaultRecorder].trackingNetworkURLFilter = trackingNetworkURLFilter;
}
@end
