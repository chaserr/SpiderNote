//
//  ModifyPasswordVC.swift
//  Spider
//
//  Created by 童星 on 16/7/17.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class ModifyPasswordVC: UIViewController {

    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customLizeNavigationBarBackBtn()
        navigationItem.title = "修改密码"
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissKeyboard()
    }

    @IBAction func hiddenPwdAction(sender: UIButton) {
        sender.selected = !sender.selected
        let newPasswordTFRect:CGRect = newPasswordTF.convertRect(newPasswordTF.bounds, toView: view)
//        let confirmPasswordTFRect:CGRect = confirmPasswordTF.convertRect(confirmPasswordTF.bounds, toView: view)
        let rect:CGRect = sender.convertRect(sender.bounds, toView: view)
        if rect.y == newPasswordTFRect.y {
            newPasswordTF.secureTextEntry = !sender.selected

        }else{
        
            confirmPasswordTF.secureTextEntry = !sender.selected

        }
    }
    @IBAction func modifyPwdBtn(sender: UIButton) {
        alert("", message: "修改成功，跳回登录界面", parentVC: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
