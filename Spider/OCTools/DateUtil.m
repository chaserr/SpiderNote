//
//  DateUtil.m
//  YouYuan
//
//  Created by phoenix on 14-10-10.
//  Copyright (c) 2014年 SEU. All rights reserved.
//

#import "DateUtil.h"
#define kSecondsPerDay 24 * 60 * 60

@implementation DateUtil

+ (NSString*)getDateStringWithSecound:(NSTimeInterval)secs format:(NSString *)format
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:secs];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *ymds = [formatter stringFromDate:date];
    return ymds;
}

+ (NSString*)getCurrentDateStringWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *now = [dateFormatter stringFromDate:[NSDate date]];
    return now;
}

+ (NSString *)stringWithDateFormat:(NSString *)string sFormat:(NSString *)sFormat dFormat:(NSString *)dFormat;
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:sFormat];
    NSDate *date = [formatter dateFromString:string];
    [formatter setDateFormat:dFormat];
    NSString *ymds = [formatter stringFromDate:date];
    return ymds;
}

+ (NSTimeInterval)timeIntervalWithGMTDateFormat:(NSString *)gmtDateString gmtFormat:(NSString *)gmtFormat
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat:gmtFormat];
    NSDate *date = [formatter dateFromString:gmtDateString];
    return [date timeIntervalSince1970];
}

+ (NSTimeInterval)timeIntervalWithDateFormat:(NSString *)string sFormat:(NSString *)sFormat dFormat:(NSString *)dFormat
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:sFormat];
    NSDate *date = [formatter dateFromString:string];
    [formatter setDateFormat:dFormat];
    return [date timeIntervalSince1970];
}

+ (NSDate *)stringToNSDate:(NSString *)string format:(NSString*)aFormat
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:aFormat];
    NSDate *date = [formatter dateFromString :string];
    return date;
}

+ (NSTimeInterval)stringToNSTimeInterval:(NSString *)string format:(NSString*)aFormat
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:aFormat];
    NSDate *date = [formatter dateFromString :string];
    return [date timeIntervalSince1970];
}

+ (NSTimeInterval)stringToNSTimeIntervalWithUTC:(NSString *)string format:(NSString *)aFormat{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:aFormat];
    NSDate *date = [formatter dateFromString :string];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSTimeInterval interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return [localeDate timeIntervalSince1970];
}

//处理时间显示格式
+ (NSString *)handleDateStr:(NSTimeInterval)msgTime
{
    NSString *strTimeStamp = [DateUtil getDateStringWithSecound:msgTime format:kDU_YYYYMMddhhmmss];
    NSString *date = nil;
    NSString *time = nil;
    if (strTimeStamp)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:kDU_yyyyMMdd];
        NSString *strToday = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *strMsgDay = [strTimeStamp substringToIndex:[strTimeStamp rangeOfString:@" "].location];

        if ([strMsgDay isEqualToString:strToday])
        {
            date = @"Today";
        }
        else if ([strMsgDay length] > 5)
        {
            date = [strMsgDay substringFromIndex:5];
        }
        time = [strTimeStamp substringFromIndex:[strTimeStamp rangeOfString:@" "].location + 1];
        if ([time length] == 8)
        {
            time = [time substringToIndex:5];
        }
        if ([date isEqualToString:@"Today"])
        {
            strTimeStamp = [NSString stringWithFormat:@"%@", time];
        }
        else
        {
            strTimeStamp = [NSString stringWithFormat:@"%@", date];
        }
    }
    return strTimeStamp;
}

//标注时间
+ (NSString *)timeIntervalToString:(NSTimeInterval)msgTime
{
    //当前时间戳
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    
    NSString *strTimeStamp = nil;

    NSTimeInterval diff = nowTime - msgTime;
    if (diff < kSecondsPerDay)
    {
        NSUInteger hours= diff/(kSecondsPerDay/24);
        
        if(hours == 0)
        {
            strTimeStamp = @"刚刚";
        }
        else
        {
            strTimeStamp = [NSString stringWithFormat:@"%lu小时前",(unsigned long)hours];
        }
    }
    else
    {
        strTimeStamp = [self getDateStringWithSecound:msgTime format:kDU_MMdd];
    }
    return strTimeStamp;
}

+ (NSString *)formatDateString:(NSString *)string fromFormat:(NSString *)fromFormat
{
    return [self handleDateStr:[self stringToNSTimeInterval:string format:fromFormat]];
}

+ (DUDateType)handleDateType:(NSTimeInterval)msgTime
{
    DUDateType type = kDUNone;
    NSString *strTimeStamp = [DateUtil getDateStringWithSecound:msgTime format:kDU_YYYYMMddhhmmss];
    if (strTimeStamp)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:kDU_yyyyMMdd];
        NSString *strToday = [dateFormatter stringFromDate:[NSDate date]];
        
        NSDate *yesterday = [[NSDate alloc] initWithTimeIntervalSinceNow:- (kSecondsPerDay)];
        NSString *strYesterday = [dateFormatter stringFromDate:yesterday];
        
        NSDate *dayBeforeYesterday = [[NSDate alloc] initWithTimeIntervalSinceNow:-(kSecondsPerDay) * 2];
        NSString *strDayBeforeYesterday = [dateFormatter stringFromDate:dayBeforeYesterday];
        
        NSString *strMsgDay = [strTimeStamp substringToIndex:[strTimeStamp rangeOfString:@" "].location];
        
        if ([strMsgDay isEqualToString:strToday])
        {
            type = kDUToday;
        }
        else if ([strMsgDay isEqualToString:strYesterday])
        {
            type = kDUYesterday;
        }
        else if ([strMsgDay isEqualToString:strDayBeforeYesterday])
        {
            type = kDUBeforeYesterday;
        }
        else if ([strMsgDay length] > 5)
        {
            type = kDUEarlyday;
        }
    }
    return type;
}

@end
