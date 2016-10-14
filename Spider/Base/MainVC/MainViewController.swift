//
//  MainViewController.swift
//  News
//
//  Created by 童星 on 16/7/10.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  UIViewController的基类，用于集成一些公用的功能

import Foundation

import UIKit

class MainViewController: UIViewController {
    
    var navigationTitleLabel:UILabel!
    var backButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleLabel = UILabel.init(frame: CGRectMake(0, 0, 176, 46))
        navigationTitleLabel.textAlignment = NSTextAlignment.Center
        navigationTitleLabel.font = UIFont.systemFontOfSize(18)
        navigationTitleLabel.backgroundColor = UIColor.clearColor()
        navigationTitleLabel.textColor = RGBCOLORV(0x282828)
        navigationTitleLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        self.navigationItem.titleView = navigationTitleLabel
        
//        if ((navigationController?.navigationBar.respondsToSelector(Selector("interactivePopGestureRecognizer"))) != nil) {
//            self.navigationController!.interactivePopGestureRecognizer!.delegate = nil;
//        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.contentSizeDidChangeNotification(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    @objc private func contentSizeDidChangeNotification(notification: NSNotification) {
        if let userInfo: NSDictionary = notification.userInfo {
            self.contentSizeDidChange(userInfo[UIContentSizeCategoryNewValueKey] as! String)
        }
    }
    
    func contentSizeDidChange(size: String) {
        // Implement in subclass
    }
    
    init(){
    
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK:控制器生命周期
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    


}


// 自定义导航栏返回按钮和标题
extension MainViewController{

    
    override func setLeftBarButtonItem(barButtonItem:UIBarButtonItem) -> Void {
        let negativeSpace:UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        
        if UIDevice.isHigherIOS7() {
            negativeSpace.width = 0
        }else{
        
            negativeSpace.width = 5
        }
        
        self.navigationItem.leftBarButtonItems = [negativeSpace, barButtonItem]
        
    }
    
    func setRightBarButtonItem(barButtonItem:UIBarButtonItem) -> Void {
        let negativeSpace:UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        
        if UIDevice.isHigherIOS7() {
            negativeSpace.width = 0
        }else{
            
            negativeSpace.width = 5
        }
        
        self.navigationItem.rightBarButtonItems = [negativeSpace, barButtonItem]
        
    }
    
    // 自定义返回按钮
    override func customLizeNavigationBarBackBtn() -> Void {
        backButton = UIButton.init(type: UIButtonType.Custom)
        backButton.frame = CGRectMake(0.0, 0.0, 30.0, 44.0)
        backButton.imageView?.contentMode = UIViewContentMode.Center
        backButton.setImage(UIImage(named: "nav_back"), forState: UIControlState.Normal)
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
//        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        backButton.addTarget(self, action: #selector(backAction), forControlEvents: UIControlEvents.TouchUpInside)
        let backBarBtnItem:UIBarButtonItem = UIBarButtonItem.init(customView: backButton)
        backBarBtnItem.style = UIBarButtonItemStyle.Plain
        setLeftBarButtonItem(backBarBtnItem)
        
    }
    
    override func backAction() -> Void {
        AppNavigator.popViewControllerAnimated(true)
    }
}
