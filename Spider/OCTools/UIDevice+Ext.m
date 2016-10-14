//
//  UIDevice+Ext.m
//  YouYuan
//
//  Created by phoenix on 14-10-10.
//  Copyright (c) 2014年 SEU. All rights reserved.
//

#import "UIDevice+Ext.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mount.h>
#import <mach/mach.h>
#import <AdSupport/ASIdentifierManager.h>

@implementation UIDevice (IdentifierAddition)

// 获取Universally Unique Identifier
+ (NSString *)getUUID
{
    NSString *uuid;
    
    if ([UIDevice isHigherIOS7])
    {
        uuid = [UIDevice advertisingIdentifier];
    }
    else
    {
        uuid = [UIDevice macAddress];
    }
    return uuid;
}

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
+ (NSString *)macAddress{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

// 广告标示符（IDFA-identifierForIdentifier）
+ (NSString *)advertisingIdentifier
{
    //示例: 1E2DFA89-496A-47FD-9941-DF1FC4E6484A
    NSString *adId =[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    return adId;
}

+ (BOOL)isDeviceiPad
{
    BOOL iPadDevice = NO;
    
    // Is userInterfaceIdiom available?
    if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
    {
        // Is device an iPad?
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            iPadDevice = YES;
    }
    
    return iPadDevice;
}

//获得设备型号
+ (NSString *)getCurrentDeviceModel
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

//获得设备名称
+ (NSString *)getCurrentDeviceName
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);

    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]
        || [platform isEqualToString:@"iPhone3,2"]
        || [platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]
        || [platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]
        || [platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]
        || [platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    if ([platform hasPrefix:@"iPhone"])
    {
        return @"iPhone";
    }
    
    // iPod
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    
    if ([platform hasPrefix:@"iPod"])
    {
        return @"iPod";
    }
    
    // iPad
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad 1G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    
    if ([platform hasPrefix:@"iPad"])
    {
        return @"iPad";
    }
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return platform;

}

// 对低端机型的判断
+ (BOOL)isLowLevelMachine
{
    NSString *machineModel = [UIDevice getCurrentDeviceName];
    
    NSArray *lowLevel = [NSArray arrayWithObjects:@"iPhone 1G", @"iPhone 3G", @"iPhone 3GS",
                         @"iPod Touch 1G", @"iPod Touch 2G", @"iPod Touch 3G",
                         @"iPad",
                         nil];
    
    for (NSString *lower in lowLevel)
    {
        if ([machineModel isEqualToString:lower])
        {
            return YES;
        }
    }
    
    return NO;
}

+(NSNumber *)freeSpace
{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/private/var", &buf) >= 0)
    {
        freespace = (long long)buf.f_bsize * buf.f_bfree;
    }
    
    return [NSNumber numberWithLongLong:freespace];
}

+(NSNumber *)totalSpace
{
	struct statfs buf;
	long long totalspace = -1;
	if(statfs("/private/var", &buf) >= 0)
    {
		totalspace = (long long)buf.f_bsize * buf.f_blocks;
	}
	return [NSNumber numberWithLongLong:totalspace];
}

// 获取运营商信息
+ (NSString *)carrierName
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    
    if (carrier == nil) {
        return nil;
    }
    NSString *carrierName = [carrier carrierName];
    //    NSString *mcc = [carrier mobileCountryCode];
    //    NSString *mnc = [carrier mobileNetworkCode];
    //    DDLogInfo(@"Carrier Name: %@ mcc: %@ mnc: %@", carrierName, mcc, mnc);
    return carrierName;
}

+ (NSString *)carrierCode
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    
    if (carrier == nil) {
        return nil;
    }
    NSString *mcc = [carrier mobileCountryCode];
    NSString *mnc = [carrier mobileNetworkCode];
    NSString *carrierCode = [NSString stringWithFormat:@"%@%@", mcc, mnc];
    return carrierCode;
}

+ (CGFloat) getBatteryValue
{
    UIDevice* device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    return device.batteryLevel;
}

+ (NSInteger) getBatteryState
{
    UIDevice* device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    return device.batteryState;
}

// 内存信息
+ (unsigned int)freeMemory
{
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    return (unsigned int)(vm_stat.free_count * pagesize);
}

+ (unsigned int)usedMemory
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (unsigned int)((kerr == KERN_SUCCESS) ? info.resident_size : 0);
}

+ (CGSize)screenSize
{
    CGRect rect = [UIScreen mainScreen].bounds;
    return CGSizeMake(rect.size.width, rect.size.height - 20);
}

+ (CGFloat)screenWidth
{
    return [UIDevice screenSize].width;
}

+ (CGFloat)screenHeight
{
    return [UIDevice screenSize].height;
}

+ (CGFloat)mainScreenHeight
{
    CGRect rect = [UIScreen mainScreen].bounds;
    return rect.size.height;
}

+ (BOOL)isIphone4
{
    return [[[UIDevice getCurrentDeviceName] lowercaseString] rangeOfString:[@"iPhone 4" lowercaseString]].length > 0;
}

+ (BOOL)isIphone5
{
    return [[[UIDevice getCurrentDeviceName] lowercaseString] rangeOfString:[@"iPhone 5" lowercaseString]].length > 0;
}

+ (BOOL)isIphone6
{
    return [[[UIDevice getCurrentDeviceName] lowercaseString] rangeOfString:[@"iPhone 6" lowercaseString]].length > 0;
}

+ (BOOL)isIphone6Plus
{
    return [[[UIDevice getCurrentDeviceName] lowercaseString] rangeOfString:[@"iPhone 6 Plus" lowercaseString]].length > 0;
}

//是否高于IOS5.0版本
+ (BOOL)isHigherIOS5
{
    NSString *requestSysVer = @"5.0";
    NSString *currentSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currentSysVer compare:requestSysVer options:NSNumericSearch] == NSOrderedAscending) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)isHigherIOS6
{
    NSString *requestSysVer = @"6.0";
    NSString *currentSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currentSysVer compare:requestSysVer options:NSNumericSearch] == NSOrderedAscending) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)isHigherIOS6P1
{
    NSString *requestSysVer = @"6.1";
    NSString *currentSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currentSysVer compare:requestSysVer options:NSNumericSearch] == NSOrderedAscending) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)isHigherIOS7
{
    NSString *requestSysVer = @"7.0";
    NSString *currentSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currentSysVer compare:requestSysVer options:NSNumericSearch] == NSOrderedAscending) {
        return NO;
    }
    return YES;
}

+ (BOOL)isHigherIOS8
{
    NSString *requestSysVer = @"8.0";
    NSString *currentSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currentSysVer compare:requestSysVer options:NSNumericSearch] == NSOrderedAscending) {
        return NO;
    }
    return YES;
}


+ (NSUInteger)DeviceSystemMajorVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion]
                                       componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

// 是否支持打电话
-(BOOL) isCanOpenTel
{
	return [self isIphone];
}

-(BOOL) isIphone
{
    NSString * model = [[UIDevice currentDevice] model];
    if (model == nil && model.length == 0){
        return NO;
    }
    NSRange rg = [model rangeOfString:@"iPhone"];
    NSRange rw = [model rangeOfString:@"mulator"];
    return rg.length > 0 && !rw.length > 0;
}



@end
