//
//  UIDevice+Ext.h
//  YouYuan
//
//  Created by phoenix on 14-10-10.
//  Copyright (c) 2014年 SEU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIKit.h>

@interface UIDevice (IdentifierAddition)

// 获取Universally Unique Identifier
+ (NSString *)getUUID;
// 获取MAC地址
+ (NSString *)macAddress;
// 广告标示符（IDFA-identifierForIdentifier）
+ (NSString *)advertisingIdentifier;
// 设备是否是iPad
+ (BOOL)isDeviceiPad;
// 获取机器型号
+ (NSString *)getCurrentDeviceModel;
// 获得设备名称
+ (NSString *)getCurrentDeviceName;
// 对低端机型的判断
+ (BOOL)isLowLevelMachine;
// 设备可用空间
// freespace/1024/1024/1024 = B/KB/MB/14.02GB
+(NSNumber *)freeSpace;
// 设备总空间
+(NSNumber *)totalSpace;
// 获取运营商信息
+ (NSString *)carrierName;
// 获取运营商代码
+ (NSString *)carrierCode;
//获取电池电量
+ (CGFloat) getBatteryValue;
//获取电池状态
+ (NSInteger) getBatteryState;
// 去除导航条的全屏尺寸
+ (CGSize)screenSize;
// 屏幕宽(去掉statusbar)
+ (CGFloat)screenWidth;
// 屏幕高(去掉statusbar)
+ (CGFloat)screenHeight;
// 屏幕高度（包含statusbar）
+ (CGFloat)mainScreenHeight;
// 内存信息
+ (unsigned int)freeMemory;
+ (unsigned int)usedMemory;
// 判断是否是iphone4
+ (BOOL)isIphone4;
// 判断是否是iphone5
+ (BOOL)isIphone5;
// 判断是否是iphone6
+ (BOOL)isIphone6;
// 判断是否是iphone6Plus
+ (BOOL)isIphone6Plus;

// 是否高于某个版本号
+ (BOOL)isHigherIOS5;
+ (BOOL)isHigherIOS6;
+ (BOOL)isHigherIOS6P1;
+ (BOOL)isHigherIOS7;
+ (BOOL)isHigherIOS8;

//是否支持拨打电话
-(BOOL) isCanOpenTel;
@end
