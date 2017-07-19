//
//  LeftMenuViewController.swift
//  Spider
//
//  Created by 童星 on 16/7/11.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class LeftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    enum Menu:Int {
        case main = 0
        case setting
        case feedback
    }
    
    var loginState:Bool = false // 测试

    var menus = ["设置", "用户反馈"]
    var mainViewController:ProjectCollectionViewController!
    var headImageView:UIImageView!
    var headerSeperatorLine:UIImageView!
    var footerSeperatorLine:UIImageView!
    var nicknameLable:UILabel!
    var footerView:UIView!
    var footerLabel:UILabel!
    var footerButton:UIImageView!
    var tableView:UITableView!
    var lock: Bool = false
    var canOperationUpload: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        // 添加子视图
        addSubView()
        // 添加约束
        addViewConstranit()
        
        addNotificationObserver(kNotificationLoginSuccessed, selector: #selector(updateInfo))
        addNotificationObserver(kSyncSuccessNotification, selector: #selector(updateSyncTime))

    }
    
    deinit{
    
        removeNotificationObserver(kNotificationLoginSuccessed)
    }
    


    func addSubView() -> Void {
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        view.addSubview(tableView)
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.w, height: 26))
        headerView.backgroundColor = UIColor.white
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.contentInset.top = 0
        
        
        // HeadView
        let headH:CGFloat = 50
        headImageView = UIImageView.init(image: UIImage(named: "default_protrial"))
        //        headImageView.frame = CGRectMake(headX, headY, headH, headH)
        headImageView.clipsToBounds = true
        headImageView.isUserInteractionEnabled = true
        headImageView.layer.cornerRadius = headH/2
        headImageView.autoresizingMask = .flexibleTopMargin
        view.addSubview(headImageView)
        headImageView.addTapGesture { [unowned self] (tapGesture) in
            
            //TODO: 判断用户是否登录了，没有登录跳转到登陆界面
            if APP_UTILITY.checkCurrentUser() {
            
                let userSpace = UserSpaceViewController()
                let nav:BaseNavViewController = BaseNavViewController.init(rootViewController: userSpace)
                APP_NAVIGATOR.mainNav = nav
                self.slideMenuController()?.changeMainViewController(nav, close: true)
                
                
            }else{
                
                if Defaults.hasKey(OldAccount) {
                    let loginVC = getViewControllerFromStoryBoard("RegisterLogin", viewControllerIdentify: "LoginVC") as! LoginVC
                    loginVC.comeFormLeftMenu = true
                    let nav:BaseNavViewController = BaseNavViewController(rootViewController: loginVC)
                    AppNavigator.presentViewController(nav, animation: true, completion: nil)
                    
                }else{
                    let otherAccountLoginVC = getViewControllerFromStoryBoard("RegisterLogin", viewControllerIdentify: "OtherAccountLoginVC") as! OtherAccountLoginVC
                    let nav:BaseNavViewController = BaseNavViewController(rootViewController: otherAccountLoginVC)
                    otherAccountLoginVC.comeFormLeftMenu = true
                    AppNavigator.presentViewController(nav, animation: true, completion: nil)
                    
                }
                
            }
            
 
        }
    
        
        
        // 用户昵称
        nicknameLable = UILabel()
        nicknameLable.textColor = RGBCOLORV(0x555555)
        nicknameLable.textAlignment = NSTextAlignment.center
        nicknameLable.font = UIFont.systemFont(ofSize: 14)
        nicknameLable.autoresizingMask = .flexibleTopMargin
        view.addSubview(nicknameLable)
        
        // 头部分割线
        headerSeperatorLine = UIImageView.init()
        headerSeperatorLine.backgroundColor = RGBACOLOR(173, g: 173, b: 173, a: 0.8)
        view.addSubview(headerSeperatorLine)
        
        // 尾部分割线
        footerSeperatorLine = UIImageView.init()
        footerSeperatorLine.backgroundColor = RGBACOLOR(173, g: 173, b: 173, a: 0.8)
        view.addSubview(footerSeperatorLine)
        
        // 尾部视图
        footerView = UIView()
        footerLabel = UILabel()
        footerLabel.font = SYSTEMFONT(14)
        footerButton = UIImageView()
        footerButton.image = UIImage(named: "lastTime_synch")
        footerButton.animationDuration = 1
        footerButton.isUserInteractionEnabled = true
        footerButton.contentMode = UIViewContentMode.center
        footerButton.addTapGesture { [weak self] (UITapGestureRecognizer) in
            
            if APP_UTILITY.checkCurrentUser() {
            
                // 异步线程同步
                self!.startSync()
                self!.footerButton.isUserInteractionEnabled = false
                var paraDic = [String: AnyObject]()
                let dic: Dictionary = SYNCPROMANAGER.getFirstRequestParam()
                paraDic["projectInfo"] = dic.dicToJSON(dic)
                SYNCPROMANAGER.syncProject(paraDic, success: { (uploadProObjID) in
                    // 执行上传操作
                    self!.uploadOperation(uploadProObjID)
                    }, failure: {
                        self!.endSync()
                        alert("同步失败", message: nil, parentVC: self!)
                })
            }else{
            
                let alert = CustomSystemAlertView.init(title: "提示", message: "请先登录后再进行同步", cancelButtonTitle: "确定", sureButtonTitle: nil)
                alert.show()
            }

        }
        footerView.addSubview(footerLabel)
        footerView.addSubview(footerButton)
        view.addSubview(footerView)
        
        if APP_UTILITY.checkCurrentUser() {
            footerLabel.text = APP_USER.lastSyncTime
            nicknameLable.text = APP_UTILITY.currentUser?.account
        }else{
            
            footerLabel.text = "请先登录后进行同步"
            nicknameLable.text = "游客状态"
        }
    }
    
    
    func uploadOperation(_ uploadProObjID: [String]) -> Void {
        var paraDic = [String: AnyObject]()
        let dic: Dictionary = UPLOADPROMANAGER.getSecondRequestParam(uploadProObjID)
        paraDic["projectInfo"] = dic.dicToJSON(dic)
//        AODlog((paraDic as NSDictionary).description)
        UPLOADPROMANAGER.uploadProject(paraDic, success: { [weak self] in
            self!.endSync()
            alert("上传成功", message: nil, parentVC: self!)
            
            }, failure: {
                self.endSync()
                alert("上传失败", message: nil, parentVC: self)
        })
    }
    
    
    func startSync() -> Void {
    
        if !lock {
            let animation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
            animation.byValue = (M_PI*2)
            animation.duration = 1.0
            animation.repeatCount = Float.infinity
            animation.isCumulative = true
            animation.isRemovedOnCompletion = false
            self.footerButton.layer.add(animation, forKey: "rotation")
            lock = true
        }
    }
    
    func endSync() -> Void {
        lock = false
        footerButton.isUserInteractionEnabled = true
        self.footerButton.layer.removeAnimation(forKey: "rotation")
    }
    
    func addViewConstranit() -> Void {
        
        headImageView.snp_makeConstraints { (make) in
            make.width.height.equalTo(100)
            make.centerX.equalToSuperview()
            make.topMargin.equalTo(50)
        }
        
        nicknameLable.snp_makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(20)
            make.topMargin.equalTo(headImageView.snp_bottom).offset(20)
            make.centerX.equalTo(headImageView)
        }
        
        headerSeperatorLine.snp_makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.topMargin.equalTo(nicknameLable.snp_bottom).offset(44)
            //            make.width.equalTo(100)
            make.height.equalTo(1)
            make.centerX.equalTo(nicknameLable)
            
        }
        
        tableView.snp_makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.topMargin.equalTo(headerSeperatorLine.snp_bottom).offset(10)
            make.bottom.equalTo(footerSeperatorLine.snp_top).offset(10)
        }
        
        footerSeperatorLine.snp_makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottomMargin.equalToSuperview().offset(-55)
            //            make.width.equalTo(100)
            make.height.equalTo(1)
            make.centerX.equalTo(nicknameLable)
            
        }
        
        footerView.snp_makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(55)

        }
        
        footerLabel.snp_makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(footerButton.snp_leading).offset(-30)
        }
        
        footerButton.snp_makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
        }
    }
    
    func updateInfo(_ notification:Notification) -> Void {
        
        AODlog(notification.userInfo)
        let name = notification.userInfo!["username"] as! String
        nicknameLable.text = name
        
    }
    
    func updateSyncTime() -> Void {
        footerLabel.text = APP_USER.lastSyncTime
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension LeftMenuViewController{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        
        if cell == nil {
            
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
            cell?.textLabel?.textColor = RGBCOLORV(0x555555)
            cell?.textLabel?.font = SYSTEMFONT(14)
        }
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = "设置"
            cell?.imageView?.image = UIImage.init(named: "leftMenu_setting")
        case 1:
            cell?.textLabel?.text = "用户反馈"
            cell?.imageView?.image = UIImage.init(named: "leftMenu_userFaceback")

        default:
            break
        }
    
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.row) {
//        case 0:
//            let settingVC = ProjectCollectionViewController()
//            let nav:BaseNavViewController = BaseNavViewController.init(rootViewController: settingVC)
//            APP_NAVIGATOR.mainNav = nav
//
//            slideMenuController()?.changeMainViewController(nav, close: true)
            
        case 0:
            
            let settingVC = LeftMenuSettingVC()
            let nav:BaseNavViewController = BaseNavViewController.init(rootViewController: settingVC)
            APP_NAVIGATOR.mainNav = nav
            slideMenuController()?.changeMainViewController(nav, close: true)
            
        case 1:
            let userFaceBack = BaseWebView()
            let nav:BaseNavViewController = BaseNavViewController.init(rootViewController: userFaceBack)
            APP_NAVIGATOR.mainNav = nav
            userFaceBack.loadPage("http://csol2.tiancity.com/homepage/article/Class_1166_Time_1.html", navTitle: "百度首页")
            slideMenuController()?.changeMainViewController(nav, close: true)
            
        default: break
            
        }
    }
    
}
