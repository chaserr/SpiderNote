//
//  RegisterVCViewController.swift
//  Spider
//
//  Created by 童星 on 16/7/14.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


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
            
            visitorLoginBtn.isHidden = true
            customLizeNavigationBarBackBtn()
        }
        
        navigationItem.title = "注册"
        hiddenPasswordBtn.isSelected = false
        
        visitorLoginBtn.addTarget(self, action: #selector(visitorLogin), for: UIControlEvents.touchUpInside)
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
    
    override func backAction() {
        let vc = (navigationController!.viewControllers[0])
        
        if self.isKind(of: type(of: vc)) {
            dismissVC(completion: nil)
        }else{
            
            popVC()
        }
    }
    
    func visitorLogin(_ sender: UIButton) -> Void {
        
        LOGINMANAGER.visitorLogin { 
            let mainViewController = ProjectCollectionViewController()
            AppNavigator.openMainNavControllerWithRoot(mainViewController, animated: true)
        }
        
    }
    
    @IBAction func hiddenPassword(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        passwordTF.isSecureTextEntry = !sender.isSelected
        let passwordTxt = passwordTF.text
        passwordTF.text = ""
        passwordTF.text = passwordTxt
    }
    
    @IBAction func sendActiveEmail(_ sender: AnyObject) {
        
        if !CommonUtils.isValidateEMail(accountTF.text!){
            AOHUDVIEW.showTips("邮箱格式不正确")
        }
        else if passwordTF.text?.length <= 5  {
            
            AOHUDVIEW.showTips("密码不能低于6位")
            
        }else {
            
            LOGINMANAGER.startRegister(accountTF.text!, password: passwordTF.text!, success: {[weak self] in
                
                self!.performSegue(withIdentifier: "getRegisterVertifyCode", sender: sender)
                
                }, failure: {
                    AOHUDVIEW.showTips("发送验证码失败,请检查网络后再试")
            })
            
        }
        
    }
    
    @IBAction func loginAction(_ sender: UIButton?) {
        
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier! == "getRegisterVertifyCode" {

            let regiVertifyVC:RegisterVerifyCodeVC = segue.destination as! RegisterVerifyCodeVC
            regiVertifyVC.accountDic = ["account": self.accountTF.text!, "password": self.passwordTF.text!]
            regiVertifyVC.getVertifyCode()
        }
        
    }
    

}
