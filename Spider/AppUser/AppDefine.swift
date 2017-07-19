//
//  AppDefine.swift
//  Spider
//
//  Created by 童星 on 16/7/15.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit


/** Notification Name*/
/** 登录监听*/
let kNotificationLoginStateChanged             = "kNotificationLoginStateChanged"
let kNotificationLoginSuccessed                = "kNotificationLoginSuccessed"
/** 前后台状态改变 */
let KNotifcationApplicationDidEnterBackground  = "KNotifcationApplicationDidEnterBackground"
let KNotifcationApplicationWillEnterForeground = "KNotifcationApplicationWillEnterForeground"
/** 网络状态改变 */
let KNotifcationNetworkReachabilityChanged     = "KNotifcationNetworkReachabilityChanged"
/** 用户登录状态改变 */
let KNotifcationUserLoginStateChanged          = "KNotifcationUserLoginStateChanged"

/** 查找图片线程名*/
let KfetchImageFromCache                       = "KfetchImageFromCache"

/** 同步完成*/
let kSyncSuccessNotification                   = "kSyncSuccessNotification"





/** all enum type*/


enum CreateDate:Int {
    case none
    case today           = 1
    case yesterday       = 2
    case beforeYesterday = 3
    case earlyday        = 4
}

enum SourceMindControType:Int {
    case comeFromHome = 0//"ProjectCollectionViewController"
    case comeFromSearch //= "SearchMainViewController"
    case comeFromSelf //= "MindViewController"
    case comeFromStructLevel //= "StructLevelView"
    case comeFromOutLine //= ""
}

enum SearchType:String {
    case Hestory
    case MindType
    case Project
}
