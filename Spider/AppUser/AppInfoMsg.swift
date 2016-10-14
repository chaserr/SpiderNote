//
//  AppInfoMsg.swift
//  Spider
//
//  Created by 童星 on 16/7/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

let APP_INFO = AppInfoMsg.getInstance()


class AppInfoMsg: NSObject {

    var account :String? = "aozzz"
    var password :Int? = 123
    var token:String? = nil
    var sessionId:String? = nil
    
    
    
    static var instance:AppInfoMsg?
    class func getInstance() ->AppInfoMsg {
        if (instance == nil) {
            instance = AppInfoMsg()
        }
        return instance!
    }
    //声明为单例
    
    override init() {
        self.account = Defaults[.account]
        self.password = Defaults[.password]
        self.token = Defaults[.token]
        self.sessionId = Defaults[.sessionId]
        
    }
    
    func save() -> Void {
        Defaults[.account] = self.account
        Defaults[.password] = self.password
        Defaults[.token] = self.token
        Defaults[.sessionId] = self.sessionId
    }
    
    func checkHaveUserAccount() -> Bool {
        if self.account != nil && self.token != nil {
            return true
        }
        
        return false
    }
}




// MARK: -- userDefault中存在的键值
extension DefaultsKeys{

    static let account = DefaultsKey<String?>("account")
    static let password = DefaultsKey<Int?>("password")
    static let token    = DefaultsKey<String?>("token")
    static let sessionId = DefaultsKey<String?>("sessionId")
    
}



