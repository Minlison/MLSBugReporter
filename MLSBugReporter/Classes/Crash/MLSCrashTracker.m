//
//  MLSCrashTracker.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/26.
//

#import "MLSCrashTracker.h"
#import "Matrix.h"
#import "WCCrashBlockFileHandler.h"
#import "MLSBugLogger.h"
#import "MLSBugReporterOptions.h"
#import "MLSBugReporterManager.h"
// filter
#import "KSCrashReportFilterAppleFmt.h"
#import "KSCrashReportFilterBasic.h"
#import "KSCrashReportFilterGZip.h"
#import "KSCrashReportFilterJSON.h"
#import "WCCrashBlockJsonUtil.h"
#import "KSReachabilityKSCrash.h"

#import "MLSBugReporterLoginViewController.h"
#import <MLSUICore/MLSUICore.h>

#import "MLSBugReporterManager+Private.h"
// 追加用户信息
void MLS_bug_kscrash_crashCallback(const KSCrashReportWriter *writer)
{
    // 用户名
    writer->beginObject(writer, "WeChat-MLSBugReporter");
    // 添加用户属性
    writer->addUIntegerElement(writer, "uin", 21002);
    writer->endContainer(writer);
}
@interface MLSCrashTracker () <WCCrashBlockMonitorDelegate, MatrixAdapterDelegate, MatrixPluginListenerDelegate>
@property (nonatomic, strong) WCCrashBlockMonitorPlugin *m_cbPlugin;
@property (nonatomic, strong) WCMemoryStatPlugin *m_msPlugin;
@property (nonatomic, strong) KSReachableOperationKSCrash *reachableOperation;
@end
@implementation MLSCrashTracker

+ (void)install {
    [[self sharedInstance] installMatrix];
}
+ (void)unInstall {
    [[self sharedInstance] unInstallMatrix];
}

+ (MLSCrashTracker *)sharedInstance
{
    static MLSCrashTracker *g_handler = nil;
    static dispatch_once_t crashTrackerOnceToken;
    dispatch_once(&crashTrackerOnceToken, ^{
        g_handler = [[MLSCrashTracker alloc] init];
    });
    
    return g_handler;
}

- (void)unInstallMatrix {
    [MatrixAdapter sharedInstance].delegate = nil;
    [self.m_cbPlugin destroy];
    [self.m_msPlugin destroy];
    self.m_cbPlugin = nil;
    self.m_msPlugin = nil;
}
- (void)installMatrix
{
    // Get Matrix's log
    //    [MatrixAdapter sharedInstance].delegate = self;
    
    Matrix *matrix = [Matrix sharedInstance];
//    return;
    MatrixBuilder *curBuilder = [[MatrixBuilder alloc] init];
    curBuilder.pluginListener = self;

    WCCrashBlockMonitorConfig *crashBlockConfig = [[WCCrashBlockMonitorConfig alloc] init];
    crashBlockConfig.appVersion = MLSBugReporterOptions.shareOptions.version;
    crashBlockConfig.appShortVersion = MLSBugReporterOptions.shareOptions.build;
    crashBlockConfig.enableCrash = YES;
    crashBlockConfig.enableBlockMonitor = YES;
    crashBlockConfig.blockMonitorDelegate = self;
    crashBlockConfig.onAppendAdditionalInfoCallBack = MLS_bug_kscrash_crashCallback;
    crashBlockConfig.reportStrategy = EWCCrashBlockReportStrategy_All;

    WCBlockMonitorConfiguration *blockMonitorConfig = [WCBlockMonitorConfiguration defaultConfig];
    blockMonitorConfig.bMainThreadHandle = YES;
    blockMonitorConfig.bFilterSameStack = YES;
    blockMonitorConfig.triggerToBeFilteredCount = 10;
    crashBlockConfig.blockMonitorConfiguration = blockMonitorConfig;

    WCCrashBlockMonitorPlugin *crashBlockPlugin = [[WCCrashBlockMonitorPlugin alloc] init];
    crashBlockPlugin.pluginConfig = crashBlockConfig;
    [curBuilder addPlugin:crashBlockPlugin];

    WCMemoryStatPlugin *memoryStatPlugin = [[WCMemoryStatPlugin alloc] init];
    memoryStatPlugin.pluginConfig = [WCMemoryStatConfig defaultConfiguration];
    [curBuilder addPlugin:memoryStatPlugin];
    
    [matrix addMatrixBuilder:curBuilder];
    
    [crashBlockPlugin start];
    [memoryStatPlugin start];

    self.m_cbPlugin = crashBlockPlugin;
    self.m_msPlugin = memoryStatPlugin;
}

// ============================================================================
#pragma mark - MatrixPluginListenerDelegate
// ============================================================================

- (void)onReportIssue:(MatrixIssue *)issue
{
    __weak __typeof(self)weakSelf = self;
    self.reachableOperation = [KSReachableOperationKSCrash operationWithHost:@"http://www.baidu.com"
                                                                   allowWWAN:YES
                                                                       block:^
                               {
                                   __strong __typeof(weakSelf)strongSelf = weakSelf;
                                   [strongSelf _onReportIssue:issue];
                               }];
}

- (void)_onReportIssue:(MatrixIssue *)issue {
    NSString *currentTilte = nil;
    BOOL toAppleFormat = NO;
    if ([issue.issueTag isEqualToString:[WCCrashBlockMonitorPlugin getTag]]) {
        if (issue.reportType == EMCrashBlockReportType_Lag) {
            NSMutableString *lagTitle = [@"Lag" mutableCopy];
            if (issue.customInfo != nil) {
                NSString *dumpTypeDes = @"";
                NSNumber *dumpType = [issue.customInfo objectForKey:@g_crash_block_monitor_custom_dump_type];
                switch (dumpType.integerValue) {
                    case EDumpType_MainThreadBlock:
                        dumpTypeDes = @"Foreground Main Thread Block";
                        break;
                    case EDumpType_BackgroundMainThreadBlock:
                        dumpTypeDes = @"Background Main Thread Block";
                        break;
                    case EDumpType_CPUBlock:
                        dumpTypeDes = @"CPU Too High";
                        break;
//                    case EDumpType_CPUIntervalHigh:
//                        dumpTypeDes = @"CPU Interval High";
//                        break;
                    case EDumpType_LaunchBlock:
                        dumpTypeDes = @"Launching Main Thread Block";
                        break;
                    case EDumpType_BlockThreadTooMuch:
                        dumpTypeDes = @"Block And Thread Too Much";
                        break;
                    case EDumpType_BlockAndBeKilled:
                        dumpTypeDes = @"Main Thread Block Before Be Killed";
                        break;
                    default:
                        dumpTypeDes = [NSString stringWithFormat:@"%d", [dumpType intValue]];
                        break;
                }
                [lagTitle appendFormat:@" [%@]", dumpTypeDes];
            }
            currentTilte = [lagTitle copy];
        } else if (issue.reportType == EMCrashBlockReportType_Crash) {
            currentTilte = @"Crash";
        }
        toAppleFormat = YES;
    } else if ([issue.issueTag isEqualToString:[WCMemoryStatPlugin getTag]]) {
        currentTilte = @"OOM Info";
        toAppleFormat = YES;
    }
    [self _reportIssueToZentao:issue title:currentTilte toAppleFormat:toAppleFormat];
}

- (void)_reportIssueToZentao:(MatrixIssue *)issue title:(NSString *)title toAppleFormat:(BOOL)toAppleFormat {
    
    NSMutableArray *zentaoFilterReports = [NSMutableArray arrayWithCapacity:4];
    id <KSCrashReportFilter> filter = nil;
    
    NSData *data = nil;
    if (issue.dataType == EMatrixIssueDataType_Data) {
        data = issue.issueData;
    } else if (issue.dataType == EMatrixIssueDataType_FilePath && issue.filePath) {
        data = [NSData dataWithContentsOfFile:issue.filePath];
    }
    
    if (data == nil) {
        [[Matrix sharedInstance] reportIssueComplete:issue success:YES];
        return;
    }
    NSMutableArray *waitFilterReports = [NSMutableArray arrayWithCapacity:4];
    NSError *error = nil;
    // decode json
    id jsonReport = [WCCrashBlockJsonUtil jsonDecode:data withError:&error];
    
    if (toAppleFormat && !error) {
        if ([jsonReport isKindOfClass:NSDictionary.class]) {
            [waitFilterReports addObject:jsonReport];
        } else if ([jsonReport isKindOfClass:NSArray.class]) {
            [waitFilterReports addObjectsFromArray:jsonReport];
        }
        filter = [self defaultCrashReportFilterSetAppleFmt];
    } else {
        [waitFilterReports addObject:data];
        filter = [self dataZipCrashReportFilterSet];
    }
    // 转 apple 日志 格式，压缩
    [filter filterReports:waitFilterReports onCompletion:^(NSArray *filteredReports, BOOL completed, NSError *error) {
        [zentaoFilterReports addObjectsFromArray:filteredReports];
    }];
    if (zentaoFilterReports.count == 0) {
        [[Matrix sharedInstance] reportIssueComplete:issue success:NO];
        return;
    }
    [self _reportIssueToZentao:issue title:title reports:zentaoFilterReports];
    
}
// 上传report
- (void)_reportIssueToZentao:(MatrixIssue *)issue title:(NSString *)title reports:(NSArray *)reports {
    if (MLSBugReporterOptions.shareOptions.configModel.sessionID.length <= 0) {
        [MLSBugReporterLoginViewController showIfNeedAndLoginCompletion:^(BOOL success, NSError * _Nonnull error) {
            if (success) {
                [self sendToZenTaoWithIssue:issue title:title reports:reports];
            } else {
                [[Matrix sharedInstance] reportIssueComplete:issue success:NO];
            }
        }];
        return;
    }
    [MLSTipClass showLoading];
    [MLSBugReporterLoginViewController getBugProductID:^(BOOL success, NSError *error) {
        [MLSTipClass hideLoading];
        if (!success) {
            [MLSBugReporterLoginViewController showIfNeedAndLoginCompletion:^(BOOL success, NSError * _Nonnull error) {
                if (success) {
                    [self sendToZenTaoWithIssue:issue title:title reports:reports];
                } else {
                    [[Matrix sharedInstance] reportIssueComplete:issue success:NO];
                }
            }];
            [MLSTipClass showErrorWithText:error.localizedDescription inView:nil];
        } else {
            [self sendToZenTaoWithIssue:issue title:title reports:reports];
        }
    }];
}


- (void)sendToZenTaoWithIssue:(MatrixIssue *)issue
                        title:(NSString *)title
                      reports:(NSArray *) reports {
    
    [MLSTipClass showLoadingInView:nil withText:@"检测到上次崩溃，正在更新..."];
    [MLSBugReporterLoginViewController getBugProductID:^(BOOL success, NSError * _Nonnull error) {
        [MLSTipClass hideLoadingInView:nil];
        if (success) {
            if (reports.count > 1) {
                [reports enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [Buglife.sharedBuglife addAttachmentWithData:obj type:LIFEAttachmentTypeIdentifierCrashText filename:[NSString stringWithFormat:@"%@-report-%d.log.gz",title,idx] error:nil];
                }];
            } else {
                [Buglife.sharedBuglife addAttachmentWithData:reports.firstObject type:LIFEAttachmentTypeIdentifierCrashText filename:[NSString stringWithFormat:@"%@-report.log.gz",title] error:nil];
            }
            // 因为是崩溃，所以改变优先级为1
            MLSBugReporterManager.sharedInstance.matrixIssue = issue;
            MLSBugReporterOptions.shareOptions.zentaoBugPriID = @"1";
            MLSBugReporterOptions.shareOptions.zentaoSeverityID = @"1";
            [Buglife.sharedBuglife _presentAlertControllerForInvocation:LIFEInvocationOptionsCrashReport withScreenshot:nil];
        } else {
            [MLSTipClass showErrorWithText:error.localizedDescription inView:nil];
            [[Matrix sharedInstance] reportIssueComplete:issue success:NO];
        }
    }];
}
// ============================================================================
#pragma mark - WCCrashBlockMonitorDelegate
// ============================================================================

- (void)onCrashBlockMonitorBeginDump:(EDumpType)dumpType blockTime:(uint64_t)blockTime
{
    
}

- (void)onCrashBlockMonitorEnterNextCheckWithDumpType:(EDumpType)dumpType
{
    if (dumpType != EDumpType_MainThreadBlock || dumpType != EDumpType_BackgroundMainThreadBlock) {
    }
}

- (void)onCrashBlockMonitorDumpType:(EDumpType)dumpType filter:(EFilterType)filterType
{
    NSLog(@"filtered dump type:%u, filter type: %u", (uint32_t)dumpType, (uint32_t)filterType);
}

- (void)onCrashBlockMonitorDumpFilter:(EDumpType)dumpType
{
    
}

- (NSDictionary *)onCrashBlockGetUserInfoForFPSWithDumpType:(EDumpType)dumpType
{
    return nil;
}

// ============================================================================
#pragma mark - MatrixAdapterDelegate
// ============================================================================

- (BOOL)matrixShouldLog:(MXLogLevel)level {
    return NO;
}

- (void)matrixLog:(MXLogLevel)logLevel
           module:(const char *)module
             file:(const char *)file
             line:(int)line
         funcName:(const char *)funcName
          message:(NSString *)message
{
    MLSBugLogDefault(@"%@:%@:%@:%@",
          [NSString stringWithUTF8String:module],[NSString stringWithUTF8String:file],[NSString stringWithUTF8String:funcName], message);
}


- (id <KSCrashReportFilter>) defaultCrashReportFilterSetAppleFmt
{
    if (MLSBugReporterOptions.shareOptions.crashlogFmt == MLSCrashLogFormatAppleFmt) {
        return [KSCrashReportFilterPipeline filterWithFilters:
                [KSCrashReportFilterAppleFmt filterWithReportStyle:KSAppleReportStyleSymbolicatedSideBySide],
                [KSCrashReportFilterStringToData filter],
                [KSCrashReportFilterGZipCompress filterWithCompressionLevel:-1],
                nil];
    } else {
        return [KSCrashReportFilterPipeline filterWithFilters:
                [KSCrashReportFilterJSONEncode filterWithOptions:(KSJSONEncodeOptionPretty | KSJSONEncodeOptionSorted)],
                [KSCrashReportFilterGZipCompress filterWithCompressionLevel:-1],
                nil];
    }
}

- (id <KSCrashReportFilter>)dataZipCrashReportFilterSet
{
    return [KSCrashReportFilterPipeline filterWithFilters:
            [KSCrashReportFilterGZipCompress filterWithCompressionLevel:-1],
            nil];
}
@end
