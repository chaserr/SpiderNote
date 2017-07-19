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
        navigationTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 176, height: 46))
        navigationTitleLabel.textAlignment = NSTextAlignment.center
        navigationTitleLabel.font = UIFont.systemFont(ofSize: 18)
        navigationTitleLabel.backgroundColor = UIColor.clear
        navigationTitleLabel.textColor = RGBCOLORV(0x282828)
        navigationTitleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.navigationItem.titleView = navigationTitleLabel
        
//        if ((navigationController?.navigationBar.respondsToSelector(Selector("interactivePopGestureRecognizer"))) != nil) {
//            self.navigationController!.interactivePopGestureRecognizer!.delegate = nil;
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.contentSizeDidChangeNotification(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    @objc fileprivate func contentSizeDidChangeNotification(_ notification: Notification) {
        if let userInfo: NSDictionary = notification.userInfo {
            self.contentSizeDidChange(userInfo[UIContentSizeCategoryNewValueKey] as! String)
        }
    }
    
    func contentSizeDidChange(_ size: String) {
        // Implement in subclass
    }
    
    init(){
    
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK:控制器生命周期
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    


}


// 自定义导航栏返回按钮和标题
extension MainViewController{

    
    override func setLeftBarButtonItem(_ barButtonItem:UIBarButtonItem) -> Void {
        let negativeSpace:UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        
        if UIDevice.isHigherIOS7() {
            negativeSpace.width = 0
        }else{
        
            negativeSpace.width = 5
        }
        
        self.navigationItem.leftBarButtonItems = [negativeSpace, barButtonItem]
        
    }
    
    func setRightBarButtonItem(_ barButtonItem:UIBarButtonItem) -> Void {
        let negativeSpace:UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        
        if UIDevice.isHigherIOS7() {
            negativeSpace.width = 0
        }else{
            
            negativeSpace.width = 5
        }
        
        self.navigationItem.rightBarButtonItems = [negativeSpace, barButtonItem]
        
    }
    
    // 自定义返回按钮
    override func customLizeNavigationBarBackBtn() -> Void {
        backButton = UIButton.init(type: UIButtonType.custom)
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 44.0)
        backButton.imageView?.contentMode = UIViewContentMode.center
        backButton.setImage(UIImage(named: "nav_back"), for: UIControlState())
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
//        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        backButton.addTarget(self, action: #selector(backAction), for: UIControlEvents.touchUpInside)
        let backBarBtnItem:UIBarButtonItem = UIBarButtonItem.init(customView: backButton)
        backBarBtnItem.style = UIBarButtonItemStyle.plain
        setLeftBarButtonItem(backBarBtnItem)
        
    }
    
    override func backAction() -> Void {
        AppNavigator.popViewControllerAnimated(true)
    }
}
