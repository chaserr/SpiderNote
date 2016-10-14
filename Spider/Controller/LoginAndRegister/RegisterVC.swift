//
//  RegisterVCViewController.swift
//  Spider
//
//  Created by 童星 on 16/7/14.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var visitorLoginBtn: UIButton!
    @IBOutlet weak var sendActiveBtn: UIButton!
    @IBOutlet weak var hiddenPasswordBtn: UIButton!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var accountTF: UITextField!
    var comeFormLeftMenu: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if comeFormLeftMenu {
            
            visitorLoginBtn.hidden = true
            customLizeNavigationBarBackBtn()
        }
        
        navigationItem.title = "注册"
        hiddenPasswordBtn.selected = false
        
        visitorLoginBtn.addTarget(self, action: #selector(visitorLogin), forControlEvents: UIControlEvents.TouchUpInside)
        
        
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissKeyboard()
    }
    
    
    override func backAction() {
        let vc = (navigationController!.viewControllers[0])
        
        if self.isKindOfClass(vc.dynamicType) {
            dismissVC(completion: nil)
        }else{
            
            popVC()
        }
    }
    
    func visitorLogin(sender: UIButton) -> Void {
        
        LOGINMANAGER.visitorLogin { 
            let mainViewController = ProjectCollectionViewController()
            AppNavigator.openMainNavControllerWithRoot(mainViewController, animated: true)
        }
        
    }
    
    @IBAction func hiddenPassword(sender: UIButton) {
        
        sender.selected = !sender.selected
        passwordTF.secureTextEntry = !sender.selected
        let passwordTxt = passwordTF.text
        passwordTF.text = ""
        passwordTF.text = passwordTxt
    }
    
    @IBAction func sendActiveEmail(sender: AnyObject) {
        
        if !CommonUtils.isValidateEMail(accountTF.text!){
            AOHUDVIEW.showTips("邮箱格式不正确")
        }
        else if passwordTF.text?.length <= 5  {
            
            AOHUDVIEW.showTips("密码不能低于6位")
            
        }else {
            
            LOGINMANAGER.startRegister(accountTF.text!, password: passwordTF.text!, success: {[weak self] in
                
                self!.performSegueWithIdentifier("getRegisterVertifyCode", sender: sender)
                
                }, failure: {
                    AOHUDVIEW.showTips("发送验证码失败,请检查网络后再试")
            })
            
        }
        
    }
    
    @IBAction func loginAction(sender: UIButton?) {
        
        if comeFormLeftMenu {
            popVC()
        }else if Defaults.hasKey(OldAccount) {
            let loginVC = getViewControllerFromStoryBoard("RegisterLogin", viewControllerIdentify: "LoginVC")
            AppNavigator.openRegisterOrLoginViewControllerWithRoot(loginVC, animated: true)
        }else{
        
            let otherAccountLoginVC = getViewControllerFromStoryBoard("RegisterLogin", viewControllerIdentify: "OtherAccountLoginVC")
            AppNavigator.openRegisterOrLoginViewControllerWithRoot(otherAccountLoginVC, animated: true)
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier! == "getRegisterVertifyCode" {

            let regiVertifyVC:RegisterVerifyCodeVC = segue.destinationViewController as! RegisterVerifyCodeVC
            regiVertifyVC.accountDic = ["account": self.accountTF.text!, "password": self.passwordTF.text!]
            regiVertifyVC.getVertifyCode()
        }
        
    }
    

}
