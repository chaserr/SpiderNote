//
//  CommonUtils.h
//  YouYuanCore
//
//  Created by phoenix on 14-10-10.
//  Copyright (c) 2014年 SEU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommonUtils : NSObject

//把string进行URL编码转换统一成NSUTF8StringEncoding格式
+(NSString*)encodeURL:(NSString *)string;

//根据一个数字得到这个数字的最后一位
+(int)getLastIndexNum:(int)num;

//得到当前系统时间，字符串表现形式
+(NSString *)getSysTime;
//
+(NSString *)getSysTimeSSS;

//得到当前系统时间，字符串表现形式
+(NSString *)getSysTimeForTimer;

//根据一个字符串判断一下这个字符串是不是null或者是空串等等不合法的字符
+(BOOL)stringIsNullAndSoOn:(NSString *)tagString;

//用正则表达式去判断用户填写的是飞信号，还是移动手机号码还是联通手机号码还是电信手机号码还是邮箱
+(NSString *)isFetionIdOrCMOrUnCommobileRegxOrTelecommobileOrEmail:(NSString *)num;

//正则，手机号码校验。
+ (BOOL)isValidateMobileNumber:(NSString*)strMobile;

//得到正确的11位手机号
+ (NSString*)getMobileNumber:(NSString*)mobile;

+(BOOL) isPhoneNumber:(NSString * )strMobile;

//判断一下目标字符是不是只含有数字
+(BOOL)isHaveNumber:(NSString *)tagString;

//正则,只含有数字和字母
+(BOOL)isValidateNumberAndAlphabet:(NSString *)str;

//正则邮箱
+(BOOL)isValidateEMail:(NSString *)str;

//正则,只含有数字
+(BOOL)isValidateNumber:(NSString *)str;

//得到本地的messageid
+(int)getLocalMessageId;

//获取默认数据
+(NSString *)getDefaultValue:(NSString *)value;

//将用户的昵称按照一定的长度截取
//aSize：将要截取的长度
+(NSString *)cutOutString:(NSString *)value size:(int)aSize;

//得到中文和英文混合模式下的字符串长度
+(int)getCEStringLength:(NSString*)str;

//根据年月日得到相对应的星期
+(NSString *)getWeek:(NSString *)data;

//格式化时间
+(NSString *)makeTime:(NSString*)aTime;

//消息盒子中的格式化时间
+(NSString *)makeTimeForMessage:(NSString*)aTime;

//过滤字符串中的特殊字符  类似!@#$%^&*() 
+(NSString *)filterNSStringContext:(NSString *)tagValue;

//判断一下是不是合法的飞信号吗
+(BOOL)isOKFetionNo:(NSString *)tagValue;

// 获取生肖
+(NSString*)makeSign:(int)aYear;

// 星座
+(NSString*)WestSign:(int)aMonth Day:(int)aDay;

// 年龄
+(NSString*)GetOld:(int)aYear Month:(int)aMonth Day:(int)aDay;

// 已知总数量和列数求行数
+(int)rowsOf:(int)size withColums:(int)columns;

// 缩放图片
- (UIImage*)scaleAndRotateImage:(UIImage*)photoimage width:(CGFloat)newWidth height:(CGFloat)newHeight;

// 获得设备名称
+ (NSString *)getCurrentDeviceName;

// url字串编码
+(NSString*)urlEncode:(NSString*)url encoding:(NSStringEncoding)stringEncoding;

// 广告标示符（IDFA-identifierForIdentifier）
+(NSString *)advertisingIdentifier;


// md5算法
+(NSString *)md5:(NSString*)str;

// youyuan md5算法
+ (NSString*)gbMD5:(NSString*)value;

// 得到运营商
+ (int)getCarrier;

//验证手机号运营商 1：移动 2：联通：3：电信：4：无
+(int)valiMobile:(NSString *)mobile;

// 判断手机当前状态
+(int )getNetWorkStates;
// 判断手机当前网络状态
//+(int )getNetWorkStates;

@end
