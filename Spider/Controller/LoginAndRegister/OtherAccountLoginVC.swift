//
//  OtherAccountLoginVC.swift
//  Spider
//
//  Created by 童星 on 16/7/17.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class OtherAccountLoginVC: UIViewController {

    @IBOutlet weak var accountTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    var comeFormLeftMenu: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "登录"

        if comeFormLeftMenu {
            
            customLizeNavigationBarBackBtn()
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissKeyboard()
    }
    

    @IBAction func goRegisterVC(sender: UIButton) {
        if comeFormLeftMenu {
            performSegueWithIdentifier("goRegister", sender: sender)
        }else{
        
            let registerVC = getViewControllerFromStoryBoard("RegisterLogin", viewControllerIdentify: "RegisterVC") as! RegisterVC
            AppNavigator.openRegisterOrLoginViewControllerWithRoot(registerVC, animated: true)
        }
        
    }
    
    
    @IBAction func hiddenPwdAction(sender: UIButton) {
        sender.selected = !sender.selected
        passwordTF.secureTextEntry = !sender.selected
    }
    @IBAction func loginAction(sender: UIButton) {
    
        if !CommonUtils.isValidateEMail(accountTF.text!){
            AOHUDVIEW.showTips("邮箱格式不正确")
        }else if passwordTF.text?.length <= 5  {
            
            AOHUDVIEW.showTips("密码不能低于6位")
            
        }else{
            dismissKeyboard()
            LOGINMANAGER.startLogin(accountTF.text!, password: passwordTF.text!, manualLogin: true)
            
        }
        
    }
    
    override func backAction() {
        let vc = (navigationController!.viewControllers[0])
        
        if self.isKindOfClass(vc.dynamicType) {
            dismissKeyboard()
            ez.runThisAfterDelay(seconds: 0.25) {
                self.dismissVC(completion: nil)
            }
        }else{
            
            popVC()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goRegister" {
            let registerVC = segue.destinationViewController as! RegisterVC
            registerVC.comeFormLeftMenu = true
        }
        
        
    }
    

}
