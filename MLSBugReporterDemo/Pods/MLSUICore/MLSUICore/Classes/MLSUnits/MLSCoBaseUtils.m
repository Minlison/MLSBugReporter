//
//  CoBaseUtils.m
//  bitmedia
//
//  Created by RainStone on 14-6-30.
//  Copyright (c) 2014年 No. All rights reserved.
//

#import "MLSCoBaseUtils.h"
#import <sys/sysctl.h>
#import "MLSConfigurationDefine.h"
static CGFloat const __HEIGHT_3_5__ = 480.0;
static CGFloat const __HEIGHT_4_0__ = 568.0;
static CGFloat const __HEIGHT_4_7__ = 667.0;
static CGFloat const __HEIGHT_5_5__ = 736.0;
static CGFloat const __HEIGHT_5_8__ = 812.0;
static CGFloat const __HEIGHT_6_1__ = 896.0;
static CGFloat const __HEIGHT_6_5__ = 896.0;


@interface UIDevice (HardwareModel)

/**
 *	Returns hardware name of device instance
 */
- (NSString *)hardwareName;
@end

@implementation CoBaseUtils

+ (BOOL)isPhoneType:(iPhoneType)type {
    NSString* name = [[UIDevice currentDevice] hardwareName];
    CGFloat height = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    BOOL isEffective = NO;
    if (!isEffective && (type & iPhoneType4)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_3_5__ hardwareName:name iPhoneName:@"iPhone 4"];
    }
    if (!isEffective && (type & iPhoneType4S)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_3_5__ hardwareName:name iPhoneName:@"iPhone 4S"];
    }
    if (!isEffective && (type & iPhoneType5)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_4_0__ hardwareName:name iPhoneName:@"iPhone 5"];
    }
    if (!isEffective && (type & iPhoneType5C)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_4_0__ hardwareName:name iPhoneName:@"iPhone 5c"];
    }
    if (!isEffective && (type & iPhoneType5S)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_4_0__ hardwareName:name iPhoneName:@"iPhone 5s"];
    }
    if (!isEffective && (type & iPhoneType5SE)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_4_0__ hardwareName:name iPhoneName:@"iPhone SE"];
    }
    if (!isEffective && (type& iPhoneType6)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_4_7__ hardwareName:name iPhoneName:@"iPhone 6"];
    }
    if (!isEffective && (type & iPhoneType6S)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_4_7__ hardwareName:name iPhoneName:@"iPhone 6s"];
    }
    if (!isEffective && (type & iPhoneType6P)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_5_5__ hardwareName:name iPhoneName:@"iPhone 6 Plus"];
    }
    if (!isEffective && (type & iPhoneType6SP)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_5_5__ hardwareName:name iPhoneName:@"iPhone 6s Plus"];
    }
    if (!isEffective && (type & iPhoneType7)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_4_7__ hardwareName:name iPhoneName:@"iPhone 7"];
    }
    if (!isEffective && (type & iPhoneType7P)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_5_5__ hardwareName:name iPhoneName:@"iPhone 7 Plus"];
    }
    if (!isEffective && (type & iPhoneType8)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_4_7__ hardwareName:name iPhoneName:@"iPhone 8"];
    }
    if (!isEffective && (type & iPhoneType8P)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_5_5__ hardwareName:name iPhoneName:@"iPhone 8 Plus"];
    }
    if (!isEffective && (type & iPhoneTypeX)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_5_8__ hardwareName:name iPhoneName:@"iPhone X"];
    }
    if (!isEffective && (type & iPhoneTypeXR)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_6_1__ hardwareName:name iPhoneName:@"iPhone XR"];
    }
    if (!isEffective && (type & iPhoneTypeXS)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_5_8__ hardwareName:name iPhoneName:@"iPhone XS"];
    }
    if (!isEffective && (type & iPhoneTypeXS_MAX)) {
        isEffective = [self hardwareHeight:height iPhoneHeight:__HEIGHT_6_5__ hardwareName:name iPhoneName:@"iPhone XS MAX"] || [self hardwareHeight:height iPhoneHeight:__HEIGHT_6_5__ hardwareName:name iPhoneName:@"iPhone XS MAX CN"];
    }
    NSString *str =@"";

    [[str stringByReplacingOccurrencesOfString:@"0x" withString:@"#"] stringByReplacingOccurrencesOfString:@"0X" withString:@"#"];
    return isEffective;
}

+ (BOOL)hardwareHeight:(CGFloat)hardwareHeight iPhoneHeight:(CGFloat)iPhoneHeight hardwareName:(NSString *)hardwareName iPhoneName:(NSString *)iPhoneName {
    return ([hardwareName isEqualToString:iPhoneName]) || (iPhoneHeight == MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width));
}

//判断系统版本是否是ios8.0以上
#define VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
+ (BOOL)isOSVersionGreaterThanOrEqualTo:(CGFloat)version {
    return VERSION >= version;
}

#pragma mark - 修改正则表达式,判断手机号码是否合法
+ (BOOL)isChinaPhoneNumber:(NSString*)mobileNum {
    if (NULLString(mobileNum)) {
        return NO;
    }
    /**
     *  香港（区号852）
     */
    NSString * HK = @"^[1-9]\\d{7}$";
    
    /**
     *  澳门(区号853)
     */
    NSString * MACAO = @"^[1-9]\\d{7}$";
    
    /**
     *  台湾（区号886)
     */
    NSString * TAIWAN = @"^09\\d{8}$";
    
    /**
     *  大陆手机号，11位纯数字
     */
    NSString * MOBILE = @"^1\\d{10}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextest_hk = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", HK];
    NSPredicate *regextest_mc = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MACAO];
    NSPredicate *regextest_tw = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", TAIWAN];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextest_mc evaluateWithObject:mobileNum] == YES)
        || ([regextest_tw evaluateWithObject:mobileNum] == YES)
        || ([regextest_hk evaluateWithObject:mobileNum] == YES)) {
        return YES;
    }
    else {
        return NO;
    }
}


+ (NSString *)validString:(id)value {
    if (NULLString(value)) {
        return @"";
    }
    return value;
}
// 不是以0开头的纯数字
+ (BOOL)isNotBeginWithZeroNumber:(NSString *)str {
    NSString * numberStr = @"^([1-9]{1})([0-9]*)$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberStr];
    return  [regextestmobile evaluateWithObject:str];
}
#pragma mark - 是否是纯数字
+ (BOOL)isNumber:(NSString *)str {
    NSString * numberStr = @"^[0-9]*$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberStr];
    return  [regextestmobile evaluateWithObject:str];
}

+ (BOOL)onlyTwoPoint:(NSString *)str {
    NSString * numberStr = @"^([1-9]{1})([0-9]{0,5})(\\.(\\d{1,2})?)?$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberStr];
    return  [regextestmobile evaluateWithObject:str];
}
+ (NSString *)deleteLastChar:(NSString *)temp {
    if (NULLString(temp)) {
        return @"";
    }
    return [temp stringByReplacingCharactersInRange:NSMakeRange(temp.length - 1, 1) withString:@""];
}

+ (NSString *)deleteThanLength:(NSInteger)length string:(NSString *)string {
    if (NULLString(string)) {
        return @"";
    }
    
    NSString *tempStr = string;
    if (tempStr.length > length) {
        tempStr = [tempStr stringByReplacingCharactersInRange:NSMakeRange(length, tempStr.length - length) withString:@""];
    }
    return tempStr;
}

/**
 * 保留几位小数
 */
+ (NSString *)retainDotCount:(NSInteger)count string:(NSString *)string {
    if (NULLString(string)) {
        return @"";
    }
    if (![string containsString:@"."]) {
        return string;
    }
    
    NSInteger strLength = string.length;
    NSRange dotRange = [string rangeOfString:@"."];
    NSUInteger dotNext = dotRange.location + dotRange.length;
    
    if ((strLength - dotNext) > count) {
        NSUInteger validLength = dotNext + count;
        NSRange range = NSMakeRange(validLength, strLength - validLength);
        return [string stringByReplacingCharactersInRange:range withString:@""];
    }
    return string;
}
+ (NSString *)progress:(CGFloat)current total:(CGFloat)total {
    CGFloat progress = current / total;
    return [[NSString stringWithFormat:@"%.0f", ceil(progress * 100)] stringByAppendingString:@"%"];
}
+ (BOOL)isFirstLaunching {
    BOOL firstLaunching = NO;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"LastAppVersion"];
    NSString *lastAppVersion = [userDefaults objectForKey:@"LastAppVersion"];
    
    NSString *currentAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if (![currentAppVersion isEqualToString:lastAppVersion]) {
        [userDefaults setValue:currentAppVersion forKey:@"LastAppVersion"];
        [userDefaults synchronize];
        
        firstLaunching = YES;
    }
    
    return firstLaunching;
}


+ (void)getImageSizeFromURL:(NSURL *)imageURL completion:(void (^)(CGSize imgSize))completion {
    
    NSURL* URL = nil;
    if([imageURL isKindOfClass:[NSURL class]]){
        URL = imageURL;
    }
    if([imageURL isKindOfClass:[NSString class]]){
        URL = [NSURL URLWithString:(NSString *)imageURL];
    }
    if(URL == nil) {
        if (completion) { completion(CGSizeZero); };
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        // 获取Head
        request.HTTPMethod = @"HEAD";
        BeginIgnoreDeprecatedWarning
        NSHTTPURLResponse *response = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        EndIgnoreDeprecatedWarning
        NSString *acceptRangeKey = [response.allHeaderFields objectForKey:@"Accept-Ranges"];
        NSString* pathExtendsion = [response.allHeaderFields objectForKey:@"Content-Type"];
        
        request = [[NSMutableURLRequest alloc] initWithURL:URL];
        CGSize size = CGSizeZero;
        if([pathExtendsion isEqualToString:@"image/png"]) {
            size =  [self getPNGImageSizeWithRequest:request rangeKey:acceptRangeKey];
        } else if([pathExtendsion isEqual:@"image/gif"]) {
            size =  [self getGIFImageSizeWithRequest:request rangeKey:acceptRangeKey];
        } else {
            size = [self getJPGImageSizeWithRequest:request rangeKey:acceptRangeKey];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) { completion(size); };
        });
    });
}
//  获取PNG图片的大小
+(CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest*)request rangeKey:(NSString *)rangeKey
{
    [request setValue:[NSString stringWithFormat:@"%@=16-23",rangeKey?:@"bytes"] forHTTPHeaderField:@"Range"];
    BeginIgnoreDeprecatedWarning
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    EndIgnoreDeprecatedWarning
    if(data.length == 8)
    {
        int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        [data getBytes:&w3 range:NSMakeRange(2, 1)];
        [data getBytes:&w4 range:NSMakeRange(3, 1)];
        int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
        int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
        [data getBytes:&h1 range:NSMakeRange(4, 1)];
        [data getBytes:&h2 range:NSMakeRange(5, 1)];
        [data getBytes:&h3 range:NSMakeRange(6, 1)];
        [data getBytes:&h4 range:NSMakeRange(7, 1)];
        int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}
//  获取gif图片的大小
+(CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest*)request  rangeKey:(NSString *)rangeKey
{
    [request setValue:[NSString stringWithFormat:@"%@=6-9",rangeKey?:@"bytes"] forHTTPHeaderField:@"Range"];
    BeginIgnoreDeprecatedWarning
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    EndIgnoreDeprecatedWarning
    if(data.length == 4)
    {
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        short w = w1 + (w2 << 8);
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(2, 1)];
        [data getBytes:&h2 range:NSMakeRange(3, 1)];
        short h = h1 + (h2 << 8);
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}
//  获取jpg图片的大小
+(CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest*)request  rangeKey:(NSString *)rangeKey
{
    [request setValue:[NSString stringWithFormat:@"%@=0-209",rangeKey?:@"bytes"] forHTTPHeaderField:@"Range"];
    BeginIgnoreDeprecatedWarning
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    EndIgnoreDeprecatedWarning
    
    if ([data length] <= 0x58) {
        return CGSizeZero;
    }
    
    if ([data length] < 210) {// 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {// 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}
@end


@implementation UIDevice (HardwareModel)

- (NSString *)hardwareName {
    static dispatch_once_t one;
    static NSString *name;
    dispatch_once(&one, ^{
        NSString *model = [self machineModel];
        if (!model) return;
        NSDictionary *dic = @{
                              @"Watch1,1" : @"Apple Watch 38mm",
                              @"Watch1,2" : @"Apple Watch 42mm",
                              @"Watch2,3" : @"Apple Watch Series 2 38mm",
                              @"Watch2,4" : @"Apple Watch Series 2 42mm",
                              @"Watch2,6" : @"Apple Watch Series 1 38mm",
                              @"Watch2,7" : @"Apple Watch Series 1 42mm",
                              @"Watch3,1" : @"Apple Watch Series 3 38mm",
                              @"Watch3,2" : @"Apple Watch Series 3 42mm",
                              @"Watch3,3" : @"Apple Watch Series 3 38mm",
                              @"Watch3,4" : @"Apple Watch Series 3 42mm",
                              
                              @"iPod1,1" : @"iPod touch 1",
                              @"iPod2,1" : @"iPod touch 2",
                              @"iPod3,1" : @"iPod touch 3",
                              @"iPod4,1" : @"iPod touch 4",
                              @"iPod5,1" : @"iPod touch 5",
                              @"iPod7,1" : @"iPod touch 6",
                              
                              @"iPhone1,1" : @"iPhone 1G",
                              @"iPhone1,2" : @"iPhone 3G",
                              @"iPhone2,1" : @"iPhone 3GS",
                              @"iPhone3,1" : @"iPhone 4 (GSM)",
                              @"iPhone3,2" : @"iPhone 4",
                              @"iPhone3,3" : @"iPhone 4 (CDMA)",
                              @"iPhone4,1" : @"iPhone 4S",
                              @"iPhone5,1" : @"iPhone 5",
                              @"iPhone5,2" : @"iPhone 5",
                              @"iPhone5,3" : @"iPhone 5c",
                              @"iPhone5,4" : @"iPhone 5c",
                              @"iPhone6,1" : @"iPhone 5s",
                              @"iPhone6,2" : @"iPhone 5s",
                              @"iPhone7,1" : @"iPhone 6 Plus",
                              @"iPhone7,2" : @"iPhone 6",
                              @"iPhone8,1" : @"iPhone 6s",
                              @"iPhone8,2" : @"iPhone 6s Plus",
                              @"iPhone8,4" : @"iPhone SE",
                              @"iPhone9,1" : @"iPhone 7",
                              @"iPhone9,2" : @"iPhone 7 Plus",
                              @"iPhone9,3" : @"iPhone 7",
                              @"iPhone9,4" : @"iPhone 7 Plus",
                              @"iPhone10,1" : @"iPhone 8",
                              @"iPhone10,2" : @"iPhone 8 Plus",
                              @"iPhone10,4" : @"iPhone 8",
                              @"iPhone10,5" : @"iPhone 8 Plus",
                              @"iPhone10,3" : @"iPhone X",
                              @"iPhone10,6" : @"iPhone X",
                              @"iPhone11,2" : @"iPhone XS",
                              @"iPhone11,4" : @"iPhone XS Max",
                              @"iPhone11,6" : @"iPhone XS Max CN",
                              @"iPhone11,8" : @"iPhone XR",
                              
                              
                              @"iPad1,1" : @"iPad 1",
                              @"iPad2,1" : @"iPad 2 (WiFi)",
                              @"iPad2,2" : @"iPad 2 (GSM)",
                              @"iPad2,3" : @"iPad 2 (CDMA)",
                              @"iPad2,4" : @"iPad 2",
                              @"iPad2,5" : @"iPad mini 1",
                              @"iPad2,6" : @"iPad mini 1",
                              @"iPad2,7" : @"iPad mini 1",
                              @"iPad3,1" : @"iPad 3 (WiFi)",
                              @"iPad3,2" : @"iPad 3 (4G)",
                              @"iPad3,3" : @"iPad 3 (4G)",
                              @"iPad3,4" : @"iPad 4",
                              @"iPad3,5" : @"iPad 4",
                              @"iPad3,6" : @"iPad 4",
                              @"iPad4,1" : @"iPad Air",
                              @"iPad4,2" : @"iPad Air",
                              @"iPad4,3" : @"iPad Air",
                              @"iPad4,4" : @"iPad mini 2",
                              @"iPad4,5" : @"iPad mini 2",
                              @"iPad4,6" : @"iPad mini 2",
                              @"iPad4,7" : @"iPad mini 3",
                              @"iPad4,8" : @"iPad mini 3",
                              @"iPad4,9" : @"iPad mini 3",
                              @"iPad5,1" : @"iPad mini 4",
                              @"iPad5,2" : @"iPad mini 4",
                              @"iPad5,3" : @"iPad Air 2",
                              @"iPad5,4" : @"iPad Air 2",
                              @"iPad6,3" : @"iPad Pro (9.7 inch)",
                              @"iPad6,4" : @"iPad Pro (9.7 inch)",
                              @"iPad6,7" : @"iPad Pro (12.9 inch)",
                              @"iPad6,8" : @"iPad Pro (12.9 inch)",
                              
                              @"iPad6,11" : @"iPad 5 (WiFi)",
                              @"iPad6,12" : @"iPad 5 (Cellular)",
                              @"iPad7,1" : @"iPad Pro 12.9-inch (WiFi)",
                              @"iPad7,2" : @"iPad Pro 12.9-inch (Cellular)",
                              @"iPad7,3" : @"iPad Pro 10.5-inch (WiFi)",
                              @"iPad7,4" : @"iPad Pro 10.5-inch (Cellular)",
                              
                              
                              @"AppleTV2,1" : @"Apple TV 2",
                              @"AppleTV3,1" : @"Apple TV 3",
                              @"AppleTV3,2" : @"Apple TV 3",
                              @"AppleTV5,3" : @"Apple TV 4",
                              
                              @"i386" : @"Simulator x86",
                              @"x86_64" : @"Simulator x64",
                              };
        name = dic[model];
        if (!name) name = model;
    });
    return name;
}
- (NSString *)machineModel {
    static dispatch_once_t one;
    static NSString *model;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return model;
}

@end
