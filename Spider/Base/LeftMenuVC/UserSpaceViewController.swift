//
//  UserSpaceViewController.swift
//  Spider
//
//  Created by 童星 on 16/7/13.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  用户个人中心

import UIKit

class UserSpaceViewController: BaseTableViewController, IBActionSheetDelegate, TZImagePickerControllerDelegate {

    
    var progressLayer:CALayer!
    
    lazy var cellTitle = {
        
        return [["头像", "昵称", "性别"],  ["修改密码"],["流量使用情况", "空间使用情况"]]
    }()
    
    lazy var actionSheet:IBActionSheet = {
    
        let actionS:IBActionSheet = IBActionSheet.init(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "直接退出", otherButtonTitles: ["退出并清除账号数据"])
        actionS.setFont(SYSTEMFONT(15))
        actionS.setTitleTextColor(UIColor.init(white: 0.574, alpha: 1))
        actionS.setButtonTextColor(UIColor.init(white: 0.574, alpha: 1))
        
        return actionS
    }()
    var footerBtn:UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customLizeNavigationBarBackBtn()
        navigationTitleLabel.text = "个人中心"

        tableView.backgroundColor = RGBCOLORV(0xfafafa)
        tableView.tableFooterView = UIView()
        
        footerBtn = UIButton.init(type: UIButtonType.custom)
        footerBtn.setTitle("退出账号", for: UIControlState())
        footerBtn.setBackgroundColor(RGBCOLORV(0x79c542), forState: UIControlState())
        footerBtn.addTarget(self, action: #selector(logoutAction), for: UIControlEvents.touchUpInside)
        view.addSubview(footerBtn)
        
        // 添加约束
        addViewConstranit()
    
        
    }
    
    func addViewConstranit() -> Void {
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(footerBtn.top).offset(5)
        }
        
        footerBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(50)
            
        }
    }
    
    
    
    //MARK: IBActionSheetDelegate
    func actionSheet(_ actionSheet: IBActionSheet!, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            LOGINMANAGER.logout({
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationLoginStateChanged), object: nil)
                AppNavigator.openLoginController()
            })
            
        }else{
        
            // 清除账号
            Defaults.remove(OldAccount)
            LOGINMANAGER.logout({
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationLoginStateChanged), object: nil)
                AppNavigator.openOtherAccountLoginController()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func backAction() {
        AppNavigator.openMainViewController()
    }
}

// MARK: Action
extension UserSpaceViewController{

    func logoutAction() -> Void {
        
        self.actionSheet.show(in: APP_DELEGATE.window)
        
    }
}

// MARK: tableviewDelegate
extension UserSpaceViewController{

    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        let sectionNum = self.cellTitle.count
        return sectionNum
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellArr = self.cellTitle[section]
        return cellArr.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 15))
        sectionHeader.backgroundColor = RGBCOLORV(0xfafafa)
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 82
        default:
            return 55

        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.section, indexPath.row) {
        case (0, _), (1,_):
           let cell = LeftMenuUserSpaceCell.cellWithTableView(tableView) as! LeftMenuUserSpaceCell
            cell.setDefaultValue(indexPath, titleArray: cellTitle as Array<AnyObject>)
           return cell

        case (2, _):
            let cell = LeftMenuUserSpaceCell.flowCellWithTableView(tableView) as! LeftMenuUserSpaceCell
            cell.setDefaultValue(indexPath, titleArray: cellTitle as Array<AnyObject>)

            let progressWidth = cell.cellStoreProgress.w
            // 最大200M , 已经用了20M
            
            
            createGradient(cell.cellStoreProgress, frame: CGRect(x: 0, y: 0, width: 20 * progressWidth/200, height: 10))
            
            return cell

        default:
            let cell = UITableViewCell()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! LeftMenuUserSpaceCell
        
        
        switch (indexPath.section, indexPath.row) {
        case(0,0):
            selectPhoto(cell)
        case (0,1):
            let modifyNickname = ModifyUserInfoVC.init(navigationTitle: "修改昵称", fromCell: cellTitle[0][1])
            modifyNickname.modifyNickName = {
                
                (nickName:String) -> Void in
                cell.nickNameLabel.text = nickName
            }
            AppNavigator.pushViewController(modifyNickname, animated: true)
        case (0,2):
            let modifyNickname = ModifyUserInfoVC.init(navigationTitle: "修改性别", fromCell: cellTitle[0][2])
            modifyNickname.selectGender = {
            
                (cellDetail:String) -> Void in
                cell.cellDetail.setTitle(cellDetail, for: UIControlState())
            }
            AppNavigator.pushViewController(modifyNickname, animated: true)
        case (1,0):
            
            let modifyPwdVC = getViewControllerFromStoryBoard("RegisterLogin", viewControllerIdentify: "ModifyPasswordVC")
            AppNavigator.pushViewController(modifyPwdVC, animated: true)
            
        default:
            break
        }
    }
    
    
    // 添加渐变层
    func createGradient(_ view:UIView, frame:CGRect) -> Void {
        progressLayer = CALayer()
        progressLayer.frame = frame
        view.layer.addSublayer(progressLayer)
        progressLayer.backgroundColor = RGBCOLORV(0x79c542).cgColor
    }
    
    func selectPhoto(_ cell: LeftMenuUserSpaceCell) -> Void {
        let imagePickerController:TZImagePickerController = TZImagePickerController.init(maxImagesCount: 1, delegate:nil)
        imagePickerController.pickerDelegate = self
        imagePickerController.didFinishPickingPhotosHandle = { (photos, assets, isOriginal) in
            
            let image = photos?[0]
            image?.resize(cell.cellDetail.size.width)
            
            cell.cellDetail.setImage(image, for: UIControlState())
            let currentUsr = UserObject.fetchUserObj((APP_UTILITY.currentUser?.userID)!)
            
            currentUsr!.updateUserObj({
                currentUsr!.userPortrial = image
                })
            
        }
        presentVC(imagePickerController)
    }
}

// MARK: -- 让tableview的分割线穿透左边
extension UserSpaceViewController{

    override func viewDidLayoutSubviews() {
        if tableView.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            tableView.separatorInset = UIEdgeInsets.zero
        }
        if tableView.responds(to: #selector(setter: UIView.layoutMargins)) {
            tableView.layoutMargins = UIEdgeInsets.zero
        }
    }
    
     func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = UIEdgeInsets.zero
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
}

// MARK: 让tableview的section不悬停
extension UserSpaceViewController{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let sectionHeaderHeight:CGFloat = 15
        if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
        }else if scrollView.contentOffset.y >= sectionHeaderHeight {
            
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0)
        }
        
    }
}


