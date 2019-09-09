//
//  MLSBugLogger.h
//  MLSBugReporter
//
//  Created by minlison on 2019/4/24.
//

#import <UIKit/UIKit.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
typedef NS_ENUM(NSInteger, MLSBugLogType) {
    MLSBugLogTypeDefault = 100001,
    MLSBugLogTypeNetwork = 100002,
    MLSBugLogTypeUserTrack = 100003,
    MLSBugLogTypeConsole = 100004,
    
    MLSBugLogTypeCombineAll = 100010,
};

NS_ASSUME_NONNULL_BEGIN

#define MLS_BUG_LOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
        [MLSBugLogger  log : isAsynchronous                                     \
                     level : lvl                                                \
                      flag : flg                                                \
                   logType : ctx                                                \
                      file : __FILE__                                           \
                  function : fnct                                               \
                      line : __LINE__                                           \
                       tag : atag                                               \
                    format : (frmt), ## __VA_ARGS__]

#define MLS_BUG_LOG_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
        do { if(lvl & flg) MLS_BUG_LOG_MACRO(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

#define MLSBugLogDefault(frmt, ...)      MLS_BUG_LOG_MAYBE(YES, DDLogLevelAll, DDLogFlagInfo, 100001,   @"MLSBugLogDefault", __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MLSBugLogNetwork(frmt, ...)      MLS_BUG_LOG_MAYBE(YES, DDLogLevelAll, DDLogFlagInfo, 100002,   @"MLSBugLogNetwork", __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MLSBugLogUserTrack(frmt, ...)    MLS_BUG_LOG_MAYBE(YES, DDLogLevelAll, DDLogFlagInfo, 100003,   @"MLSBugLogUserTrack", __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MLSBugLogConsole(frmt, ...)      MLS_BUG_LOG_MAYBE(YES, DDLogLevelAll, DDLogFlagInfo, 100004,   @"MLSBugLogConsole", __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

@interface MLSBugReportFileLogger : DDFileLogger
// 类型
@property (nonatomic, assign) MLSBugLogType type;
// 创建logger
+ (instancetype)loggerWithType:(MLSBugLogType)type;
@end


@interface MLSBugLogger : NSObject

/**
 获取日志根路径

 @return 日志根路径
 */
+ (NSString *)getLogRootPath;
/**
 获取对应日志文件夹

 @param type 类型
 @return 日志文件夹
 */
+ (NSString *)getLogPathWithType:(MLSBugLogType)type;

/**
 获取压缩包

 @param type 日志类型
 @return 压缩包
 */
+ (NSString *)getLogZipFileWithType:(MLSBugLogType)type;

/**
 删除压缩日志包

 @param type 日志类型
 @return 是否删除成功
 */
+ (BOOL)deleteLogZipFileWithType:(MLSBugLogType)type;

/**
 删除对应类型日志

 @param type 类型
 */
+ (void)removeLogFileForType:(MLSBugLogType)type;

/**
 移除所有log
 */
+ (void)removeAllLogFile;


+ (void)log:(BOOL)asynchronous
      level:(DDLogLevel)level
       flag:(DDLogFlag)flag
    logType:(MLSBugLogType)logType
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id __nullable)tag
     format:(NSString *)format, ... NS_FORMAT_FUNCTION(9,10);
@end

NS_ASSUME_NONNULL_END
