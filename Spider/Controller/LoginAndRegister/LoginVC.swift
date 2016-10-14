//
//  LoginVC.swift
//  Spider
//
//  Created by 童星 on 16/7/15.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var oldAccount: String?
        
        if Defaults.hasKey(OldAccount) {
            oldAccount = Defaults[OldAccount].stringValue
        }
        userNickname.text = oldAccount
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func hiddenPwdAction(sender: UIButton) {
        sender.selected = !sender.selected
        userPasswordTF.secureTextEntry = !sender.selected
        let passwordTxt = userPasswordTF.text
        userPasswordTF.text = ""
        userPasswordTF.text = passwordTxt
    }
    
    @IBAction func selectOtherPlantform(sender: UIButton) {

    }
    @IBAction func forgetPwdAction(sender: UIButton) {
    }
    @IBAction func loginAction(sender: UIButton) {
        
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
        
        if self.isKindOfClass(vc.dynamicType) {
            dismissVC(completion: nil)
        }else{
        
            popVC()
        }
    }

    func hiddenKeyBoard(){
        userPasswordTF.resignFirstResponder()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        hiddenKeyBoard()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goOtherAccountLoginVC"{
            let otherAccountLoginVC = segue.destinationViewController as! OtherAccountLoginVC
            otherAccountLoginVC.comeFormLeftMenu = true
        }
        
        
    }
    

}
