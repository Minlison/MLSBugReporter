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
@property(nonatomic, assign, getter=isReporting) BOOL reporting;
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
    blockMonitorConfig.bGetCPUHighLog = NO;
    blockMonitorConfig.bGetPowerConsumeStack = YES;
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
    if (Buglife.sharedBuglife.isReporting || self.isReporting) {
        return;
    }
    self.reporting = YES;
    NSString *currentTilte = nil;
    BOOL toAppleFormat = NO;
    if ([issue.issueTag isEqualToString:[WCCrashBlockMonitorPlugin getTag]]) {
        if (issue.reportType == EMCrashBlockReportType_Lag) {
            NSMutableString *lagTitle = [@"Lag" mutableCopy];
            NSString *dumpTypeDes = @"";
            if (issue.customInfo != nil) {
                NSNumber *dumpType = [issue.customInfo objectForKey:@g_crash_block_monitor_custom_dump_type];
                switch (dumpType.integerValue) {
                    case EDumpType_MainThreadBlock:
                        dumpTypeDes = @"前台主线程阻塞";
                        break;
                    case EDumpType_BackgroundMainThreadBlock:
                        dumpTypeDes = @"后台主线程阻塞";
                        break;
                    case EDumpType_CPUBlock:
                        dumpTypeDes = @"CPU 占用率太高";
                        break;
//                    case EDumpType_CPUIntervalHigh:
//                        dumpTypeDes = @"CPU Interval High";
//                        break;
                    case EDumpType_LaunchBlock:
                        dumpTypeDes = @"启动时主线程阻塞";
                        break;
                    case EDumpType_BlockThreadTooMuch:
                        dumpTypeDes = @"阻塞线程数过多";
                        break;
                    case EDumpType_BlockAndBeKilled:
                        dumpTypeDes = @"主线程阻塞被杀死";
                        break;
                        case EDumpType_PowerConsume:
                        dumpTypeDes = @"电池耗电过高";
                        break;

                    default:
                        dumpTypeDes = [NSString stringWithFormat:@"%d", [dumpType intValue]];
                        break;
                }
                [lagTitle appendFormat:@" [%@]", dumpTypeDes];
            }
            currentTilte = dumpTypeDes;
        } else if (issue.reportType == EMCrashBlockReportType_Crash) {
            currentTilte = @"闪退";
        }
        toAppleFormat = YES;
    } else if ([issue.issueTag isEqualToString:[WCMemoryStatPlugin getTag]]) {
        currentTilte = @"OOM 内存泄漏";
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
        self.reporting = NO;
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
        self.reporting = NO;
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
                self.reporting = NO;
            }
        }];
        return;
    }
    NSString *tipString = [NSString stringWithFormat:@"检测到%@问题，正在处理...",title];
    [MLSTipClass showLoadingInView:nil withText:tipString];
    [MLSBugReporterLoginViewController getBugProductID:^(BOOL success, NSError *error) {
        
        if (!success) {
            [MLSTipClass hideLoading];
            [MLSBugReporterLoginViewController showIfNeedAndLoginCompletion:^(BOOL success, NSError * _Nonnull error) {
                if (success) {
                    [self sendToZenTaoWithIssue:issue title:title reports:reports];
                } else {
                    [[Matrix sharedInstance] reportIssueComplete:issue success:NO];
                    self.reporting = NO;
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
    [MLSBugReporterLoginViewController getBugProductID:^(BOOL success, NSError * _Nonnull error) {
        [MLSTipClass hideLoadingInView:nil];
        if (success) {
            if (reports.count > 1) {
                [reports enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [Buglife.sharedBuglife addAttachmentWithData:obj type:LIFEAttachmentTypeIdentifierCrashText filename:[NSString stringWithFormat:@"%@-report-%d.log.gz",title,(int)idx] error:nil];
                }];
            } else {
                [Buglife.sharedBuglife addAttachmentWithData:reports.firstObject type:LIFEAttachmentTypeIdentifierCrashText filename:[NSString stringWithFormat:@"%@-report.log.gz",title] error:nil];
            }
            MLSBugReporterManager.sharedInstance.matrixIssue = issue;
            // 因为是崩溃，所以改变优先级为 1
            if (issue.reportType == EMCrashBlockReportType_Crash) {
                MLSBugReporterOptions.shareOptions.zentaoBugPriID = @"1";
                MLSBugReporterOptions.shareOptions.zentaoSeverityID = @"1";
            }
            NSString *appName = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"];
            MLSBugReporterOptions.shareOptions.bugModel.bugTitle = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",MLSBugReporterOptions.shareOptions.zentaoProductName,appName,MLSBugReporterOptions.shareOptions.version,MLSBugReporterOptions.shareOptions.build,title];
            [Buglife.sharedBuglife presentReporterWithInvocation:LIFEInvocationOptionsCrashReport];
        } else {
            [MLSTipClass showErrorWithText:error.localizedDescription inView:nil];
            [[Matrix sharedInstance] reportIssueComplete:issue success:NO];
            self.reporting = NO;
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
