//
//  RegisterVerifyCodeVC.swift
//  Spider
//
//  Created by 童星 on 16/7/15.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

typealias UserNameBlock = (String) -> Void

class RegisterVerifyCodeVC: UIViewController {

    
    @IBOutlet weak var vertifyCodeTF: UITextField!
    @IBOutlet weak var VertifyCodeBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    var userNameBlock:UserNameBlock?
    
    var navTitle: String?
    var registerBtnTitle: String?
    var accountDic = [String: String]()
    
    
    var secondCount:Int!
    var timer:Timer!
    var isFindPassword: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navTitle ?? "注册"
        customLizeNavigationBarBackBtn()
        if isFindPassword == true {
            registerBtn.setTitle("提交", for: UIControlState())
        }
        
        VertifyCodeBtn.adjustsImageWhenHighlighted = false
        

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
    func getUserInfo(_ nameBlock:UserNameBlock){
        userNameBlock = nameBlock
    }
    
    func getVertifyCode() -> Void {
        
        secondCount = 60
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, block: {
                [weak self] in
                if let strongSelf = self {
                    strongSelf.VertifyCodeBtn.setBackgroundColor(RGBCOLORV(0xcdcdcd), forState: UIControlState())
                    strongSelf.VertifyCodeBtn.isUserInteractionEnabled = false
                    strongSelf.secondCount = strongSelf.secondCount - 1
                    strongSelf.VertifyCodeBtn.setTitle("重新获取(\(strongSelf.secondCount))", for: UIControlState())
                    
                    if strongSelf.secondCount == 0 {
                        strongSelf.timer.invalidate()
                        strongSelf.VertifyCodeBtn.setTitle("重新获取", for: UIControlState())
                        strongSelf.VertifyCodeBtn.setBackgroundColor(RGBCOLORV(0x79c542), forState: UIControlState())
                        strongSelf.VertifyCodeBtn.isUserInteractionEnabled = true
                        
                    }
                }
            }, repeats: true) as! Timer
        RunLoop.current.add(timer, forMode: RunLoopMode.UITrackingRunLoopMode)
    }
    
    @IBAction func getVertifyCodeAgain(_ sender: AnyObject, forEvent event: UIEvent) {
        getVertifyCode()
        
    }
    
    @IBAction func registerAction(_ sender: UIButton, forEvent event: UIEvent) {
        
        if isFindPassword {
            
            
        }else{
        
            let account = accountDic["account"]
            
            LOGINMANAGER.sendVertifyEmail(account!, smsCode: vertifyCodeTF.text!, success: { 
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationLoginSuccessed), object: nil, userInfo: ["username":account!])
                AppNavigator.openMainViewController()
                
                }, failure: { 
                    AOHUDVIEW.showTips("注册失败")
            })
        }

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
