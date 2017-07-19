//
//  OtherAccountLoginVC.swift
//  Spider
//
//  Created by 童星 on 16/7/17.
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    

    @IBAction func goRegisterVC(_ sender: UIButton) {
        if comeFormLeftMenu {
            performSegue(withIdentifier: "goRegister", sender: sender)
        }else{
        
            let registerVC = getViewControllerFromStoryBoard("RegisterLogin", viewControllerIdentify: "RegisterVC") as! RegisterVC
            AppNavigator.openRegisterOrLoginViewControllerWithRoot(registerVC, animated: true)
        }
        
    }
    
    
    @IBAction func hiddenPwdAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTF.isSecureTextEntry = !sender.isSelected
    }
    @IBAction func loginAction(_ sender: UIButton) {
    
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
        
        if self.isKind(of: type(of: vc)) {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goRegister" {
            let registerVC = segue.destination as! RegisterVC
            registerVC.comeFormLeftMenu = true
        }
        
        
    }
    

}
