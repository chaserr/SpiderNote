//
//  UIViewControllerExtensions.swift
//  EZSwiftExtensions
//
//  Created by Goktug Yilmaz on 15/07/15.
//  Copyright (c) 2015 Goktug Yilmaz. All rights reserved.
//

import UIKit

extension UIViewController {
    // MARK: - Notifications
    //TODO: Document this part
    public func addNotificationObserver(name: String, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
    }

    public func removeNotificationObserver(name: String) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: name), object: nil)
    }

    public func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    #if os(iOS)

    public func addKeyboardWillShowNotification() {
        self.addNotificationObserver(name: NSNotification.Name.UIKeyboardWillShow.rawValue, selector: #selector(UIViewController.keyboardWillShowNotification(_:)))
    }

    public func addKeyboardDidShowNotification() {
        self.addNotificationObserver(name: NSNotification.Name.UIKeyboardDidShow.rawValue, selector: #selector(UIViewController.keyboardDidShowNotification(_:)))
    }

    public func addKeyboardWillHideNotification() {
        self.addNotificationObserver(name: NSNotification.Name.UIKeyboardWillHide.rawValue, selector: #selector(UIViewController.keyboardWillHideNotification(_:)))
    }

    public func addKeyboardDidHideNotification() {
        self.addNotificationObserver(name: NSNotification.Name.UIKeyboardDidHide.rawValue, selector: #selector(UIViewController.keyboardDidHideNotification(_:)))
    }

    public func removeKeyboardWillShowNotification() {
        self.removeNotificationObserver(name: NSNotification.Name.UIKeyboardWillShow.rawValue)
    }

    public func removeKeyboardDidShowNotification() {
        self.removeNotificationObserver(name: NSNotification.Name.UIKeyboardDidShow.rawValue)
    }

    public func removeKeyboardWillHideNotification() {
        self.removeNotificationObserver(name: NSNotification.Name.UIKeyboardWillHide.rawValue)
    }

    public func removeKeyboardDidHideNotification() {
        self.removeNotificationObserver(name: NSNotification.Name.UIKeyboardDidHide.rawValue)
    }

    public func keyboardDidShowNotification(_ notification: Notification) {
        if let nInfo = notification.userInfo, let value = nInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {

            let frame = value.cgRectValue
            keyboardDidShowWithFrame(frame)
        }
    }

    public func keyboardWillShowNotification(_ notification: Notification) {
        if let nInfo = notification.userInfo, let value = nInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {

            let frame = value.cgRectValue
            keyboardWillShowWithFrame(frame)
        }
    }

    public func keyboardWillHideNotification(_ notification: Notification) {
        if let nInfo = notification.userInfo, let value = nInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {

            let frame = value.cgRectValue
            keyboardWillHideWithFrame(frame)
        }
    }

    public func keyboardDidHideNotification(_ notification: Notification) {
        if let nInfo = notification.userInfo, let value = nInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {

            let frame = value.cgRectValue
            keyboardDidHideWithFrame(frame)
        }
    }

    public func keyboardWillShowWithFrame(_ frame: CGRect) {

    }

    public func keyboardDidShowWithFrame(_ frame: CGRect) {

    }

    public func keyboardWillHideWithFrame(_ frame: CGRect) {

    }

    public func keyboardDidHideWithFrame(_ frame: CGRect) {

    }

    //EZSE: Makes the UIViewController register tap events and hides keyboard when clicked somewhere in the ViewController.
    public func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    #endif

    public func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - VC Container

    /// EZSwiftExtensions
    public var top: CGFloat {
        get {
            if let me = self as? UINavigationController, let visibleViewController = me.visibleViewController {
                return visibleViewController.top
            }
            if let nav = self.navigationController {
                if nav.isNavigationBarHidden {
                    return view.top
                } else {
                    return nav.navigationBar.bottom
                }
            } else {
                return view.top
            }
        }
    }

    /// EZSwiftExtensions
    public var bottom: CGFloat {
        get {
            if let me = self as? UINavigationController, let visibleViewController = me.visibleViewController {
                return visibleViewController.bottom
            }
            if let tab = tabBarController {
                if tab.tabBar.isHidden {
                    return view.bottom
                } else {
                    return tab.tabBar.top
                }
            } else {
                return view.bottom
            }
        }
    }

    /// EZSwiftExtensions
    public var tabBarHeight: CGFloat {
        get {
            if let me = self as? UINavigationController, let visibleViewController = me.visibleViewController {
                return visibleViewController.tabBarHeight
            }
            if let tab = self.tabBarController {
                return tab.tabBar.frame.size.height
            }
            return 0
        }
    }

    /// EZSwiftExtensions
    public var navigationBarHeight: CGFloat {
        get {
            if let me = self as? UINavigationController, let visibleViewController = me.visibleViewController {
                return visibleViewController.navigationBarHeight
            }
            if let nav = self.navigationController {
                return nav.navigationBar.h
            }
            return 0
        }
    }

    /// EZSwiftExtensions
    public var navigationBarColor: UIColor? {
        get {
            if let me = self as? UINavigationController, let visibleViewController = me.visibleViewController {
                return visibleViewController.navigationBarColor
            }
            return navigationController?.navigationBar.tintColor
        } set(value) {
            navigationController?.navigationBar.barTintColor = value
        }
    }

    /// EZSwiftExtensions
    public var navBar: UINavigationBar? {
        get {
            return navigationController?.navigationBar
        }
    }

    /// EZSwiftExtensions
    public var applicationFrame: CGRect {
        get {
            return CGRect(x: view.x, y: top, width: view.w, height: bottom - top)
        }
    }

    // MARK: - VC Flow

    /// EZSwiftExtensions
    public func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }

    /// EZSwiftExtensions
    public func popVC() {
        navigationController?.popViewController(animated: true)
    }

    /// EZSwiftExtensions
    public func presentVC(_ vc: UIViewController) {
        present(vc, animated: true, completion: nil)
    }

    /// EZSwiftExtensions
    public func dismissVC(completion: (() -> Void)? ) {
        dismiss(animated: true, completion: completion)
    }

    /// EZSwiftExtensions
    public func addAsChildViewController(_ vc: UIViewController, toView: UIView) {
        toView.addSubview(vc.view)
        self.addChildViewController(vc)
        vc.didMove(toParentViewController: self)
    }

    ///EZSE: Adds image named: as a UIImageView in the Background
    func setBackgroundImage(_ named: String) {
        let image = UIImage(named: named)
        let imageView = UIImageView(frame: view.frame)
        imageView.image = image
        view.addSubview(imageView)
        view.sendSubview(toBack: imageView)
    }

    ///EZSE: Adds UIImage as a UIImageView in the Background
    @nonobjc func setBackgroundImage(_ image: UIImage) {
        let imageView = UIImageView(frame: view.frame)
        imageView.image = image
        view.addSubview(imageView)
        view.sendSubview(toBack: imageView)
    }
    
    
    func customLizeNavigationBarBackBtn() -> Void {
        var backButton:UIButton!
        backButton = UIButton.init(type: UIButtonType.custom)
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 50.0, height: 44.0)
        backButton.imageView?.contentMode = UIViewContentMode.center
        backButton.setImage(UIImage(named: "nav_back"), for: UIControlState())
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        backButton.addTarget(self, action: #selector(backAction), for: UIControlEvents.touchUpInside)
        let backBarBtnItem:UIBarButtonItem = UIBarButtonItem.init(customView: backButton)
        backBarBtnItem.style = UIBarButtonItemStyle.plain
        setLeftBarButtonItem(backBarBtnItem)
        
    }
    
    func setLeftBarButtonItem(_ barButtonItem:UIBarButtonItem) -> Void {
        let negativeSpace:UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        
        if UIDevice.isHigherIOS7() {
            negativeSpace.width = 0
        }else{
            
            negativeSpace.width = 5
        }
        
        self.navigationItem.leftBarButtonItems = [negativeSpace, barButtonItem]
        
    }
    
    func backAction() -> Void {
        popVC()
    }
    
    /**隐藏导航条下面的一条黑线*/
    func hiddenNavBottomLine() -> Void {
        let navBottomLine = getLineViewInNavigationBar((navigationController?.navigationBar)!)
        navBottomLine?.isHidden = true
    }
    
    /**显示导航条下面的一条黑线*/
    func showNavBottomLine() -> Void {
        let navBottomLine = getLineViewInNavigationBar((navigationController?.navigationBar)!)
        navBottomLine?.isHidden = false
    }
    
    /**找到导航栏下面的黑线*/
    func getLineViewInNavigationBar(_ view:UIView) -> UIImageView? {
        if view.isKind(of: UIImageView.self) && view.bounds.size.height <= 1.0 {
            return view as? UIImageView
        }
        
        for subView in view.subviews {
            let imageView = getLineViewInNavigationBar(subView)
            if (imageView != nil) {
                return imageView
            }
            
        }
        
        return nil
    }
    
}
