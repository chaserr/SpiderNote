//
//  SearchMindResultVCTableViewController.swift
//  Spider
//
//  Created by 童星 on 16/7/22.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import RealmSwift

class SearchMindResultVC: BaseTableViewController {

    var searchHistories:NSMutableArray = NSMutableArray() // mian搜索记录
    var questionDataSource:Array<AnyObject>? = []
    /**判断列表的显示内容是搜索记录，节点，还是长文*/
    var showQuestion:Bool = false
    /** 查询参数 */
    var containsParameter: String! = ""
    
    lazy var titleLabel:UILabel = {
        
        let titleL = UILabel.init(frame: CGRectMake(12, 0, 200, 30))
//        titleL.textColor = RGBCOLOR(0, g: 104, b: 248)
        titleL.font = SYSTEMFONT(14)
        return titleL
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = CGRectMake(0, 0, kScreenWidth, 0)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        // 获取本地搜索历史
        showSearchController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func showSearchController() -> Void {
        
        // 获取搜索历史记录
        let histories = Defaults.objectForKey(kMindSearchHistory)
        if histories != nil {
            searchHistories.addObjectsFromArray(histories as! [AnyObject])
            
        }
        self.reloadViewLayouts()
        (self.parentViewController as!SearchMainViewController).searchBar.becomeFirstResponder()
        
    }
    
    func reloadViewLayouts() -> Void {
        if showQuestion {
            // 用户点击搜索，搜索出问题时，现实问题列表
            view.frame = CGRectMake(view.x, view.y, view.w, UIScreen.mainScreen().bounds.height - 64)
            tableView.frame = CGRectMake(0, tableView.y, tableView.w, view.h - 40)
            
        }
        else{
            
            // 显示搜索记录
            var footerH:CGFloat = 0
            
            if searchHistories.count > 0 {
                footerH = kHeightForFooterInSection
            }
            let historySearchViewH = (CGFloat)((searchHistories.count)) * 44 + footerH
            var tableviewH:CGFloat = 64
            if historySearchViewH > kScreenHeight - 64 {
                tableviewH = kScreenHeight - 64
            }else{
                
                tableviewH = historySearchViewH
            }
            tableView.frame = CGRectMake(0, tableView.y, kScreenWidth, tableviewH)
            
        }
        
        tableView.reloadData()
    }
    
}

// MARK: - Table view data source
extension SearchMindResultVC{
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showQuestion {
            return questionDataSource!.count
        }else{
            
            return searchHistories.count
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if !showQuestion && searchHistories.count > 0 {
            return (kHeightForFooterInSection)
        }else{
            
            return (kMinTableViewHeight)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if showQuestion {
            return 30
        }else{
            
            return (kMinTableViewHeight)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if showQuestion {
            return 80
        }else{
            
            return 44
        }
    }
    
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerView:UIView?
        
        if showQuestion {
            headerView = UIView.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.w, 30))
            headerView!.backgroundColor = UIColor.whiteColor()
            headerView!.addSubview(titleLabel)
            let headString = "与\(self.containsParameter)有关的搜索结果:\(questionDataSource!.count)条记录"
            titleLabel.attributedText = headString.colorSubString(containsParameter, color: UIColor.redColor())
            let cureLine:UIView = UIView.init(frame: CGRectMake(0, titleLabel.y + titleLabel.h, UIScreen.mainScreen().bounds.width - 12, 0.5))
            cureLine.backgroundColor = RGBCOLOR(224, g: 224, b: 224)
            headerView!.addSubview(cureLine)
        }
        
        return headerView
        
    }
    
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if !showQuestion && searchHistories.count > 0 {
            let footerView = UIView.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, kHeightForFooterInSection))
            footerView.backgroundColor = UIColor.whiteColor()
            let btn:UIButton = UIButton.init(frame: CGRectMake(0, 10, kScreenWidth, 30))
            footerView.addSubview(btn)
            footerView.addBorderBottom(size: 0.5, color: RGBCOLORV(0xBCBAC1))
            btn.setBackgroundColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            btn.adjustsImageWhenHighlighted = false
            btn.setTitleColor(RGBCOLORV(0xaaaaaa), forState: UIControlState.Normal)
            btn.layer.cornerRadius = 4
            btn.setTitle("清空搜索历史", forState: UIControlState.Normal)
            btn.titleLabel?.font = UIFont.init(name: "Superclarendon-Light", size: 16)
            btn.addTarget(self, action: #selector(clearHistoriesButtonClicked), forControlEvents: UIControlEvents.TouchUpInside)
            return footerView
        }
        return nil
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if showQuestion {
            
            let cell:SearchResultCell = SearchResultCell.cellWithTableView(tableView) as! SearchResultCell
            
            let mindType = self.questionDataSource![indexPath.row] as! MindObject
            
            let length = mindType.structInfo.lengths - (" > " + mindType.name).lengths
            cell.structPath.text = mindType.structInfo.substringToIndex(mindType.structInfo.startIndex.advancedBy(length))

            let headString = mindType.name
            cell.mindName.attributedText = headString.colorSubString(containsParameter, color: UIColor.redColor())
            return cell
            
        }
        else{
            let searchHistoryTableViewCell = "searchHistoryTableViewCell";
            var cell = tableView.dequeueReusableCellWithIdentifier(searchHistoryTableViewCell)
            if cell == nil {
                
                cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "searchHistoryTableViewCell");
                cell?.contentView.addSubLayerWithFrame(CGRectMake(0, 44 - 0.5, UIScreen.mainScreen().bounds.w, 0.5), color: RGBCOLOR(200, g: 199, b: 204).CGColor)
                cell?.textLabel?.backgroundColor = UIColor.whiteColor()
            }
            
            cell?.imageView?.image = UIImage.init(named: "SearchHistory")
            cell!.textLabel!.text = self.searchHistories[indexPath.row] as? String;
            cell!.textLabel!.font = SYSTEMFONT(14)
            let rightBtn = UIButton.init(type: UIButtonType.Custom)
            rightBtn.frame = CGRectMake(kScreenWidth - 44, 0, 44, 44)
            rightBtn.addTarget(self, action: #selector(rightBtnDidClick), forControlEvents: UIControlEvents.TouchUpInside)
            rightBtn.setImage(UIImage.init(named: "search_history_delete_icon"), forState: UIControlState.Normal)
            rightBtn.tag = indexPath.row
            cell?.contentView.addSubview(rightBtn)
            return cell!
            
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if showQuestion {
            // 点击问题跳转到问题详情
            
            let cell:SearchResultCell = tableView.cellForRowAtIndexPath(indexPath) as! SearchResultCell
            let mindType = self.questionDataSource![indexPath.row] as! MindObject
            // 根据路径的">"符号来判断层级
            let levelCount = cell.structPath.text?.componentsSeparatedByString(" > ")
            // TODO: 层级的改变
            SpiderStruct.sharedInstance.currentLevel = (levelCount?.count)! - 1
            
            if (mindType.ownerProject.first != nil) {
                // 父节点是顶级节点：项目
                let projrctMind = MindViewController.init(ownerProject: mindType.ownerProject.first!)
                SPIDERSTRUCT.sourceMindType = SourceMindControType.ComeFromSearch
                projrctMind.searchResultMind = mindType
                AppNavigator.pushViewController(projrctMind, animated: true)
                
            }else{
                // 父节点是自身： mind
                let mindObj = MindViewController.init(ownerMind: mindType.ownerMind.first!)
                mindObj.searchResultMind = mindType
                SPIDERSTRUCT.sourceMindType = SourceMindControType.ComeFromSearch
                AppNavigator.pushViewController(mindObj, animated: true)
                
            }
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }else{
            
            (self.parentViewController as! SearchMainViewController).searchBar.text = searchHistories[indexPath.row] as? String
            self.containsParameter = searchHistories[indexPath.row] as? String
            getQuestionList(nil)
        }
    }
    
    
    
    
    /**
     * 删除某个历史搜索关键词
     */
    func rightBtnDidClick(sender:UIButton) -> Void {
        
        searchHistories.removeObject(searchHistories[sender.tag])
        Defaults[kMindSearchHistory] = searchHistories
        Defaults.synchronize()
        reloadViewLayouts()
    }
    
    /**
     *  清除搜索记录
     */
    func clearHistoriesButtonClicked(sender:UIButton) -> Void {
        searchHistories.removeAllObjects()
        Defaults[kMindSearchHistory] = searchHistories
        Defaults.synchronize()
        reloadViewLayouts()
    }
    
    func getQuestionList(startID:NSNumber?) -> Void {
//        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        questionDataSource?.removeAll()
        //[c]不区分大小写 [d]无音调  [cd]两个都不要  (断言编程指南)
        let predicate = NSPredicate(format: "type == 0 AND deleteFlag == 0 AND name CONTAINS[c] %@", containsParameter)
        let mindObjectArr = (REALM.realm?.objects(MindObject).sorted("updateAtTime", ascending: false).filter(predicate))!.toArray()

        // 从当前结点搜
        if SPIDERSTRUCT.currentMindPath == nil {
            questionDataSource = mindObjectArr
        }else{
            let currentCount = SPIDERSTRUCT.currentMindPath!.componentsSeparatedByString(" > ")

            for mindType in mindObjectArr {
                let queryCount = mindType.structInfo.componentsSeparatedByString(" > ")
                
                if mindType.structInfo.containsString(SPIDERSTRUCT.currentMindPath!) && queryCount.count > currentCount.count {
                    questionDataSource?.append(mindType)
                }
            }
        }
        showQuestion = true
        reloadViewLayouts()
    }
}

// MARK: -- 让tableview的分割线穿透左边
extension SearchMindResultVC{
    
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

