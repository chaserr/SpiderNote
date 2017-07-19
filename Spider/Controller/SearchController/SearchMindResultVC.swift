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
        
        let titleL = UILabel.init(frame: CGRect(x: 12, y: 0, width: 200, height: 30))
//        titleL.textColor = RGBCOLOR(0, g: 104, b: 248)
        titleL.font = SYSTEMFONT(14)
        return titleL
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 0)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = UIColor.white
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        // 获取本地搜索历史
        showSearchController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func showSearchController() -> Void {
        
        // 获取搜索历史记录
        let histories = Defaults.object(forKey: kMindSearchHistory)
        if histories != nil {
            searchHistories.addObjects(from: histories as! [AnyObject])
            
        }
        self.reloadViewLayouts()
        (self.parent as!SearchMainViewController).searchBar.becomeFirstResponder()
        
    }
    
    func reloadViewLayouts() -> Void {
        if showQuestion {
            // 用户点击搜索，搜索出问题时，现实问题列表
            view.frame = CGRect(x: view.x, y: view.y, width: view.w, height: UIScreen.main.bounds.height - 64)
            tableView.frame = CGRect(x: 0, y: tableView.y, width: tableView.w, height: view.h - 40)
            
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
            tableView.frame = CGRect(x: 0, y: tableView.y, width: kScreenWidth, height: tableviewH)
            
        }
        
        tableView.reloadData()
    }
    
}

// MARK: - Table view data source
extension SearchMindResultVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showQuestion {
            return questionDataSource!.count
        }else{
            
            return searchHistories.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if !showQuestion && searchHistories.count > 0 {
            return (kHeightForFooterInSection)
        }else{
            
            return (kMinTableViewHeight)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if showQuestion {
            return 30
        }else{
            
            return (kMinTableViewHeight)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        if showQuestion {
            return 80
        }else{
            
            return 44
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerView:UIView?
        
        if showQuestion {
            headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.w, height: 30))
            headerView!.backgroundColor = UIColor.white
            headerView!.addSubview(titleLabel)
            let headString = "与\(self.containsParameter)有关的搜索结果:\(questionDataSource!.count)条记录"
            titleLabel.attributedText = headString.colorSubString(containsParameter, color: UIColor.red)
            let cureLine:UIView = UIView.init(frame: CGRect(x: 0, y: titleLabel.y + titleLabel.h, width: UIScreen.main.bounds.width - 12, height: 0.5))
            cureLine.backgroundColor = RGBCOLOR(224, g: 224, b: 224)
            headerView!.addSubview(cureLine)
        }
        
        return headerView
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if !showQuestion && searchHistories.count > 0 {
            let footerView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: kHeightForFooterInSection))
            footerView.backgroundColor = UIColor.white
            let btn:UIButton = UIButton.init(frame: CGRect(x: 0, y: 10, width: kScreenWidth, height: 30))
            footerView.addSubview(btn)
            footerView.addBorderBottom(size: 0.5, color: RGBCOLORV(0xBCBAC1))
            btn.setBackgroundColor(UIColor.white, forState: UIControlState())
            btn.adjustsImageWhenHighlighted = false
            btn.setTitleColor(RGBCOLORV(0xaaaaaa), for: UIControlState())
            btn.layer.cornerRadius = 4
            btn.setTitle("清空搜索历史", for: UIControlState())
            btn.titleLabel?.font = UIFont.init(name: "Superclarendon-Light", size: 16)
            btn.addTarget(self, action: #selector(clearHistoriesButtonClicked), for: UIControlEvents.touchUpInside)
            return footerView
        }
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showQuestion {
            
            let cell:SearchResultCell = SearchResultCell.cellWithTableView(tableView) as! SearchResultCell
            
            let mindType = self.questionDataSource![indexPath.row] as! MindObject
            
            let length = mindType.structInfo.lengths - (" > " + mindType.name).lengths
            cell.structPath.text = mindType.structInfo.substring(to: mindType.structInfo.characters.index(mindType.structInfo.startIndex, offsetBy: length))

            let headString = mindType.name
            cell.mindName.attributedText = headString.colorSubString(containsParameter, color: UIColor.red)
            return cell
            
        }
        else{
            let searchHistoryTableViewCell = "searchHistoryTableViewCell";
            var cell = tableView.dequeueReusableCell(withIdentifier: searchHistoryTableViewCell)
            if cell == nil {
                
                cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "searchHistoryTableViewCell");
                cell?.contentView.addSubLayerWithFrame(CGRect(x: 0, y: 44 - 0.5, width: UIScreen.main.bounds.w, height: 0.5), color: RGBCOLOR(200, g: 199, b: 204).cgColor)
                cell?.textLabel?.backgroundColor = UIColor.white
            }
            
            cell?.imageView?.image = UIImage.init(named: "SearchHistory")
            cell!.textLabel!.text = self.searchHistories[indexPath.row] as? String;
            cell!.textLabel!.font = SYSTEMFONT(14)
            let rightBtn = UIButton.init(type: UIButtonType.custom)
            rightBtn.frame = CGRect(x: kScreenWidth - 44, y: 0, width: 44, height: 44)
            rightBtn.addTarget(self, action: #selector(rightBtnDidClick), for: UIControlEvents.touchUpInside)
            rightBtn.setImage(UIImage.init(named: "search_history_delete_icon"), for: UIControlState())
            rightBtn.tag = indexPath.row
            cell?.contentView.addSubview(rightBtn)
            return cell!
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if showQuestion {
            // 点击问题跳转到问题详情
            
            let cell:SearchResultCell = tableView.cellForRow(at: indexPath) as! SearchResultCell
            let mindType = self.questionDataSource![indexPath.row] as! MindObject
            // 根据路径的">"符号来判断层级
            let levelCount = cell.structPath.text?.components(separatedBy: " > ")
            // TODO: 层级的改变
            SpiderStruct.sharedInstance.currentLevel = (levelCount?.count)! - 1
            
            if (mindType.ownerProject.first != nil) {
                // 父节点是顶级节点：项目
                let projrctMind = MindViewController.init(ownerProject: mindType.ownerProject.first!)
                SPIDERSTRUCT.sourceMindType = SourceMindControType.comeFromSearch
                projrctMind.searchResultMind = mindType
                AppNavigator.pushViewController(projrctMind, animated: true)
                
            }else{
                // 父节点是自身： mind
                let mindObj = MindViewController.init(ownerMind: mindType.ownerMind.first!)
                mindObj.searchResultMind = mindType
                SPIDERSTRUCT.sourceMindType = SourceMindControType.comeFromSearch
                AppNavigator.pushViewController(mindObj, animated: true)
                
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        }else{
            
            (self.parent as! SearchMainViewController).searchBar.text = searchHistories[indexPath.row] as? String
            self.containsParameter = searchHistories[indexPath.row] as? String
            getQuestionList(nil)
        }
    }
    
    
    
    
    /**
     * 删除某个历史搜索关键词
     */
    func rightBtnDidClick(_ sender:UIButton) -> Void {
        
        searchHistories.remove(searchHistories[sender.tag])
        Defaults[kMindSearchHistory] = searchHistories
        Defaults.synchronize()
        reloadViewLayouts()
    }
    
    /**
     *  清除搜索记录
     */
    func clearHistoriesButtonClicked(_ sender:UIButton) -> Void {
        searchHistories.removeAllObjects()
        Defaults[kMindSearchHistory] = searchHistories
        Defaults.synchronize()
        reloadViewLayouts()
    }
    
    func getQuestionList(_ startID:NSNumber?) -> Void {
//        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        questionDataSource?.removeAll()
        //[c]不区分大小写 [d]无音调  [cd]两个都不要  (断言编程指南)
        let predicate = NSPredicate(format: "type == 0 AND deleteFlag == 0 AND name CONTAINS[c] %@", containsParameter)
        let mindObjectArr = (REALM.realm?.objects(MindObject.self).sorted("updateAtTime", ascending: false).filter(predicate))!.toArray()

        // 从当前结点搜
        if SPIDERSTRUCT.currentMindPath == nil {
            questionDataSource = mindObjectArr
        }else{
            let currentCount = SPIDERSTRUCT.currentMindPath!.components(separatedBy: " > ")

            for mindType in mindObjectArr {
                let queryCount = mindType.structInfo.components(separatedBy: " > ")
                
                if mindType.structInfo.contains(SPIDERSTRUCT.currentMindPath!) && queryCount.count > currentCount.count {
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

