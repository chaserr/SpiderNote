//
//  AppDelegate.swift
//  Spider
//
//  Created by 童星 on 5/6/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift
import Kingfisher

class AppInstallInfo {
    /** 软件是否激活： */
    var isActived:Bool!
    var userAccountDic:NSMutableDictionary! 
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var appInstallInfo:AppInstallInfo!
    var backgroundUpdateTask: UIBackgroundTaskIdentifier?
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        AODlog(FileUtil.getFileUtil().getDocmentPath())
        /** 不自动清理缓存 */
        ImageCache.default.maxCachePeriodInSecond = TimeInterval.infinity

        setAudioSession()
        
        // shareSDK第三方分享设置
//        setShareSetting()
        
        NotificationCenter.default.addObserver(self, selector: #selector(manageRealmDB), name: NSNotification.Name(rawValue: kNotificationLoginStateChanged), object: nil)

        // initLialize
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        
        // Override point for customization after application launch.
        
//         是否进入引导页
//        if VERSIONMANAGE.showGuidePage() {
//            AOHUDVIEW.showTipsWithAutoHide("引导页", autoHideTime: 1)
            
//        }else{
        
            launchApp(launchOptions)
//        }
        
        /** Controller */
        

        return true
    }
    
    func setAudioSession() {
        do {

            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.defaultToSpeaker])

        } catch {
            debugPrint(error)
        }
    }
    
    func launchApp(_ launchOptions: [AnyHashable: Any]?) -> Void {
        
        startApp(launchOptions)
        
    }
    
    func startApp(_ launchOptions: [AnyHashable: Any]?) -> Void {
        
        // 初始化登录管理
        LoginManager.getInstance()
        /** 先初始化 Realm */
        manageRealmDB()
        
        addLeftMenuController()

        
//        // 如果当前用户存在，那么之前登陆过，直接进入主界面
//        if APP_UTILITY.checkCurrentUser() {
//            addLeftMenuController()
//        }else{ //否则打开注册界面
//            
//            if Defaults.hasKey(OldAccount) {
//                let LoginVC = getViewControllerFromStoryBoard("RegisterLogin", viewControllerIdentify: "LoginVC")
//                AppNavigator.openRegisterOrLoginViewControllerWithRoot(LoginVC, animated: true)            }else{
//            
//                let otherAccountLoginVC = getViewControllerFromStoryBoard("RegisterLogin", viewControllerIdentify: "OtherAccountLoginVC")
//                AppNavigator.openRegisterOrLoginViewControllerWithRoot(otherAccountLoginVC, animated: true)            }
//            
//    
//        }
    
    }
    
    func addLeftMenuController() -> Void {
        
        let mainViewController = ProjectCollectionViewController()

        AppNavigator.openMainNavControllerWithRoot(mainViewController, animated: false)
    }
    
    func manageRealmDB() -> Void {
        
        RealmDAO.instance()
    }
    
//    func setShareSetting() -> Void {
//        
//        ShareSDK.registerApp(kShareAppKey,
//         activePlatforms:
//            [
//                SSDKPlatformType.TypeSinaWeibo.rawValue,
//                SSDKPlatformType.SubTypeWechatSession.rawValue,
//                SSDKPlatformType.SubTypeWechatTimeline.rawValue,
//                SSDKPlatformType.SubTypeQZone.rawValue,
//                SSDKPlatformType.TypeQQ.rawValue
//            ],
//         // onImport 里的代码,需要连接社交平台SDK时触发
//            onImport: { (platform: SSDKPlatformType) in
//                switch platform{
//                
//                case SSDKPlatformType.TypeSinaWeibo:
//                    ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
//                case SSDKPlatformType.SubTypeWechatSession:
//                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
//                case SSDKPlatformType.SubTypeWechatTimeline:
//                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
//                case SSDKPlatformType.SubTypeQZone:
//                    ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
//                case SSDKPlatformType.TypeQQ:
//                    ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
//                default: break
//                }
//            },
//            onConfiguration: { (plantform: SSDKPlatformType, appInfo: NSMutableDictionary!) -> Void in
//            
//                switch plantform {
//                
//                case SSDKPlatformType.TypeSinaWeibo:
//                    appInfo.SSDKSetupSinaWeiboByAppKey(kSinaAppKey, appSecret: kSinaAppSecret, redirectUri: kSinaCallBackUrl, authType: SSDKAuthTypeBoth)
//                case SSDKPlatformType.SubTypeWechatSession:
//                    appInfo.SSDKSetupWeChatByAppId(kWexinAppId, appSecret: kWeixinAppSecret)
//                case SSDKPlatformType.SubTypeWechatTimeline:
//                    appInfo.SSDKSetupWeChatByAppId(kWexinAppId, appSecret: kWeixinAppSecret)
//
//                case SSDKPlatformType.SubTypeQZone:
//                    appInfo.SSDKSetupQQByAppId(kQQAppID, appKey: kQQAppKey, authType: SSDKAuthTypeBoth)
//
//                case SSDKPlatformType.TypeQQ:
//                    appInfo.SSDKSetupQQByAppId(kQQAppID, appKey: kQQAppKey, authType: SSDKAuthTypeBoth)
//
//                default: break
//                }
//            
//        })
//        
//    }
    
//    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
//        return WXApi.handleOpenURL(url, delegate: self)
//    }
//    
//    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
//        return WXApi.handleOpenURL(url, delegate: self)
//
//    }
    
    deinit{
    
        NotificationCenter.default.removeObserver(self)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: KNotifcationApplicationDidEnterBackground), object: nil)
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // 后台任务
//        self.beingBackgroundUpdateTask()
//        alert("跳出来不跳出来", message: "跳不逃不出爱", parentVC: getCurrentRootViewController()!)
//        self.endBackgroundUpdateTask()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: KNotifcationApplicationWillEnterForeground), object: nil)
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // 后台任务
    func beingBackgroundUpdateTask() -> Void {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { 
            self.endBackgroundUpdateTask()
        })
    }
    
    func endBackgroundUpdateTask() -> Void {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask!)
        self.backgroundUpdateTask = UIBackgroundTaskInvalid
    }


}

