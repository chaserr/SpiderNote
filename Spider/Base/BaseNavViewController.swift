//
//  BaseNavViewController.swift
//  Spider
//
//  Created by 童星 on 16/7/4.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class BaseNavViewController: UINavigationController, UINavigationControllerDelegate {

    var distrube:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        UINavigationBar.appearance().translucent = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func pushViewController(viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)

    }
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        
        if ((navigationController?.topViewController?.isKindOfClass(MindViewController.self)) != nil) {
            SPIDERSTRUCT.currentLevel -= 1
        }else if ((navigationController?.topViewController?.isKindOfClass(ProjectCollectionViewController.self)) != nil) {
        
            SPIDERSTRUCT.currentLevel == 0
            
        }
        
        
        
//                for item in viewControllers {
//                    if item.dynamicType == ProjectCollectionViewController.self {
////                        // 如果搜索控制器在数组的top-3位置，说明进行了两次push操作，所以移除搜索控制器，
////                        if viewControllers.indexOf(item) == viewControllers.count - 1 - 2 {
////                            alert("要销毁搜索控制器了哦", message: "", parentVC: self)
////                            viewControllers.removeObject(item)
////        
////                        }
//                      AODlog(item)  
//                    }
//                    
//                }
        
        
        return super.popViewControllerAnimated(animated)
        
    }
}

extension BaseNavViewController {
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
    }
}
