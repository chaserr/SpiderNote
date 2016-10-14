//
//  SearchResultVC.swift
//  Spider
//
//  Created by 童星 on 16/7/18.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class SearchResultVC: MainViewController {

    var buttonTitle:String? = ""
    
    var searchResult:UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customLizeNavigationBarBackBtn()
        view.backgroundColor = UIColor.redColor()
        
        searchResult = UIButton.init(type: UIButtonType.System)
        searchResult.frame = CGRectMake(0, 100, 200, 200)
        searchResult.setTitle(buttonTitle, forState: UIControlState.Normal)
        view.addSubview(searchResult)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
