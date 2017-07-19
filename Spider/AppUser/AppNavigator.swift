//
//  AppNavigator.swift
//  Spider
//
//  Created by 童星 on 16/7/4.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  导航跳转

import UIKit

let APP_NAVIGATOR = AppNavigator.getInstance()


class AppNavigator: NSObject, CAAnimationDelegate {
    var mainNav: UINavigationController?
    
    var topVC: UIViewController? {
        guard let nav = mainNav else { return nil }
        return nav.topViewController
    }

    static var instance:AppNavigator?
    class func getInstance() ->AppNavigator {
        if (instance == nil) {
            instance = AppNavigator()
        }
        return instance!
    }
    
    // 显示模态视图
    class func presentViewController(_ viewcontroller:UIViewController, animation:Bool, completion: (() -> Void)?) -> Void {
        let presentCon = AppNavigator.getInstance().mainNav?.presentedViewController
        if presentCon != nil && (presentCon?.isKind(of: BaseNavViewController.self))! {
            (presentCon as! BaseNavViewController).present(viewcontroller, animated: animation, completion: completion)
        }else{
        
            AppNavigator.getInstance().mainNav?.present(viewcontroller, animated: animation, completion: completion)
        }
    }
    
    
    // 打开根视图界面
    class func openMainNavControllerWithRoot(_ rootViewController:UIViewController, animated:Bool) -> Void {
        let delegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // 执行动画
        if animated {
            let animation:CATransition = CATransition()
//            animation.delegate = self
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade
            animation.subtype = kCATransitionFromLeft
            delegate.window?.layer.add(animation, forKey: "animation")
        }        
        
        let nav:BaseNavViewController = BaseNavViewController(rootViewController: rootViewController)
        let leftViewController = LeftMenuViewController()
        
//        (leftViewController.mainViewController) = nav
        let slideMenuController = SlideMenuController(mainViewController: nav, leftMenuViewController: leftViewController)
        delegate.window?.rootViewController = slideMenuController
        AppNavigator.getInstance().mainNav = nav
        
    }
    
    // MARK: push操作
    class func pushViewController(_ viewcontroller:UIViewController,animated:Bool) -> Void {
        // 如果不使用系统的动画，就是用自定义动画
        if animated == false {
            let delegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let animation:CATransition = CATransition()
//            animation.delegate = self
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFromRight
            
            delegate.window?.layer.add(animation, forKey: "animation")
            
        }
        
        let pressentCon = (AppNavigator.getInstance().mainNav?.presentedViewController)
        if pressentCon != nil && pressentCon?.isKind(of: BaseNavViewController.self) != nil {
            (pressentCon as! BaseNavViewController).pushViewController(viewcontroller, animated: animated)
            
        } else{
        
            AppNavigator.getInstance().mainNav?.pushViewController(viewcontroller, animated: animated)
        }
        
    }
    // MARK:pop操作
    class func popViewControllerAnimated(_ animated:Bool) -> Void {
        // 如果不使用系统的动画，就是用自定义动画
        if animated == false {
            let delegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let animation:CATransition = CATransition.init()
//            animation.delegate = self
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
            animation.type = kCATransitionFade;
            animation.subtype = kCATransitionFromRight;
            
            delegate.window?.layer.add(animation, forKey: "animation")
        }
        
        let pressentCon = (AppNavigator.getInstance().mainNav?.presentedViewController)
        if pressentCon != nil && pressentCon?.isKind(of: BaseNavViewController.self) != nil {
            (pressentCon as! BaseNavViewController).popViewController(animated: animated)
        }else{
            
            AppNavigator.getInstance().mainNav?.popViewController(animated: animated)
        }
    }
    
    // MARK:打开主界面
    class func openMainViewController() -> Void {
        let mainViewController = ProjectCollectionViewController()
        AppNavigator.openMainNavControllerWithRoot(mainViewController, animated: true)
        
    }
    
    // MARK: push到根视图
    class func popToRootViewController(_ animation:Bool) -> Void {
        APP_NAVIGATOR.mainNav?.popToRootViewController(animated: animation)
    }
    
    // 切换window根视图到注册/登录界面
    class func openRegisterOrLoginViewControllerWithRoot(_ rootViewController:UIViewController, animated:Bool) -> Void {
        let delegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // 执行动画
        if !animated {
            let animation:CATransition = CATransition()
//            animation.delegate = self
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade
            animation.subtype = kCATransitionFromRight
            delegate.window?.layer.add(animation, forKey: "animation")
        }
        
        let nav:BaseNavViewController = BaseNavViewController(rootViewController: rootViewController)
        delegate.window?.rootViewController = nav
        AppNavigator.getInstance().mainNav = nav
        
    }
 
    
    // 打开注册界面
    class func openRegisterViewController() -> Void {
    
        let storyBoard = UIStoryboard.init(name: "RegisterLogin", bundle: nil)
        let reg = storyBoard.instantiateInitialViewController()
        AppNavigator.presentViewController(reg!, animation: true, completion: nil)
//        AppNavigator.openRegisterViewControllerWithRoot(reg!, animated: true)
    }
    
    // 打开登录界面
    class func openLoginController() -> Void {
        let storyBoard = UIStoryboard.init(name: "RegisterLogin", bundle: nil)
        let log: LoginVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let loginVCNav = BaseNavViewController(rootViewController: log)
        AppNavigator.presentViewController(loginVCNav, animation: true) {
            
        }
    }
    
    // 打开登录界面
    class func openOtherAccountLoginController() -> Void {
        let storyBoard = UIStoryboard.init(name: "RegisterLogin", bundle: nil)
        let log: OtherAccountLoginVC = storyBoard.instantiateViewController(withIdentifier: "OtherAccountLoginVC") as! OtherAccountLoginVC
        let loginVCNav = BaseNavViewController(rootViewController: log)
        AppNavigator.presentViewController(loginVCNav, animation: true) {
            
        }
    }
    

}

