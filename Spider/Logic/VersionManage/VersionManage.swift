//
//  VersionManage.swift
//  Spider
//
//  Created by 童星 on 16/7/26.
//  Copyright © 2016年 oOatuo. All rights reserved.
//


import UIKit
let VERSIONMANAGE = VersionManage.getInstance()

/**
    版本更新，不过现在基本不需要用户自己进行版本更新了，苹果会自动在有新版本时，提示用户。并且如果强制添加版本更新功能，应用会被打回
 */
class VersionManage: NSObject {

    static var instance:VersionManage?
    class func getInstance() ->VersionManage {
        if (instance == nil) {
            
            instance = VersionManage()
        }
        return instance!
    }
    
    /**获取本地版本号*/
    func appLocalVersion() -> String {
        let info:[String:AnyObject] = Bundle.main.infoDictionary! as [String : AnyObject]
        let version:String = info["CFBundleVersion"] as! String
        return version.trimmingCharacters(in: CharacterSet.letters)
        
    }

    
    /** 是否显示引导页*/
    func showGuidePage() -> Bool {
        if Defaults.hasKey(CurrentAppVersionKey){
            let version:String             = Defaults.object(forKey: CurrentAppVersionKey) as! String
            if version == appLocalVersion() {
                return false
            }else{
                // 如果不等，说明版本进行了升级，
                // 先存储当前版本
                Defaults[CurrentAppVersionKey] = appLocalVersion()
                return true
            }
        }else{

            // 没有值，第一次启动
            return true

        }
    }
}
