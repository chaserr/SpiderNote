//
//  LoginManager.swift
//  Spider
//
//  Created by 童星 on 16/8/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import SwiftyJSON

let LOGINMANAGER = LoginManager.getInstance()


enum LoginState:Int {
    case not = -1 // 未登录
    case logining = 0 // 登录中
    case logined = 1 // 已经登录
}

enum AppState:Int {
    case none = 0 // 保留
    case didEnterBackGrouond = 1 // 后台
    case willEnterForeground = 2 // 到前台
}

enum UserEnterType:Int {
    case null = 0
    case register = 1 // 通过注册进入的客户端
    case login = 2 // 通过登录进入的客户端
}

class LoginManager: NSObject {

    /** 应用程序状态 */
    var appState:AppState?
    /** 用户登录状态 */
//    private var _loginState:LoginState // 内部使用
    var loginState:LoginState
    /** 用户注册还是登陆 */
    var loginMode:UserEnterType?
    
    static var instance:LoginManager?
    class func getInstance() ->LoginManager {
        if (instance == nil) {
            
            instance = LoginManager()
        }
        return instance!
    }
    
    override init() {
        
        loginState = LoginState.not
        appState = AppState.willEnterForeground
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name(rawValue: KNotifcationApplicationWillEnterForeground), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: NSNotification.Name(rawValue: KNotifcationApplicationDidEnterBackground), object: nil)
    }
    
    deinit{
    
        NotificationCenter.default.removeObserver(self)
    }
    
    func setLoginState(_ state:LoginState) -> Void {
        if loginState == state {
            return
        }
        loginState = state

    }
    
    func didEnterBackground() -> Void {
        appState = AppState.didEnterBackGrouond
    }
    
    func willEnterForeground() -> Void {
        appState = AppState.didEnterBackGrouond
    }
    
    /** 用户注册*/
    func startRegister(_ account: String, password: String, success: @escaping () -> Void,  failure:@escaping () -> Void) -> Void {
        
        var paramDic = [String : AnyObject]()
        paramDic["userName"] = account as AnyObject
        paramDic["password"] = password as AnyObject
//        AOHUDVIEW.showTips("发送中...")
//        AORequest.init(requestMethod: .POST, specialParameters: paramDic, api: .registerUrl).responseJSON { (response ) in
//            if response.result.isSuccess{
//                AOHUDVIEW.hideLoadingView()
//                let jsonData = JSON(response.result.value!)
//                let dic = JsonStrToDic(jsonData.rawString()!)
//                if (dic!["code"] as! String) == "1003" {
//                
//                    AOHUDVIEW.showTips(dic!["message"] as! String)
//                }else{
//                
//                    AODlog((dic! as NSDictionary).description)
//                    APP_USER.account = account
//                    APP_USER.password = password
//                    APP_USER.saveUserInfo()
//                    success()
//                }
//                
//            }
//            if response.result.isFailure{
//                AOHUDVIEW.hideHUD()
//                if let responseString = response.result.error?.debugDescription {
//                    failure()
//                    AODlog(responseString)
//                }
//            }
//        }

    }
    
    func uploadOperation(_ uploadProObjID: [String]) -> Void {
        var paraDic = [String: AnyObject]()
        let dic: Dictionary = UPLOADPROMANAGER.getSecondRequestParam(uploadProObjID)
        paraDic["projectInfo"] = dic.dicToJSON(dic) as AnyObject
        //        AODlog((paraDic as NSDictionary).description)
        UPLOADPROMANAGER.uploadProject(paraDic, success: {
            alert("上传成功", message: nil, parentVC: getCurrentRootViewController()!)
            
            }, failure: {

        })
    }
    
    /** 发送邮箱验证码*/
    func sendVertifyEmail(_ userName:String, smsCode: String, success: () -> Void, failure: () -> Void) -> Void {
        
        AOHUDVIEW.showLoadingView("注册中...")
        var paramDic = [String : AnyObject]()
        paramDic["userName"] = userName as AnyObject
        paramDic["smsCode"] = smsCode as AnyObject
//        AORequest.init(requestMethod: .POST, specialParameters: paramDic, api: .sendEmailUrl).responseJSON { (response ) in
//            if response.result.isSuccess{
//                AOHUDVIEW.hideLoadingView()
//                AODlog("======注册成功======")
//                let jsonData = JSON(response.result.value!)
//                let dic = JsonStrToDic(jsonData.rawString()!)
//                AODlog((dic! as NSDictionary).description)
//                let code = dic!["code"] as! String
//                if code == "0000" { // 注册成功
//                
//                    AOHUDVIEW.showTips(dic!["message"] as! String)
//                    
//                    // 先把默认的用户的信息都清除， 切换到当前的用户
//                    self.logout(nil) // 相当于退出默认用户
//                    
//                    
//                    APP_UTILITY.currentUser?.token = dic!["token"] as? String
//                    APP_UTILITY.currentUser?.userID = dic!["userId"] as? String
//                    APP_UTILITY.currentUser?.account = APP_USER.account
//                    APP_UTILITY.currentUser?.password = APP_USER.password
//                    APP_UTILITY.saveCurrentUser()
//                    // 保存本次注册的账号
//                    Defaults[OldAccount] = userName
//                    //TODO: 注册成功后要合并本地数据库
//                    // 1. 切换数据库路径
//                    RealmDAO.instance()
//                    let oldSqlPath = FileUtil.getFileUtil().getDocmentPath().stringByAppendingPathComponent(defaultUserID).stringByAppendingPathComponent("sql").stringByAppendingPathComponent("spider.realm")
//                    REALM.copyObjectBetweenRealms(oldSqlPath, willCopyObject: ProjectObject.self)
//                    let userObj = UserObject()
//                    // 保存用户
//                    var nickName: String? = APP_UTILITY.currentUser?.account
//                    nickName = nickName?.substringToIndex((nickName?.startIndex.advancedBy((nickName?.getIndexOf("@"))!))!)
//                    userObj.email = userName
//                    userObj.userName = nickName!
//                    userObj.userId = dic!["userId"] as! String
//                    userObj.createAt = DateUtil.getCurrentDateStringWithFormat(kDUYYYYMMddhhmmss)
//                    userObj.saveUserObj()
//                    // 更新状态机
//                    self.setLoginState(LoginState.Logined)
//                    
//                    // 登录成功后默认同步
//                    var paraDic = [String: AnyObject]()
//                    let padic: Dictionary = SYNCPROMANAGER.getFirstRequestParam()
//                    paraDic["projectInfo"] = padic.dicToJSON(padic)
//                    SYNCPROMANAGER.syncProject(paraDic, success: { (uploadProObjID) in
//                        // 执行上传操作
//                        self.uploadOperation(uploadProObjID)
//                        }, failure: {
//                    })
//                    
//                    
//                    success()
//
//                }
//                else{
//                
//                    AOHUDVIEW.showTips(dic!["message"] as! String)
//                }
//                
//            }
//            if response.result.isFailure{
//                AOHUDVIEW.hideHUD()
//                if let responseString = response.result.error?.debugDescription {
//                    failure()
//                    AODlog(responseString)
//                }
//            }
//        }
    }
    
    /**
     用户登录
     
     - parameter account:  账号
     - parameter password: 密码
     - parameter verType:  登录类型（主动登录, 自动登录）
     */
    func startLogin(_ account:String, password:String, manualLogin: Bool) -> Void {
        loginMode = UserEnterType.login
        if loginState != LoginState.not {
            return
        }
        
        setLoginState(LoginState.logining)
        if manualLogin { // 手动登录显示HUD
            AODlog("=======开始登录======")
            AOHUDVIEW.showLoadingView("登录中...")
        }
        
        var bodyDic = [String : AnyObject]()
        bodyDic["password"] = password as AnyObject
        bodyDic["userName"] = account as AnyObject
        
//        AORequest.init(requestMethod: .POST, specialParameters: bodyDic, api: .loginUrl).responseJSON { (response ) in
//            
//            if response.result.isSuccess {
//                AODlog("======登录成功======")
//                let jsonData = JSON(response.result.value!)
//                let dic = JsonStrToDic(jsonData.rawString()!)
//                AODlog((dic! as NSDictionary).description)
//                self.logout(nil) // 相当于退出默认用户
//                
//                APP_UTILITY.currentUser?.account = account
//                APP_UTILITY.currentUser?.password = password
//                APP_UTILITY.currentUser?.userID = dic!["userId"] as? String
//                APP_UTILITY.currentUser?.token = dic!["token"] as? String
//                APP_UTILITY.saveCurrentUser()
//                APP_USER.account = account
//                APP_USER.password = password
//                APP_USER.saveUserInfo()
//                
//                // 保存本次登录的账号
//                Defaults[OldAccount] = account
//                //TODO: 登录成功后只需要切换数据库
//                RealmDAO.instance()
//                
//                // 保存用户
//                
//                let userObj = UserObject()
//                var userName: String? = APP_UTILITY.currentUser?.account
//                userName = userName?.substringToIndex((userName?.startIndex.advancedBy((userName?.getIndexOf("@"))!))!)
//                userObj.userName = userName!
//                userObj.userId = dic!["userId"] as! String
//                userObj.email = account
//                userObj.password = password
//                userObj.updateAccoundPrimaryKey()
//                
//                
//                // 更新状态机
//                self.setLoginState(LoginState.Logined)
//                
//                // 登录成功后默认同步
//                var paraDic = [String: AnyObject]()
//                let padic: Dictionary = SYNCPROMANAGER.getFirstRequestParam()
//                paraDic["projectInfo"] = padic.dicToJSON(padic)
//                SYNCPROMANAGER.syncProject(paraDic, success: { (uploadProObjID) in
//                    // 执行上传操作
//                    self.uploadOperation(uploadProObjID)
//                    }, failure: {
//                })
//                
//                self.transToController(manualLogin)
//
//            }
//            
//            if response.result.isFailure{
//                AODlog("======登录失败======")
//                self.setLoginState(LoginState.Not)
//                AOHUDVIEW.showTips("登录失败"/*response.result.description*/)
//                if !manualLogin {
//                    
//                    
//                }
//                
//            }
//        }
        
    }
    
    
    func transToController(_ type: Bool) -> Void {
        if type {
            AOHUDVIEW.hideHUD()
        }
        
        let mainViewController = ProjectCollectionViewController()
        AppNavigator.openMainNavControllerWithRoot(mainViewController, animated: true)
    }
    
    func visitorLogin(_ complete: (() -> Void)?) -> Void {
        
        APP_USER.userID = "00000001"
        APP_USER.saveUserInfo()
        APP_UTILITY.currentUser?.userID = "00000001"
        APP_UTILITY.saveCurrentUser()
        if complete != nil
        {
            complete!()
        }
    }
    
    /** 用户登出 */
    func logout(_ complete: (()-> Void)?) -> Void {
        AODlog("======注销======")
        self.setLoginState(LoginState.not)
        APP_UTILITY.clearCurrentUser()
        loginMode = UserEnterType.null
        if complete != nil {
            complete!()
        }
    }
    
    
}
