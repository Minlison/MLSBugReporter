//
//  MLSBugLogger.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/24.
//

#import "MLSBugLogger.h"
#import "MLSBugReporterManager.h"
#import "MLSBugReporterOptions.h"
#import <SSZipArchive/SSZipArchive.h>
#import <CocoaLumberjack/DDMultiFormatter.h>
@interface MLSBugLogger ()
@property (nonatomic, strong) NSMutableDictionary <NSString *, MLSBugReportFileLogger *>*loggers;
@property (nonatomic, strong) DDLog *ddlog;
@end

@implementation MLSBugLogger
+ (instancetype)sharedInstance {
    static dispatch_once_t loggerOnceToken;
    static MLSBugLogger *loggerInstance = nil;
    dispatch_once(&loggerOnceToken,^{
        loggerInstance = [[super alloc] init];
    });
    return loggerInstance;
}

- (DDLog *)ddlog {
    if (!_ddlog) {
        _ddlog = [[DDLog alloc] init];
    }
    return _ddlog;
}

+ (void)log:(BOOL)asynchronous
      level:(DDLogLevel)level
       flag:(DDLogFlag)flag
    logType:(MLSBugLogType)logType
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id __nullable)tag
     format:(NSString *)format, ... {
    
    if (![self cannHandleLoggerForType:logType]) {
        return;
    }
    
    va_list args;
    
    if (format) {
        va_start(args, format);
        
        [[MLSBugLogger sharedInstance].ddlog log:asynchronous level:level flag:flag context:logType file:file function:function line:line tag:tag format:format args:args];
        
        va_end(args);
    }
}


+ (BOOL)cannHandleLoggerForType:(MLSBugLogType)type {
    MLSBugLogType _logType = type;
    if (MLSBugReporterOptions.shareOptions.combineAllLog == YES) {
        _logType = MLSBugLogTypeCombineAll;
    }
    
    BOOL res = NO;
    switch (_logType) {
        case MLSBugLogTypeDefault: {
            res = YES;
        }
            break;
        case MLSBugLogTypeNetwork: {
            res = MLSBugReporterOptions.shareOptions.trackingNetwork;
        }
            break;
        case MLSBugLogTypeUserTrack: {
            res = MLSBugReporterOptions.shareOptions.trackingUserSteps;
        }
            break;
        case MLSBugLogTypeConsole: {
            res = MLSBugReporterOptions.shareOptions.trackingConsoleLog;
        }
            break;
        case MLSBugLogTypeCombineAll: {
            res = MLSBugReporterOptions.shareOptions.combineAllLog;
        }
            break;
        default:
            break;
    }
    if (res) {
        [self installloggerIfNeedForType:_logType];
    }
    return res;
}

+ (BOOL)installloggerIfNeedForType:(MLSBugLogType)type {
    if ( ![self loggerIsInstallFroType:type] ) {
        [[MLSBugLogger sharedInstance].ddlog addLogger:[self getLoggerWithType:type]];
    }
    return NO;
}
+ (BOOL)loggerIsInstallFroType:(MLSBugLogType)type {
    return [[MLSBugLogger sharedInstance].loggers objectForKey:@(type).stringValue] != nil;
}

+ (MLSBugReportFileLogger *)getLoggerWithType:(MLSBugLogType)type {
    return [self getLoggerWithCreate:YES forType:type];
}

+ (MLSBugReportFileLogger *)getLoggerWithCreate:(BOOL)create forType:(MLSBugLogType)type {
    if (![MLSBugLogger sharedInstance].loggers) {
        [MLSBugLogger sharedInstance].loggers = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    MLSBugReportFileLogger *logger = [[MLSBugLogger sharedInstance].loggers objectForKey:@(type).stringValue];
    if (!logger && create) {
        logger = [MLSBugReportFileLogger loggerWithType:type];
        [[MLSBugLogger sharedInstance].loggers setObject:logger forKey:@(type).stringValue];
    }
    return logger;
}


+ (NSString *)createDirAtPath:(NSString *)path {
    BOOL isDir = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)getLogRootPath {
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    libraryPath = [libraryPath stringByAppendingPathComponent:@"MLSBugReport"];
    return [self createDirAtPath:libraryPath];
}

+ (NSString *)getLogPathWithType:(MLSBugLogType)type {
    NSString *logPath = [[self getLogRootPath] stringByAppendingPathComponent:[self descriptionForType:type]];
    return [self createDirAtPath:logPath];
}
+ (NSString *)getLogZipFilePathWithType:(MLSBugLogType)type {
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *cacheFileName = [NSString stringWithFormat:@"%@logs.zip", [self descriptionForType:type]];
    NSString *cacheFile = [cacheDir stringByAppendingPathComponent:cacheFileName];
    return cacheFile;
}
+ (NSString *)getLogZipFileWithType:(MLSBugLogType)type {
    
    MLSBugReportFileLogger *logger = [self getLoggerWithCreate:NO forType:type];
    if (!logger) {
        return nil;
    }
    __block NSString *cacheFile = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [logger rollLogFileWithCompletionBlock:^{
        NSArray <NSString *>*logFiles = [logger.logFileManager sortedLogFilePaths];
        if (logFiles.count > 0) {
            NSString *t_cacheFile = [self getLogZipFilePathWithType:type];
            if ([SSZipArchive createZipFileAtPath:t_cacheFile withFilesAtPaths:logFiles]) {
                cacheFile = t_cacheFile;
            } else {
                cacheFile = logFiles.firstObject;
            }
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    // 10秒 超时
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    return cacheFile;
}

+ (BOOL)deleteLogZipFileWithType:(MLSBugLogType)type {
    NSString *cacheFile = [self getLogZipFilePathWithType:type];
    return [[NSFileManager defaultManager] removeItemAtPath:cacheFile error:nil];
}

+ (void)removeAllLogFile {
    [[MLSBugLogger sharedInstance].ddlog flushLog];
    [[MLSBugLogger sharedInstance].loggers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MLSBugReportFileLogger * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj rollLogFileWithCompletionBlock:^{
            [obj.logFileManager.unsortedLogFilePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj hasSuffix:@"archived.log"]) {
                    [[NSFileManager defaultManager] removeItemAtPath:obj error:nil];
                }
            }];
        }];
    }];
}

+ (void)removeLogFileForType:(MLSBugLogType)type {
    [[MLSBugLogger sharedInstance].ddlog flushLog];
    MLSBugReportFileLogger *logger =  [self getLoggerWithCreate:NO forType:type];
    [logger rollLogFileWithCompletionBlock:^{
        [logger.logFileManager.unsortedLogFilePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj hasSuffix:@"archived.log"]) {
                [[NSFileManager defaultManager] removeItemAtPath:obj error:nil];
            }
        }];
    }];
}

+ (NSString *)descriptionForType:(MLSBugLogType)type {
    switch (type) {
        case MLSBugLogTypeDefault:
            return @"default";
            break;
        case MLSBugLogTypeNetwork:
            return @"network";
            break;
        case MLSBugLogTypeUserTrack:
            return @"usertrack";
            break;
        case MLSBugLogTypeConsole:
            return @"console";
            break;
        case MLSBugLogTypeCombineAll:
            return @"all";
            break;
        default:
            break;
    }
}

@end
@interface MLSBugReportFileFormatter : NSObject <DDLogFormatter>

@end

@interface DDLogFileManagerDefault (MLSBugReport)
- (NSString *)applicationName;
- (NSDateFormatter *)logFileDateFormatter;
@end

@interface MLSBugReportFileManager : DDLogFileManagerDefault
@property (nonatomic, assign) MLSBugLogType logType;
@end

@implementation MLSBugReportFileManager
- (NSString *)newLogFileName {
    NSString *appName = [self applicationName];
    NSString *logType = [MLSBugLogger descriptionForType:self.logType];
    
    NSDateFormatter *dateFormatter = [self logFileDateFormatter];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *formattedDate = [dateFormatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"%@-%@-%@.log", appName, logType, formattedDate];
}
- (BOOL)isLogFile:(NSString *)fileName {
    NSString *appName = [self applicationName];
    NSString *logType = [MLSBugLogger descriptionForType:self.logType];
    // We need to add a space to the name as otherwise we could match applications that have the name prefix.
    BOOL hasProperPrefix = [fileName hasPrefix:[appName stringByAppendingFormat:@"-%@",logType]];
    BOOL hasProperSuffix = [fileName hasSuffix:@".log"];
    
    return (hasProperPrefix && hasProperSuffix);
}


@end
@interface DDFileLogger (MLSBugReport)
- (void)lt_rollLogFileNow;
// 低版本方法兼容
- (void)rollLogFileNow;
@end
@implementation MLSBugReportFileLogger

+ (instancetype)loggerWithType:(MLSBugLogType)type {
    MLSBugReportFileManager *fileManager = [[MLSBugReportFileManager alloc] initWithLogsDirectory:[MLSBugLogger getLogPathWithType:type]];
    fileManager.maximumNumberOfLogFiles = 5; // 保留5次历史文件
    fileManager.logType = type;
    MLSBugReportFileLogger *logger = [[MLSBugReportFileLogger alloc] initWithLogFileManager:fileManager];
    logger.type = type;
    
    DDMultiFormatter *formatter = [[DDMultiFormatter alloc] init];
    [formatter addFormatter:[[MLSBugReportFileFormatter alloc] init]];
    [formatter addFormatter:[[DDLogFileFormatterDefault alloc] init]];
    
    logger.logFormatter = formatter;
    logger.maximumFileSize = 1 * 1024 * 1024; // 1MB
    if (type == MLSBugLogTypeCombineAll) {
        logger.maximumFileSize = 5 * 1024 * 1024; // 5 MB
    }
    return logger;
}

- (void)rollLogFileWithCompletionBlock:(void (^ __nullable)(void))completionBlock {
    // This method is public.
    // We need to execute the rolling on our logging thread/queue.
    
    dispatch_block_t block = ^{
        @autoreleasepool {
            if ([self respondsToSelector:@selector(lt_rollLogFileNow)]) {
                [self lt_rollLogFileNow];
            } else if ([self respondsToSelector:@selector(rollLogFileNow)]) {
                [self rollLogFileNow];
            }
            
            if (completionBlock) {
                completionBlock();
            }
        }
    };
    
    // The design of this method is taken from the DDAbstractLogger implementation.
    // For extensive documentation please refer to the DDAbstractLogger implementation.
    
    if ([self isOnInternalLoggerQueue]) {
        block();
    } else {
        dispatch_queue_t globalLoggingQueue = [DDLog loggingQueue];
        NSAssert(![self isOnGlobalLoggingQueue], @"Core architecture requirement failure");
        
        dispatch_async(globalLoggingQueue, ^{
            dispatch_async(self.loggerQueue, block);
        });
    }
}


- (void)logMessage:(DDLogMessage *)logMessage {
    if (logMessage.context != self.type && self.type != MLSBugLogTypeCombineAll) {
        return;
    }
    [super logMessage:logMessage];
}
@end


@implementation MLSBugReportFileFormatter

- (NSString * __nullable)formatLogMessage:(DDLogMessage *)logMessage {
    return [NSString stringWithFormat:@"【LOGTYPE - %@】 - %@",logMessage.tag, logMessage.message];
}

@end
