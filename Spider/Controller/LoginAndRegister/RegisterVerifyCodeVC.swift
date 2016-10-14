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
    var timer:NSTimer!
    var isFindPassword: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navTitle ?? "注册"
        customLizeNavigationBarBackBtn()
        if isFindPassword == true {
            registerBtn.setTitle("提交", forState: UIControlState.Normal)
        }
        
        VertifyCodeBtn.adjustsImageWhenHighlighted = false
        

    }
    
    // MARK:控制器生命周期
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissKeyboard()
    }
    
    func getUserInfo(nameBlock:UserNameBlock){
        userNameBlock = nameBlock
    }
    
    func getVertifyCode() -> Void {
        
        secondCount = 60
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, block: {
                [weak self] in
                if let strongSelf = self {
                    strongSelf.VertifyCodeBtn.setBackgroundColor(RGBCOLORV(0xcdcdcd), forState: UIControlState.Normal)
                    strongSelf.VertifyCodeBtn.userInteractionEnabled = false
                    strongSelf.secondCount = strongSelf.secondCount - 1
                    strongSelf.VertifyCodeBtn.setTitle("重新获取(\(strongSelf.secondCount))", forState: UIControlState.Normal)
                    
                    if strongSelf.secondCount == 0 {
                        strongSelf.timer.invalidate()
                        strongSelf.VertifyCodeBtn.setTitle("重新获取", forState: UIControlState.Normal)
                        strongSelf.VertifyCodeBtn.setBackgroundColor(RGBCOLORV(0x79c542), forState: UIControlState.Normal)
                        strongSelf.VertifyCodeBtn.userInteractionEnabled = true
                        
                    }
                }
            }, repeats: true) as! NSTimer
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: UITrackingRunLoopMode)
    }
    
    @IBAction func getVertifyCodeAgain(sender: AnyObject, forEvent event: UIEvent) {
        getVertifyCode()
        
    }
    
    @IBAction func registerAction(sender: UIButton, forEvent event: UIEvent) {
        
        if isFindPassword {
            
            
        }else{
        
            let account = accountDic["account"]
            
            LOGINMANAGER.sendVertifyEmail(account!, smsCode: vertifyCodeTF.text!, success: { 
                
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationLoginSuccessed, object: nil, userInfo: ["username":account!])
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
