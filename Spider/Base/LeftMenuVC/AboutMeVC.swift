//
//  AboutMeVC.swift
//  Spider
//
//  Created by 童星 on 16/7/14.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class AboutMeVC: BaseTableViewController {

    lazy var cellTitle = {
        
        return [["蜘蛛笔记"],  ["新浪微博", "微信公众号", "官方Q群"],["电话", "邮箱"], ["免责申明"]]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customLizeNavigationBarBackBtn()
        navigationTitleLabel.text = "关于蜘蛛笔记"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension AboutMeVC{

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let sectionNum = self.cellTitle.count
        return sectionNum
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellArr = self.cellTitle[section]
        return cellArr.count
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1,2:
            return 22
        default:
            return 15
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = UIView.init(frame: CGRectMake(0, 0, kScreenWidth, 22))
        sectionHeader.backgroundColor = RGBCOLORV(0xfafafa)
        let titleLabel = UILabel.init(frame:CGRectMake(10, 0, kScreenWidth - 20, 22))
        titleLabel.textAlignment = NSTextAlignment.Left
        titleLabel.textColor = RGBCOLORV(0x999999)
        titleLabel.font = SYSTEMFONT(11)
        sectionHeader.addSubview(titleLabel)
        
        switch section {
        case 1:
            titleLabel.text = "联系方式"
        case 2:
            titleLabel.text = "市场合作"
        default:
            titleLabel.text = ""
        }
        
        
        return sectionHeader
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 180
        case (3, 0):
            return 90
        default:
            return 55
            
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = AboutMeCell.cellWithTableView(tableView, indexPath: indexPath) as! AboutMeCell
        cell.setDefaultValue(indexPath, titleArray: cellTitle)

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0,1):
            let modifyNickname = ModifyUserInfoVC.init(navigationTitle: "修改昵称", fromCell: cellTitle[0][1])
            AppNavigator.pushViewController(modifyNickname, animated: true)
        case (0,2):
            let modifyNickname = ModifyUserInfoVC.init(navigationTitle: "修改性别", fromCell: cellTitle[0][2])
            AppNavigator.pushViewController(modifyNickname, animated: true)
        default:
            break
        }
    }
    
}

// MARK: -- 让tableview的分割线穿透左边
extension AboutMeVC{
    
    override func viewDidLayoutSubviews() {
        if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
}

// MARK: 让tableview的section不悬停
extension AboutMeVC{
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let sectionHeaderHeight:CGFloat = 15
        if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
        }else if scrollView.contentOffset.y >= sectionHeaderHeight {
            
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0)
        }
        
    }
}




