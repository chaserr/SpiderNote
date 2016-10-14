//
//  AppDelegate.swift
//  Spider
//
//  Created by Atuooo on 5/6/16.
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
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        println(FileUtil.getFileUtil().getDocmentPath())
        /** 不自动清理缓存 */
        Kingfisher.ImageCache.defaultCache.maxCachePeriodInSecond = NSTimeInterval.infinity

        setAudioSession()
        
        // shareSDK第三方分享设置
//        setShareSetting()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(manageRealmDB), name: kNotificationLoginStateChanged, object: nil)

        // initLialize
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
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
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: [.DefaultToSpeaker])

        } catch {
            debugPrint(error)
        }
    }
    
    func launchApp(launchOptions: [NSObject: AnyObject]?) -> Void {
        
        startApp(launchOptions)
        
    }
    
    func startApp(launchOptions: [NSObject: AnyObject]?) -> Void {
        
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
    
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName(KNotifcationApplicationDidEnterBackground, object: nil)
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // 后台任务
//        self.beingBackgroundUpdateTask()
//        alert("跳出来不跳出来", message: "跳不逃不出爱", parentVC: getCurrentRootViewController()!)
//        self.endBackgroundUpdateTask()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName(KNotifcationApplicationWillEnterForeground, object: nil)
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // 后台任务
    func beingBackgroundUpdateTask() -> Void {
        self.backgroundUpdateTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ 
            self.endBackgroundUpdateTask()
        })
    }
    
    func endBackgroundUpdateTask() -> Void {
        UIApplication.sharedApplication().endBackgroundTask(self.backgroundUpdateTask!)
        self.backgroundUpdateTask = UIBackgroundTaskInvalid
    }


}

