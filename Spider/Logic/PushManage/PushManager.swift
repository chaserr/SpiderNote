//
//  PushManager.swift
//  Spider
//
//  Created by 童星 on 16/8/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}




class PushManager: NSObject {

    /** 接受的消息列表 */
    var messageContents:Array = [AnyObject]()
    /** 接受到的消息数 */
    var messageCount:Int?
    /** 接受到的通知数 */
    var notificationCount:Int?
    /** 设备token */
    var device_token:String!
    
    static var instance:PushManager?
    class func getInstance() ->PushManager {
        if (instance == nil) {
            
            instance = PushManager()
        }
        return instance!
    }
    
    override init() {
        super.init()
        messageCount = 0
        notificationCount = 0
    }
    
    
    
}

extension PushManager{

    // 注册本地推送
    func registerLocalPush(_ key:String, pushText:String, date:Date) -> Void {
        // 创建一个本地通知
        let locationNotification:UILocalNotification? = UILocalNotification()
        let pushDate = Date(timeInterval: 0, since: date)
        if locationNotification != nil {
            // 推送时间
            locationNotification!.fireDate = pushDate
            // 设置时区
            locationNotification!.timeZone = TimeZone.current
            // 设置重复时间
            locationNotification!.repeatInterval = NSCalendar.Unit.nanosecond
            // 推送声音
            locationNotification!.soundName = UILocalNotificationDefaultSoundName
            // 推送内容
            locationNotification!.alertBody = pushText
            // 显示在icon上的红色圈子的数字
            locationNotification!.applicationIconBadgeNumber = 1
            // 设置userinfo,方便在之后需要撤销的时候用
            let info = ["key" : key]
            // 添加推送
            UIApplication.shared.scheduleLocalNotification(locationNotification!)
        }
    }
    
    // 取消本地推送
    func uninstallLocalPush(_ key:String) -> Void {
        let localPushArr = UIApplication.shared.scheduledLocalNotifications
        if localPushArr?.count > 0 {
            for localPush:UILocalNotification in localPushArr! {
                let dict = localPush.userInfo
                if (dict != nil) {
                    let infoKey = dict!["key"] as! String
                    if infoKey == key {
                        UIApplication.shared.cancelLocalNotification(localPush)
                       break
                    }
                    
                }
            }
        }
    }
    
    
    
}
