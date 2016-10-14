//
//  NSDate+Ext.swift
//  Spider
//
//  Created by 童星 on 16/7/7.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

struct ConvertNSDate {
    
    //NSDate → String转换
    static func convertNSDateToString (date: NSDate) -> String {
        
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.locale               = NSLocale(localeIdentifier: "zh_CN")
        dateFormatter.dateFormat           = "yyyy.MM.dd"
        let dateString: String             = dateFormatter.stringFromDate(date)
        return dateString
    }
}


extension NSDate {

    /** 时间 -> 时间戳 */
    class func stringToTimeStamp() -> String {
        let nowTime   = NSDate()
        let timeStamp = Int(nowTime.timeIntervalSince1970)
        return String(timeStamp)
    }
    /** 时间戳 -> 时间 */
    class func timeToTimeStamp(timeStamp:String, dateFormat:String) -> String {
        let timeInterval: NSTimeInterval = NSTimeInterval(timeStamp)!
        let covDate                      = NSDate(timeIntervalSince1970: timeInterval)
        let dFormatter                   = NSDateFormatter()
        dFormatter.dateFormat            = dateFormat
        return dFormatter.stringFromDate(covDate)

    }
    /** 输出为美国格式时间*/
    func output_en_USformat(covDate: NSDate) -> String {
        let dateFormatter       = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.locale    = NSLocale(localeIdentifier: "en_US")// zh_CN  en_US
//        let today:NSDate = NSDate()
        let dateString          = dateFormatter.stringFromDate(covDate)
        return dateString
        //结果：Aug 30, 2015, 10:57:33 AM
    }
    /** 将某个美国格式的时间字符串转换成中国格式的时间字符串*/
    func output_zh_CNformat(dateStr: String) -> String {
        let dateFormatter       = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.locale    = NSLocale(localeIdentifier: "en_US")// zh_CN  en_US
        let ndate               = dateFormatter.dateFromString(dateStr)
        let endDateString       = ndate!.description
        let ns2                 = (endDateString as NSString).substringToIndex(16)
        return ns2
    }
    
    
}

