//
//  PushManager.swift
//  Spider
//
//  Created by 童星 on 16/8/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit



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
    func registerLocalPush(key:String, pushText:String, date:NSDate) -> Void {
        // 创建一个本地通知
        let locationNotification:UILocalNotification? = UILocalNotification()
        let pushDate = NSDate(timeInterval: 0, sinceDate: date)
        if locationNotification != nil {
            // 推送时间
            locationNotification!.fireDate = pushDate
            // 设置时区
            locationNotification!.timeZone = NSTimeZone.defaultTimeZone()
            // 设置重复时间
            locationNotification!.repeatInterval = NSCalendarUnit.Nanosecond
            // 推送声音
            locationNotification!.soundName = UILocalNotificationDefaultSoundName
            // 推送内容
            locationNotification!.alertBody = pushText
            // 显示在icon上的红色圈子的数字
            locationNotification!.applicationIconBadgeNumber = 1
            // 设置userinfo,方便在之后需要撤销的时候用
            let info = ["key" : key]
            // 添加推送
            UIApplication.sharedApplication().scheduleLocalNotification(locationNotification!)
        }
    }
    
    // 取消本地推送
    func uninstallLocalPush(key:String) -> Void {
        let localPushArr = UIApplication.sharedApplication().scheduledLocalNotifications
        if localPushArr?.count > 0 {
            for localPush:UILocalNotification in localPushArr! {
                let dict = localPush.userInfo
                if (dict != nil) {
                    let infoKey = dict!["key"] as! String
                    if infoKey == key {
                        UIApplication.sharedApplication().cancelLocalNotification(localPush)
                       break
                    }
                    
                }
            }
        }
    }
    
    
    
}
