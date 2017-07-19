//
//  LoginVC.swift
//  Spider
//
//  Created by 童星 on 16/7/15.
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


class LoginVC: UIViewController {

    
    @IBOutlet weak var userPortrial: UIImageView!
    @IBOutlet weak var userNickname: UILabel!
    @IBOutlet weak var userPasswordTF: UITextField!
    @IBOutlet weak var hiddenPwdBtn: UIButton!
    @IBOutlet weak var otherPlantformLogin: UIButton!
    @IBOutlet weak var forgetPwdBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    var isNavTopViewController: Bool!
    var comeFormLeftMenu: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "登录"
        if comeFormLeftMenu {
            
            customLizeNavigationBarBackBtn()
        }
    }
    
    // MARK:控制器生命周期
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var oldAccount: String?
        
        if Defaults.hasKey(OldAccount) {
            oldAccount = Defaults[OldAccount].stringValue
        }
        userNickname.text = oldAccount
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func hiddenPwdAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        userPasswordTF.isSecureTextEntry = !sender.isSelected
        let passwordTxt = userPasswordTF.text
        userPasswordTF.text = ""
        userPasswordTF.text = passwordTxt
    }
    
    @IBAction func selectOtherPlantform(_ sender: UIButton) {

    }
    @IBAction func forgetPwdAction(_ sender: UIButton) {
    }
    @IBAction func loginAction(_ sender: UIButton) {
        
        if !CommonUtils.isValidateEMail(userNickname.text!){
            AOHUDVIEW.showTips("邮箱格式不正确")
        }else if userPasswordTF.text?.length <= 5  {
            
            AOHUDVIEW.showTips("密码不能低于6位")
            
        }else{
        
            dismissKeyboard()
            LOGINMANAGER.startLogin(userNickname.text!, password: userPasswordTF.text!, manualLogin: true)

        }
    }
    

    override func backAction() {
        let vc = (navigationController!.viewControllers[0])
        
        if self.isKind(of: type(of: vc)) {
            dismissVC(completion: nil)
        }else{
        
            popVC()
        }
    }

    func hiddenKeyBoard(){
        userPasswordTF.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hiddenKeyBoard()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goOtherAccountLoginVC"{
            let otherAccountLoginVC = segue.destination as! OtherAccountLoginVC
            otherAccountLoginVC.comeFormLeftMenu = true
        }
        
        
    }
    

}
