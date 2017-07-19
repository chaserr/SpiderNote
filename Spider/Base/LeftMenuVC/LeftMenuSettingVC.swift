//
//  LeftMenuSettingV.swift
//  Spider
//
//  Created by 童星 on 16/7/12.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  设置界面

import UIKit
import Reachability
let kPrefixOfcellDetailKey = "kPrefixOfcellDetailKey"

class LeftMenuSettingVC: BaseTableViewController {
    
    
    lazy var cellTitle = {
    
        return [["自动同步", "同步频率", "仅在wifi连接时同步", "上传图片大小"], ["清除缓存"], ["当前版本"], ["评价蜘蛛笔记", "关于蜘蛛笔记"]]
    }()
    
//    lazy var cellDetail:Dictionary = {
//    
//        return [:]
//    }()
    
    var cellDetailDict:Dictionary = [String:String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.navigationTitleLabel.text = "设置"
        self.customLizeNavigationBarBackBtn()
        self.tableView.tableFooterView = UIView()
        
        let reach = Reachability.forInternetConnection().currentReachabilityStatus()
        switch(reach) {
        case .NotReachable:
            alert("", message: "没有网络", parentVC: self)
        case .ReachableViaWiFi:
            alert("", message: "WiFi网络", parentVC: self)
            
        case .ReachableViaWWAN:
            alert("", message: "窝蜂网", parentVC: self)
            
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


// MARK: -- tableviewDelegate and datasource method
extension LeftMenuSettingVC{

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
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if APP_USER.autoSync == 0 && indexPath == IndexPath(row: 1, section: 0){

            return 0
        }
        return 55
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = LeftMenuSettingCell.cellWithTableView(tableView) as! LeftMenuSettingCell
        
        cell.switchBlock { (senderOn) in
            senderOn ? cell.isHidden == false : cell.isHidden == true
            tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.fade)
        }
        
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            if APP_USER.autoSync == 0 && indexPath == IndexPath(row: 1, section: 0){
                cell.isHidden = true
            }
        case (1, 0):
            self.cellDetailDict["\(indexPath.row)\(indexPath.section)"] = getCacheSize()
        default:
            break
        }
        
        cell.setDefaultValue(indexPath, titleArray: self.cellTitle as Array<AnyObject>, cellDetailDic: self.cellDetailDict)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! LeftMenuSettingCell

        switch (indexPath.section, indexPath.row) {
        case (0,1):

            let arr = ["15分钟", "30分钟", "60分钟", "每天", "取消"]
            showAlert(arr, cell: cell)

            
        case (0,3):
            
            let arr = ["原图", "最大2M", "最大500k", "取消"]
            showAlert(arr, cell: cell)
        case (1, 0):
            clearCache()
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.none)
            AOHUDVIEW.showTipsWithAutoHide("清除缓存成功", autoHideTime: 1)
        case (2,0):  // 检查更新
            break
// TODO: 版本检测是不被允许存在的，审核期间隐藏此功能，审核之后可以根据后台字段出现
//            let alertView = CustomSystemAlertView.init(title:nil, message: "更新至1.2.0版本", cancelButtonTitle: "取消", sureButtonTitle: "更新")
//            alertView.show()
//            alertView.clickIndexClosure({ (index) in
//
//                if index == 1{
//                
//                    alert("更新", message: nil, parentVC: self)
//                }
//            })
            
            
        case (3,1):
            let aboutMe = AboutMeVC()
            AppNavigator.pushViewController(aboutMe, animated: true)
            
        default:
            break
        }
    }
    
    func showAlert(_ titleArray:Array<String>, cell:LeftMenuSettingCell) -> Void {
        let alertView:CustomAlertView = CustomAlertView.init(frame: kScreenBounds, titlesArray: titleArray)

        let indexPath:IndexPath = tableView.indexPath(for: cell)!
        
        alertView.clickBtnIndex = {
            (index:Int, string:String) -> Void in

            if string != "取消" {
                cell.cellDetail.setTitle(string, for: UIControlState())
                switch (indexPath.section,indexPath.row) {
                case (0,1): // 同步频率
                    APP_USER.syncrate = string
                case (0,3): // 上传图片大小
                    APP_USER.uploadPhotoSizeLiimit = string
                default:
                    break
                }
                APP_USER.saveUserInfo()
            }
            
        }
        alertView.show()

    }
}


// MARK: -- 让tableview的分割线穿透左边
extension LeftMenuSettingVC{
    
    override func viewDidLayoutSubviews() {
        if tableView.responds(to: Selector("setSeparatorInset:")) {
            tableView.separatorInset = UIEdgeInsets.zero
        }
        if tableView.responds(to: Selector("setLayoutMargins:")) {
            tableView.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        if cell.responds(to: Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsets.zero
        }
        if cell.responds(to: Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
}

// MARK: 让tableview的section不悬停
extension LeftMenuSettingVC{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let sectionHeaderHeight:CGFloat = 15
        if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
        }else if scrollView.contentOffset.y >= sectionHeaderHeight {
            
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0)
        }
        
    }
}

// MARK: 获取缓存大小
extension LeftMenuSettingVC{

    // 拼接缓存大小
    func getCacheSize() -> String {
        let cachePath:String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        // 获取cache文件夹下的缓存大小
        let size:NSInteger = FileUtil.getFileUtil().getSizeOfDirectoryPath(cachePath)
        var str: String = "0.00K"
        //判断尺寸大小,拼接不同显示方式
        if size > 1000 * 1000 {
            let sizeMB: CGFloat = CGFloat(size) / 1000.0 / 1000.0
            str = "\(String(format: "%.1f", sizeMB))MB"
        } else if size > 1000 {
            let sizeKB: CGFloat = CGFloat(size) / 1000.0
            str = "\(String(format: "%.1f", sizeKB))KB"
        } else if size > 0 {
            str = "\(size)dB"
        }
        
        return str
    }
    /**
     清理缓存
     */
    func clearCache() -> Void {
        let cachePath: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        FileUtil.getFileUtil().removeDirectoryPath(cachePath)
    }
}

