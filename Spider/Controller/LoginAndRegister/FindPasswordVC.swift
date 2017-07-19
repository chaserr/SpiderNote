//
//  FindPasswordVC.swift
//  Spider
//
//  Created by 童星 on 16/7/17.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class FindPasswordVC: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "找回密码"
        
        customLizeNavigationBarBackBtn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "findPasswordVerifyCode" {
            // 从找回密码进入
            let vc: RegisterVerifyCodeVC = segue.destination as! RegisterVerifyCodeVC
            vc.navTitle = "找回密码"
            vc.isFindPassword = true
            vc.accountDic = ["account": (APP_UTILITY.currentUser?.account)!, "password": (APP_UTILITY.currentUser?.password)!]
            vc.getVertifyCode()
            
        }
    }
 

}
