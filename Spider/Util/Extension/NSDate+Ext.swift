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
    static func convertNSDateToString (_ date: Date) -> String {
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale               = Locale(identifier: "zh_CN")
        dateFormatter.dateFormat           = "yyyy.MM.dd"
        let dateString: String             = dateFormatter.string(from: date)
        return dateString
    }
}


extension Date {

    /** 时间 -> 时间戳 */
    static func stringToTimeStamp() -> String {
        let nowTime   = Date()
        let timeStamp = Int(nowTime.timeIntervalSince1970)
        return String(timeStamp)
    }
    /** 时间戳 -> 时间 */
    static func timeToTimeStamp(_ timeStamp:String, dateFormat:String) -> String {
        let timeInterval: TimeInterval = TimeInterval(timeStamp)!
        let covDate                      = Date(timeIntervalSince1970: timeInterval)
        let dFormatter                   = DateFormatter()
        dFormatter.dateFormat            = dateFormat
        return dFormatter.string(from: covDate)

    }
    /** 输出为美国格式时间*/
    func output_en_USformat(_ covDate: Date) -> String {
        let dateFormatter       = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.medium
        dateFormatter.locale    = Locale(identifier: "en_US")// zh_CN  en_US
//        let today:NSDate = NSDate()
        let dateString          = dateFormatter.string(from: covDate)
        return dateString
        //结果：Aug 30, 2015, 10:57:33 AM
    }
    /** 将某个美国格式的时间字符串转换成中国格式的时间字符串*/
    func output_zh_CNformat(_ dateStr: String) -> String {
        let dateFormatter       = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.medium
        dateFormatter.locale    = Locale(identifier: "en_US")// zh_CN  en_US
        let ndate               = dateFormatter.date(from: dateStr)
        let endDateString       = ndate!.description
        let ns2                 = (endDateString as NSString).substring(to: 16)
        return ns2
    }
    
    
}

