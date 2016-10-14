//
//  CommonUtils.m
//  YouYuanCore
//
//  Created by phoenix on 14-10-10.
//  Copyright (c) 2014年 SEU. All rights reserved.
//

#import "CommonUtils.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CommonCrypto/CommonDigest.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>


static int selfAddNum = -1;
static int year = -1;
static int month = -1;
static int day = -1;

@implementation CommonUtils

//把string进行URL编码转换统一成NSUTF8StringEncoding格式
+ (NSString*)encodeURL:(NSString *)string
{
	NSString *urlString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    
	if(urlString)
    {
		return urlString;
	}
	return @"";
}

//根据一个数字得到这个数字的最后一位
+(int)getLastIndexNum:(int)num
{
    NSString *stringTemp=[NSString stringWithFormat:@"%d",num];
    NSString *returnString=[stringTemp substringFromIndex:[stringTemp length]-1];
    int lastNum=[returnString intValue];
    return lastNum;
}

//得到当前系统时间，字符串表现形式
+(NSString *)getSysTime
{
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString* date=[formatter stringFromDate:[NSDate date]];
    return date;
}

//得到当前系统时间，字符串表现形式
+(NSString *)getSysTimeSSS
{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    NSString* date=[formatter stringFromDate:[NSDate date]];
    return date;
}

+(NSString *)getSysTimeForTimer
{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString* date=[formatter stringFromDate:[NSDate date]];
    return date;
}

//根据一个字符串判断一下这个字符串是不是null或者是空串等等不合法的字符，这些非法的字符都是一些最基本的，和业务逻辑没有关系的
//后续还会完善
+(BOOL)stringIsNullAndSoOn:(NSString *)tagString
{
    if(tagString==nil)
    {
        return NO;
    }
    else
    {
        if([@"NULL" isEqualToString:tagString])
        {
            return NO;
        }
        if([@"null" isEqualToString:tagString])
        {
            return NO;
        }
        if([@"" isEqualToString:tagString])
        {
            return NO;
        }
        if([tagString isKindOfClass:[NSNull class]]==YES)
        {
            return NO;
        }
        
        return YES;
    }
}


//判断一下是不是合法的飞信号吗
+(BOOL)isOKFetionNo:(NSString *)tagValue
{
    NSString *isOkFetion=@"^\\d{4,10}$";
    NSPredicate *FetionNumPred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", isOkFetion];
    return [FetionNumPred evaluateWithObject:tagValue];
}

// 得到运营商
+ (int)getCarrier
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo  alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSString * mcc = [carrier mobileCountryCode];
    NSString * mnc = [carrier mobileNetworkCode];
    if (mnc == nil || mnc.length <1 || [mnc isEqualToString:@"SIM Not Inserted"] ) {
        return 0;
    }else {
        if ([mcc isEqualToString:@"460"]) {
            NSInteger MNC = [mnc intValue];
            switch (MNC) {
                case 00:
                case 02:
                case 07:
                case 20:
                    return 1;
                    break;
                case 01:
                case 06:
                    return 2;
                    break;
                case 03:
                case 05:
                    return 3;
                    break;
                default:
                    return 0;
                    break;
            }
        }
    }
    
    return 4 ;
}


//验证手机号运营商 1：移动 2：联通：3：电信：4：无
+(int)valiMobile:(NSString *)mobile
{
    
    //移动号段
    NSString *MOBILE_REGX= @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
    
    //联通号段
    NSString *UNICOMMOBILE_REGX=@"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";;
    
    //电信号段
    NSString *TELECOMMOBILE_REGX=@"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
    
    
    //只含有数字
    NSString *ONLYNUM_REGX=@"[0-9]{4,18}";
    
    
    NSPredicate *mobileNumPred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE_REGX];
    
    NSPredicate *unicommobilePred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", UNICOMMOBILE_REGX];
    
    NSPredicate *telecommobilePred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", TELECOMMOBILE_REGX];
    
    
    //只含有数字
    NSPredicate *onlyNumPred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", ONLYNUM_REGX];
    
    
    BOOL isMobileNum=[mobileNumPred evaluateWithObject:mobile];
    
    BOOL isCommobileNum=[unicommobilePred evaluateWithObject:mobile];
    
    BOOL isTelecommobileNum=[telecommobilePred evaluateWithObject:mobile];
    
    BOOL isOnlyNum=[onlyNumPred evaluateWithObject:mobile];
    
    if (mobile.length != 11) {
        //手机位号不对
        NSLog(@"手机号位数不对");
        return 4;
    }
    // 移动手机号
    if (isOnlyNum && isMobileNum) {
        return 1;
    }
    else if (isOnlyNum && isCommobileNum) {
        //联通手机号
        return 2;
    }
    else if (isOnlyNum && isTelecommobileNum) {
        //电信手机号
        return 3;
    }else{
        return 4;
    }
    
    
    
}


// 判断手机当前网络状态
+(int )getNetWorkStates
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    //    NSString *state = [[NSString alloc]init];
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏    0: 无网络 1：2G， 2：3G，3：4G  5:WIFI;
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            
            
            //            switch (netType) {
            //                case 0:
            //                    state = @"无网络";
            //                    //无网模式
            //                    break;
            //                case 1:
            //                    state = @"2G";
            //                    break;
            //                case 2:
            //                    state = @"3G";
            //                    break;
            //                case 3:
            //                    state = @"4G";
            //                    break;
            //                case 5:
            //                {
            //                    state = @"WIFI";
            //                }
            //                    break;
            //                default:
            //                    break;
            //            }
        }
    }
    //根据状态选择
    return netType;
}



//正则，手机号码校验:判断一下是不是正确的手机格式
+ (BOOL)isValidateMobileNumber:(NSString*)strMobile
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    
    /*
     18500041984:       valid
     8618500041984:     valid
     008618500041984:   valid
     +8618500041984:    valid
     08618500041984:    invalid
     ++8618500041984:   invalid
     */
    
    //NSString *reg = @"^((86)|(086)|(0086)|(\\+86)){0,1}((13[0-9])|(15[^4,\\D])|(18[0-9]))\\d{8}$";//Android
    //NSString *mobileRegex = @"^((\\+861)|1)((3[4-9])|(5[0-2|7-9])|(8[7-8])|82|47)[0-9]{8}$";
    //NSString *mobileRegex = @"^((00861)|(\\+861)|(861)|1)(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    NSString *mobileRegex = @"^((00861)|(\\+861)|(861)|1)(3[0-9]|4[0-9]|5[0-9]|7[0-9]|8[0-9])\\d{8}$";
    
    
    NSPredicate *mobileTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    return [mobileTest evaluateWithObject:strMobile];
}
// 是否是手机号码
+(BOOL) isPhoneNumber:(NSString * )strMobile {
    //		String reg2 = "^((861)|(00861)|(\\+861)|1)((3[0-9])|(5[0-3|5-9])|(8[5-9])|82|47|80)[0-9]{8}$";
    NSString * reg = @"^((86)|(086)|(0086)|(\\+86)){0,1}((13[0-9])|(15[^4,\\D])|(18[0-2,5-9]))\\d{8}$";
    NSPredicate *mobileTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];

    return [mobileTest evaluateWithObject:strMobile];

}

//得到正确的11位手机号
+ (NSString*)getMobileNumber:(NSString*)mobile
{
    if(mobile && mobile.length >= 11)
    {
        NSString *last11 = [mobile substringFromIndex:mobile.length - 11];
        
        return last11;
    }
    else
    {
        return nil;
    }
}

+(NSString *)isFetionIdOrCMOrUnCommobileRegxOrTelecommobileOrEmail:(NSString *)num
{
    //判断飞信号码的话，根据是不是只含有数字去判断，要是只含有数字的话，咱去看看是不是手机号码，要是不是手机号码但是还只含有数字的话，那就是飞信号吗了
    //要是不光有数字，还有字母啥的，那就直接去判断邮箱
    
    NSString *MOBILE_REGX=@"^(134|135|136|137|138|139|147|150|151|152|157|158|159|181|182|183|187|188)\\d{8}$";
    
    NSString *UNICOMMOBILE_REGX=@"^1(3[012]|5[56]|8[56])\\d{8}$";
    
    NSString *TELECOMMOBILE_REGX=@"^1((33|53|8[019])\\d{8})|(349\\d{7})$";
    
    NSString *EMAIL_REGX=@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
    
    //只含有数字
    NSString *ONLYNUM_REGX=@"[0-9]{4,18}";
    
    
    NSPredicate *mobileNumPred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE_REGX];
    
    NSPredicate *unicommobilePred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", UNICOMMOBILE_REGX];
    
    NSPredicate *telecommobilePred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", TELECOMMOBILE_REGX];
    
    NSPredicate *emailPred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", EMAIL_REGX];
    
    //只含有数字
    NSPredicate *onlyNumPred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", ONLYNUM_REGX];
    
    
    BOOL isMobileNum=[mobileNumPred evaluateWithObject:num];
    
    BOOL isCommobileNum=[unicommobilePred evaluateWithObject:num];
    
    BOOL isTelecommobileNum=[telecommobilePred evaluateWithObject:num];
    
    BOOL isEmail=[emailPred evaluateWithObject:num];
    
    //只含有数字
    BOOL isOnlyNum=[onlyNumPred evaluateWithObject:num];
    
    
    if(isOnlyNum==YES)
    {
        //如果只含有数字的话，还需要判断一下是移动的还是电信的还是联通的
        if(isMobileNum==YES||isCommobileNum==YES||isTelecommobileNum==YES)
        {
            //移动的
            return @"mobileno";
        }
        else if([CommonUtils isOKFetionNo:num]==YES)
        {
            return @"isfetionid";
        }
        else
        {
            return @"error";
        }
    }
    else
    {
        //不是只含有数字的话，就需要去判断邮箱了
        if(isEmail==YES)
        {
            //是邮箱
            return @"isemail";
        }
    }
    
    return @"error";
}

//判断一下目标字符是不是只含有数字
+(BOOL)isHaveNumber:(NSString *)tagString
{
    NSString *ONLYNUM_REGX=@"^[^0]\\d*$";
    
    NSPredicate *onlyNumPred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", ONLYNUM_REGX];
    
    return [onlyNumPred evaluateWithObject:tagString];
}

//正则,只含有数字和字母
+(BOOL)isValidateNumberAndAlphabet:(NSString *)str
{
    NSString *REGX = @"^[A-Za-z0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGX];
    return [pred evaluateWithObject:str];
}

//正则邮箱
+(BOOL)isValidateEMail:(NSString *)str
{
//    NSString *REGX = @"^[A-Z0-9a-z._%+-]+$";
//
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGX];
//
//    return [pred evaluateWithObject:str];
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:str];
}

//正则,只含有数字
+(BOOL)isValidateNumber:(NSString *)str
{
    
    NSString *REGX = @"^[1-9]\\d*$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGX];
    
    return [pred evaluateWithObject:str];
}

//得到本地系统的messageid
+(int)getLocalMessageId
{
    return arc4random();
    
    if( selfAddNum < 0 )
    {
        // 当前日起
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        NSDate *now;
        
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        
        NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
        
        NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        
        now=[NSDate date];
        
        comps = [calendar components:unitFlags fromDate:now];
        
        //int week = [comps weekday];
        //int hour = [comps hour];
        //int min = [comps minute];
        //int sec = [comps second];
        
        year=[comps year];
        month = [comps month];
        day = [comps day];
        
        // 读取 NSUserDefaults
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"year"]!=nil)
        {
            int yearSaved =[[[NSUserDefaults standardUserDefaults] objectForKey:@"year"] intValue];
            int monthSaved =[[[NSUserDefaults standardUserDefaults] objectForKey:@"month"] intValue];
            int daySaved =[[[NSUserDefaults standardUserDefaults] objectForKey:@"day"] intValue];
            int selfAddNumSaved =[[[NSUserDefaults standardUserDefaults] objectForKey:@"selfAddNum"] intValue];
            
            if( (yearSaved == year) && (monthSaved == month) && (daySaved == day) )
            {
                selfAddNum = selfAddNumSaved+10;
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:year] forKey:@"year"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:month] forKey:@"month"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:day] forKey:@"day"];
                selfAddNum = 0;
            }
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:year] forKey:@"year"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:month] forKey:@"month"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:day] forKey:@"day"];
            selfAddNum = 0;
        }
        
    }
    
    
    selfAddNum++;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:selfAddNum] forKey:@"selfAddNum"];
    
    int localMessageId=[[NSString stringWithFormat:@"1%04d%02d%02d06%d",year,month,day,selfAddNum] intValue];
    
    
    return localMessageId;
    
}

//获取默认数据
+(NSString *)getDefaultValue:(NSString *)value
{
    if([CommonUtils stringIsNullAndSoOn:value]==YES)
    {
        return value;
    }
    else
    {
        return @"";
    }
}

//将用户的昵称按照一定的长度截取
+(NSString *)cutOutString:(NSString *)value size:(int)aSize
{
    if([CommonUtils stringIsNullAndSoOn:value]==YES)
    {
        if(value.length<=aSize)
        {
            return value;
        }
        else
        {
            return [NSString stringWithFormat:@"%@...",[value substringToIndex:aSize]];
        }
    }
    else
    {
        return @"";
    }
}

//得到中文和英文混合模式下的字符串长度
+(int)getCEStringLength:(NSString*)str
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [str dataUsingEncoding:enc];
    return (int)[da length];
}


+(NSString *)getWeek:(NSString *)data
{
    NSArray *array=[data componentsSeparatedByString:@"-"];
    int dayOfWeek;
    int aYear=[[array objectAtIndex:0] intValue];
    int aMonth=[[array objectAtIndex:1] intValue];
    int aDay=[[array objectAtIndex:2] intValue];
    
    dayOfWeek   =   aYear   >   0   ?   (5   +   (aYear   +   1)   +   (aYear   -   1)/4   -   (aYear   -   1)/100   +   (aYear   -   1)/400)   %   7
    :   (5   +   aYear   +   aYear/4   -   aYear/100   +   aYear/400)   %   7;
    dayOfWeek   =   aMonth   >   2   ?   (dayOfWeek   +   2*(aMonth   +   1)   +   3*(aMonth   +   1)/5)   %   7
    :   (dayOfWeek   +   2*(aMonth   +   2)   +   3*(aMonth   +   2)/5)   %   7;
    
    if(((aYear%4   ==   0   &&   aYear%100   !=   0)   ||   aYear%400   ==   0)   &&   aMonth> 2)
    {
        dayOfWeek   =   (dayOfWeek   +   1)   %   7;
    }
    dayOfWeek   =   (dayOfWeek   +   aDay)   %   7;
    
    
    switch (dayOfWeek)
    {
        case 1:
            return @"星期一";
            break;
        case 2:
            return @"星期二";
            break;
        case 3:
            return @"星期三";
            break;
        case 4:
            return @"星期四";
            break;
        case 5:
            return @"星期五";
            break;
        case 6:
            return @"星期六";
            break;
        default:
            return @"星期日";
            break;
    }
    
    return @"日期无效";
}

+(NSString*)makeTime:(NSString*)aTime
{
    if( [CommonUtils stringIsNullAndSoOn:aTime] == NO )
    {
        return @"";
    }
    else if( aTime.length > 12 )
    {
        NSRange range1= NSMakeRange(0,4);
        NSRange range2= NSMakeRange(4,2);
        NSRange range3= NSMakeRange(6,2);
        NSRange range4= NSMakeRange(8,2);
        NSRange range5= NSMakeRange(10,2);
        
        BOOL isToday = NO;
        {
            NSDate *now = [NSDate date];
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
            
            int year = (int)[dateComponent year];
            int month = (int)[dateComponent month];
            int day = (int)[dateComponent day];
            
            int tY = (int)[aTime substringWithRange:range1].integerValue;
            int tM = (int)[aTime substringWithRange:range2].integerValue;
            int tD = (int)[aTime substringWithRange:range3].integerValue;
            
            if( (year==tY) && (month==tM) && (day==tD) )
            {
                isToday = YES;
            }
            
        }
        
        if( isToday )
        {
            //            Modify by Ljc 2013-07-09
#ifdef TEST
            return [NSString stringWithFormat:@"%@:%@:%@",
                    [aTime substringWithRange:range4],
                    [aTime substringWithRange:range5],
                    [aTime substringWithRange:NSMakeRange(12, 2)]];
#else
            return [NSString stringWithFormat:@"%@:%@",[aTime substringWithRange:range4],[aTime substringWithRange:range5]];
#endif
            //            Modify end
        }
        else
        {
            return [NSString stringWithFormat:@"%@-%@-%@ %@:%@",[aTime substringWithRange:range1],[aTime substringWithRange:range2],[aTime substringWithRange:range3],[aTime substringWithRange:range4],[aTime substringWithRange:range5]];
        }
    }
    else
    {
        return @"";
    }
}

//消息盒子中的格式化时间
+(NSString *)makeTimeForMessage:(NSString*)aTime
{
    if( [CommonUtils stringIsNullAndSoOn:aTime] == NO )
    {
        return @"";
    }
    else if( aTime.length > 12 )
    {
        NSRange range1= NSMakeRange(0,4);
        NSRange range2= NSMakeRange(4,2);
        NSRange range3= NSMakeRange(6,2);
        NSRange range4= NSMakeRange(8,2);
        NSRange range5= NSMakeRange(10,2);
        NSRange range6= NSMakeRange(12,2);
        
        return [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",[aTime substringWithRange:range1],[aTime substringWithRange:range2],[aTime substringWithRange:range3],[aTime substringWithRange:range4],[aTime substringWithRange:range5],[aTime substringWithRange:range6]];
    }
    else
    {
        return @"";
    }
}

//过滤字符串中的特殊字符  类似!@#$%^&*()
+(NSString *)filterNSStringContext:(NSString *)tagValue
{
    NSString*bStr =(__bridge_transfer NSString *)(CFURLCreateStringByAddingPercentEscapes (kCFAllocatorDefault, (CFStringRef)tagValue,NULL,CFSTR(":/?#[]@!$&’()*+,;=%^<>.|\\\"_-+'"), kCFStringEncodingUTF8));
    return bStr;
}

+(NSString*)makeSign:(int)aYear
{
    static NSArray* arr = nil;
    if( arr == nil )
        arr = [NSArray arrayWithObjects:@"猴", @"鸡", @"狗", @"猪", @"鼠", @"牛", @"虎", @"兔", @"龙", @"蛇", @"马", @"羊", nil];
    
    aYear = aYear % 12;
    return [arr objectAtIndex:aYear];
}

+(NSString*)WestSign:(int)aMonth Day:(int)aDay
{
    static NSString *allWestSign = @"魔羯水瓶双鱼牡羊金牛双子巨蟹狮子处女天秤天蝎射手";
    static int seps[] = {20, 19, 21, 21, 21, 22, 23, 23, 23, 23, 22, 22};
    
    aMonth--;
    if( aDay >= seps[aMonth] )
    {
        aMonth+=1;
    }
    
    NSRange aRange;
    aRange.location = aMonth % 12 * 2;
    aRange.length = 2;
    return [allWestSign substringWithRange:aRange];
}

+(NSString*)GetOld:(int)aYear Month:(int)aMonth Day:(int)aDay
{
    static int year_now = -1;
    static int month_now = -1;
    static int day_now = -1;
    
    if( year_now < 0 )
    {
        NSDate *now = [NSDate date];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
        
        year_now = (int)[dateComponent year];
        month_now = (int)[dateComponent month];
        day_now = (int)[dateComponent day];
    }
    
    int old = year_now - aYear;
    if( aMonth > month_now )
        old -= 1;
    else if( (aMonth == month_now) && (aDay > day_now))
    {
        old -= 1;
    }
    
    return [NSString stringWithFormat:@"%d",old];
    
}

/*
* 已知总数量和列数求行数
*
* @param size       总数量
* @param columns    列数
* @return           计算得到的行数
*
*/
+(int)rowsOf:(int)size withColums:(int)columns
{
    if (size < 1 || columns < 1)
        return 0;
    // 整除
    BOOL isDivisible = ((size % columns) == 0);
    if (isDivisible)
    {
        return size / columns;
    }
    else
    {
        return size / columns + 1;
    }
}

/*
 * 缩放图片
 *
 * @param photoimage    原图
 * @param newWidth      新长度
 * @param newHeight     新高度
 * @return              缩放以后的新图
 *
 */
-(UIImage*)scaleAndRotateImage:(UIImage*)photoimage width:(CGFloat)newWidth height:(CGFloat)newHeight
{
    if(nil == photoimage)
        return nil;
    
    CGImageRef imgRef =photoimage.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    bounds.size.width = newWidth;
    bounds.size.height = newHeight;
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGFloat scaleRatioheight = bounds.size.height / height;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient =photoimage.imageOrientation;
    switch(orient)
    {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid?image?orientation"];
            break;
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatioheight);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatioheight);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
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

+ (NSString*)urlEncode:(NSString*)url encoding:(NSStringEncoding)stringEncoding
{
	NSArray *escapeChars = [NSArray arrayWithObjects:/*@";", @"/", @"?", @":",*/
							/*@"@", @"&", @"=", */@"+", /*@"$", @",", @"!",
                                                         @"'", @"(", @")", @"*", @"-",*/ nil];
	
	NSArray *replaceChars = [NSArray arrayWithObjects:/*@"%3B", @"%2F", @"%3F", @"%3A",*/
							 /*@"%40", @"%26", @"%3D",*/@"%2B", /*@"%24", @"%2C", @"%21",
                                                                 @"%27", @"%28", @"%29", @"%2A", @"%2D",*/ nil];
	int len = [escapeChars count];
	NSString *tempStr = [url stringByAddingPercentEscapesUsingEncoding:stringEncoding];
	if (tempStr == nil) {
		return nil;
	}
	NSMutableString *temp = [tempStr mutableCopy];
	int i;
	for (i = 0; i < len; i++) {
		
		[temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
	}
	NSString *outStr = [NSString stringWithString: temp];
	return outStr;
}

// 广告标示符（IDFA-identifierForIdentifier）
+ (NSString *)advertisingIdentifier
{
    //示例: 1E2DFA89-496A-47FD-9941-DF1FC4E6484A
    NSString *adId =[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    return adId;
}



+ (NSString *)md5:(NSString*)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int) strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString*)gbMD5:(NSString*)value
{
    NSString* key = @"yYER!@UO-L#F13^Ey!@";
    NSString* str = [NSString stringWithFormat:@"%@%@", value, key];
    str = [CommonUtils md5:str];
    
    NSRange range = NSMakeRange(0, 12);
    str = [str substringWithRange:range];
    
    str = [CommonUtils md5:str];
    
    range = NSMakeRange(0, 16);
    str = [str substringWithRange:range];
    
    return str;
}

@end
