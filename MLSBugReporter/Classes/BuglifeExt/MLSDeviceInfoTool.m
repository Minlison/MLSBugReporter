//
//  MLSDeviceInfoTool.m
//  MLSBugReporter
//
//  Created by minlison on 2019/4/29.
//

#import "MLSDeviceInfoTool.h"
#import "UIDevice+MLSBugReporter.h"
#import "MLSBugReporterOptions.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <MLSNetwork/MLSNetwork.h>
#import <MLSNetwork/MLSNetWorkReachability.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <net/if.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation MLSDeviceInfoTool

+ (void)appenTableStart:(NSMutableString *)str {
    [str appendFormat:@"<table style=\"table-layout:fixed;\" border=\"1\">"];
}
+ (void)appenTableStop:(NSMutableString *)str {
    [str appendFormat:@"</table>"];
}
+ (void)appenTableHeader:(NSMutableString *)str name:(NSString *)name columns:(NSInteger)columns {
    [str appendFormat:@"<tr>\
     <th align=\"center\" colspan=\"%d\">%@</th>\
     </tr>", columns, name];
}
+ (void)appenTrStart:(NSMutableString *)str {
    [str appendString:@"<tr>"];
}
+ (void)appenTrStop:(NSMutableString *)str {
    [str appendString:@"</tr>"];
}

+ (void)appenTh:(NSMutableString *)str value:(NSString *)value {
    [str appendFormat:@"<th align=\"center\">%@</th>",value];
}
+ (void)appendTr:(NSMutableString *)str values:(NSArray <NSString *>*)values {
    [self appenTrStart:str];
    [values enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self appenTh:str value:obj];
    }];
    [self appenTrStop:str];
}
+ (void)appendAppInfoTable:(NSMutableString *)string {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    MLSBugReporterOptions *options = [MLSBugReporterOptions shareOptions];
    // 应用信息
    [self appenTableStart:string];
    [self appenTableHeader:string name:@"应用信息" columns:3];
    
    NSString *appName = infoDictionary[@"CFBundleDisplayName"];
    if (appName == nil) {
        appName = infoDictionary[@"CFBundleName"];
    }
    [self appendTr:string values:@[@"应用名",@"版本号",@"Build"]];
    [self appendTr:string values:@[appName,options.version,options.build]];
    
    [self appenTableStop:string];
}
+ (void)appendDeviceInfoTable:(NSMutableString *)string {
    [self appenTableStart:string];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = @"yyyy'年'MM'月'dd'日'' 'HH'时'mm'分'ss'秒'SSS'毫秒'";
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *timeup = [dateFormatter stringFromDate:UIDevice.currentDevice.systemUptime];
    
    [self appenTableHeader:string name:@"系统信息" columns:4];
    [self appendTr:string values:@[@"系统版本",
                                   @"设备名称",
                                   @"设备版本",
                                   @"设备开启时间",]];
    NSString *systemVersion = [NSString stringWithFormat:@"%@ %@",[UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
    [self appendTr:string values:@[systemVersion,
                                   UIDevice.currentDevice.machineModelName?:@"",
                                   UIDevice.currentDevice.machineModel?:@"",
                                   timeup]];
    
    [self appendTr:string values:@[@"是否越狱",
                                   @"是否可以拨打电话",
                                   @"设备WIFI地址",
                                   @"设备蜂窝网络地址"]];
    
    NSString *jailBroken = UIDevice.currentDevice.isJailbroken ? @"是" : @"否";
    NSString *canMakePhoneCalls = UIDevice.currentDevice.canMakePhoneCalls ? @"是" : @"否";
    NSString *wifiAddress = @"";
    if (MLSBugReporterOptions.shareOptions.getWifiName) {
        wifiAddress = [NSString stringWithFormat:@"WIFI名:%@<br> ipv4:%@<br> ipv6:%@", [self ssid], UIDevice.currentDevice.ipAddressWIFI, UIDevice.currentDevice.ipV6AddressWIFI?:@""];
    } else {
        wifiAddress = [NSString stringWithFormat:@"ipv4:%@<br> ipv6:%@",[self getLocalIPAddress:YES], UIDevice.currentDevice.ipAddressWIFI?:@""];
    }
    
    [self appendTr:string values:@[jailBroken,
                                   canMakePhoneCalls,
                                   wifiAddress,
                                   UIDevice.currentDevice.ipAddressCell?:@""]];
    
    [self appenTableStop:string];
}
+ (void)appendNetworkInfoTable:(NSMutableString *)string {
    [self appenTableStart:string];
    [self appenTableHeader:string name:@"流量信息" columns:4];
    [self appendTr:string values:@[@"WIFI 发送流量",@"WIFI 接收流量",@"WAN 发送流量",@"WAN 接收流量"]];
    [self appendTr:string values:@[[self getStringFromBytes:[UIDevice.currentDevice getNetworkTrafficBytes:(MLSBRNetworkTrafficTypeWIFISent)]],
                                   [self getStringFromBytes:[UIDevice.currentDevice getNetworkTrafficBytes:(MLSBRNetworkTrafficTypeWIFIReceived)]],
                                   [self getStringFromBytes:[UIDevice.currentDevice getNetworkTrafficBytes:(MLSBRNetworkTrafficTypeWWANSent)]],
                                   [self getStringFromBytes:[UIDevice.currentDevice getNetworkTrafficBytes:(MLSBRNetworkTrafficTypeWWANReceived)]]]];
    [self appenTableStop:string];
}
+ (void)appendDiskInfoTable:(NSMutableString *)string {
    [self appenTableStart:string];
    [self appenTableHeader:string name:@"磁盘空间" columns:3];
    [self appendTr:string values:@[@"总计",@"已用",@"剩余"]];
    [self appendTr:string values:@[[self getStringFromBytes:UIDevice.currentDevice.diskSpace],
                                   [self getStringFromBytes:UIDevice.currentDevice.diskSpaceUsed],
                                   [self getStringFromBytes:UIDevice.currentDevice.diskSpaceFree]]];
    [self appenTableStop:string];
}

+ (void)appendMemoryInfoTable:(NSMutableString *)string {
    [self appenTableStart:string];
    [self appenTableHeader:string name:@"内存使用情况" columns:5];
    [self appendTr:string values:@[@"总计",@"已用",@"空闲",@"活动",@"闲置"]];
    [self appendTr:string values:@[[self getStringFromBytes:UIDevice.currentDevice.memoryTotal],
                                   [self getStringFromBytes:UIDevice.currentDevice.memoryUsed],
                                   [self getStringFromBytes:UIDevice.currentDevice.memoryFree],
                                   [self getStringFromBytes:UIDevice.currentDevice.memoryActive],
                                   [self getStringFromBytes:UIDevice.currentDevice.memoryInactive]]];
    [self appenTableStop:string];
}
+ (void)appendCPUInfoTable:(NSMutableString *)string {
    [self appenTableStart:string];
    NSUInteger cpuCount = UIDevice.currentDevice.cpuUsagePerProcessor.count;
    [self appenTableHeader:string name:@"CPU使用情况" columns:2 + cpuCount];
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:2+cpuCount];
    [titles addObjectsFromArray:@[@"CPU个数", @"CPU总使用率"]];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:2+cpuCount];
    [values addObjectsFromArray:@[@(UIDevice.currentDevice.cpuCount),
                                  [NSString stringWithFormat:@"%.2f %%",UIDevice.currentDevice.cpuUsage * 100]]];
    
    [UIDevice.currentDevice.cpuUsagePerProcessor enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [titles addObject:[NSString stringWithFormat:@"CPU %d",idx+1]];
        [values addObject:[NSString stringWithFormat:@"%.2f %%",obj.floatValue * 100]];
    }];
    [self appendTr:string values:titles];
    [self appendTr:string values:values];
    [self appenTableStop:string];
}
+ (void)appendNetworkCheckResult:(NSMutableString *)string {
    [self appenTableStart:string];
    
    
    
    NSArray *titles = @[@"运营商", @"设备网络类型", @"公网IP", @"本地IP"];
    [self appenTableHeader:string name:@"网络环境" columns:titles.count];
    NSArray *values = @[[self netOperatorByWho],
                        [self getNetworkStatus],
                        [self getNetworkIPAddressIFConfig],
                        [self getLocalIPAddress:YES]];
    [self appendTr:string values:titles];
    [self appendTr:string values:values];
    [self appenTableStop:string];
    
}
+ (void)appendApplicaitonInfo:(NSMutableString *)string {
    void(^AppendString)(NSMutableString *string) = ^(NSMutableString *string) {
        [self appendAppInfoTable:string];
        [string appendString:@"<br>"];
        [self appendDeviceInfoTable:string];
        [string appendString:@"<br>"];
        [self appendNetworkInfoTable:string];
        [string appendString:@"<br>"];
        [self appendDiskInfoTable:string];
        [string appendString:@"<br>"];
        [self appendMemoryInfoTable:string];
        [string appendString:@"<br>"];
        [self appendCPUInfoTable:string];
        [string appendString:@"<br>"];
    };
    if (NSThread.isMainThread) {
        AppendString(string);
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            AppendString(string);
        });
    }
    [self appendNetworkCheckResult:string];
    [string appendString:@"<br>"];
}
+ (NSString *)getApplicationInfo {
    NSMutableString *string = [[NSMutableString alloc] init];
    [self appendApplicaitonInfo:string];
    return string;
}
+ (NSString *)getStringFromBytes:(uint64_t)bytes {
    double maxBytes = bytes * 1.0;
    double bytesUp = 1024.0;
    if (maxBytes < bytesUp) {
        return [NSString stringWithFormat:@"%d bytes", (int)bytes];
    }
    
    maxBytes = maxBytes / bytesUp;
    if (maxBytes < bytesUp) {
        return [NSString stringWithFormat:@"%.2f KB", maxBytes];
    }
    
    maxBytes = maxBytes / bytesUp;
    if (maxBytes < bytesUp) {
        return [NSString stringWithFormat:@"%.2f MB", maxBytes];
    }
    
    maxBytes = maxBytes / bytesUp;
    if (maxBytes < bytesUp) {
        return [NSString stringWithFormat:@"%.2f GB", maxBytes];
    }
    
    maxBytes = maxBytes / bytesUp;
    if (maxBytes < bytesUp) {
        return [NSString stringWithFormat:@"%.2f TB", maxBytes];
    }
    return [NSString stringWithFormat:@"%lld bytes", (long long)maxBytes];
}



+ (NSString *)netOperatorByWho {
    
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier;
    if (@available(iOS 12, *)) {
        NSDictionary *value = info.serviceSubscriberCellularProviders;
        carrier = value[@"0000000100000001"];
    } else {
        carrier = [info subscriberCellularProvider];
    }
    
    NSString *mobile;
    //先判断有没有SIM卡，如果没有则不获取本机运营商
    if (!carrier.isoCountryCode) {
        
        mobile = @"无运营商";
    }else{
        
        mobile = [carrier carrierName];
    }
    return mobile;
}
+ (NSString *)getNetworkStatus {
    MLSNetWorkStatus status = [MLSNetworkReachability shareManager].currentReachabilityStatus;
    switch (status) {
        case MLSNetWorkStatusNotReachable:
            return @"不可用";
            break;
        case MLSNetWorkStatusUnknown:
            return @"未知网络类型";
            break;
        case MLSNetWorkStatusWWAN2G:
            return @"2G";
            break;
        case MLSNetWorkStatusWWAN3G:
            return @"3G";
            break;
        case MLSNetWorkStatusWWAN4G:
            return @"4G";
            break;
        case MLSNetWorkStatusWiFi:
            return @"wifi";
            break;
        default:
            break;
    }
}


#define MLSBUG_IOS_CELLULAR    @"pdp_ip0"
#define MLSBUG_IOS_WIFI        @"en0"
#define MLSBUG_IOS_VPN         @"utun0"
#define MLSBUG_IP_ADDR_IPv4    @"ipv4"
#define MLSBUG_IP_ADDR_IPv6    @"ipv6"

+ (NSString *)getLocalIPAddress:(BOOL)preferIPv4 {
    
    NSArray *searchArray = preferIPv4 ?
    @[ MLSBUG_IOS_VPN @"/" MLSBUG_IP_ADDR_IPv4, MLSBUG_IOS_VPN @"/" MLSBUG_IP_ADDR_IPv6, MLSBUG_IOS_WIFI @"/" MLSBUG_IP_ADDR_IPv4, MLSBUG_IOS_WIFI @"/" MLSBUG_IP_ADDR_IPv6, MLSBUG_IOS_CELLULAR @"/" MLSBUG_IP_ADDR_IPv4, MLSBUG_IOS_CELLULAR @"/" MLSBUG_IP_ADDR_IPv6 ] :
    @[ MLSBUG_IOS_VPN @"/" MLSBUG_IP_ADDR_IPv6, MLSBUG_IOS_VPN @"/" MLSBUG_IP_ADDR_IPv4, MLSBUG_IOS_WIFI @"/" MLSBUG_IP_ADDR_IPv6, MLSBUG_IOS_WIFI @"/" MLSBUG_IP_ADDR_IPv4, MLSBUG_IOS_CELLULAR @"/" MLSBUG_IP_ADDR_IPv6, MLSBUG_IOS_CELLULAR @"/" MLSBUG_IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        address = addresses[key];
        //筛选出IP地址格式
        if([self isValidatIP:address]) *stop = YES;
    } ];
    return address ? address : @"0.0.0.0";
}
+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result = [ipAddress substringWithRange:resultRange];
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses {
    
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = MLSBUG_IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = MLSBUG_IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}
+ (NSString *)getNetworkIPAddressIFConfig {
    
    MLSNetworkRequest *req = [MLSNetworkRequest requestWithParam:nil];
    req.baseUrl = @"https://ifconfig.me";
    req.requestUrl = @"/ip";
    req.requestTimeoutInterval = 3;
    req.responseSerializerType = MLSResponseSerializerTypeHTTP;
    __block NSString *publicIP = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [req startWithSuccess:^(MLSNetworkRequest * req, id data, NSError *error) {
        publicIP = req.responseString;
        dispatch_semaphore_signal(semaphore);
    } failure:^(id<MLSRetryPreRequestProtocol> req, id data, NSError *error) {
        publicIP = nil;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(req.requestTimeoutInterval * NSEC_PER_SEC)));
    return publicIP?:@"未知";
}

+ (NSString *)ssid {
    NSString *ssid = @"无法获取,请开启 Wireless Accessory Configuration 权限, 并使用付费账户签名";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            ssid = [dict valueForKey:(NSString
                                       *)kCNNetworkInfoKeySSID];
        }
    }
    return ssid;
}
@end
