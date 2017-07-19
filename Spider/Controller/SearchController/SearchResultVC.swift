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
        view.backgroundColor = UIColor.red
        
        searchResult = UIButton.init(type: UIButtonType.system)
        searchResult.frame = CGRect(x: 0, y: 100, width: 200, height: 200)
        searchResult.setTitle(buttonTitle, for: UIControlState())
        view.addSubview(searchResult)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
