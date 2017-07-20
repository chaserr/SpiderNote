//
//  SearchArticleResultVC.swift
//  Spider
//
//  Created by 童星 on 16/7/22.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import RealmSwift
class SearchArticleResultVC: BaseTableViewController, UINavigationControllerDelegate {
    
    var searchHistories: NSMutableArray = NSMutableArray() // 搜索记录
    var questionDataSource: Array<AnyObject>? = []
    /**判断列表的显示内容是搜索记录，节点，还是长文*/
    var showQuestion: Bool = false
    var searchtype: SearchType?
    /** 查询参数 */
    var containsParameter: String! = ""
    var resultArticleArr: Array = [MindObject]()
    var unArchiveArr: Array = [ArticleModel]()
    
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        tableView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 0)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = UIColor.white
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        tableView.showsVerticalScrollIndicator = true
        tableView.tableFooterView = footerView
        
        // 获取本地搜索历史
        showSearchController()
       
        notificationToken = REALM.realm.addNotificationBlock({ (notification, realm) in
            self.getQuestionList(nil)
        })
    }
    
    deinit{
    
        notificationToken?.stop()
    }
    
    // MARK:控制器生命周期
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        if containsParameter != ""
//        {
//            getQuestionList(nil)
//        }
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
    
    func showSearchController() -> Void {
        
        // 获取搜索历史记录
        let histories = Defaults.object(forKey: kArticleSearchHistory)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: 懒加载
    lazy var titleLabel:UILabel = {
        
        let titlel  = UILabel.init(frame: CGRect(x: 12, y: 0, width: 200, height: 30))
        //        titleL.textColor = RGBCOLOR(0, g: 104, b: 248)
        titlel.font = SYSTEMFONT(14)
        return titlel
    }()
    lazy var footerView:UIView = {
        let view             = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 1))
        view.backgroundColor = RGBCOLORV(0xeaeaea)
        return view
    }()


}
// MARK: - Table view data source
extension SearchArticleResultVC{
    
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
            let articleModel = questionDataSource![indexPath.row] as! ArticleModel
            return articleModel.cellRowHight
//            return 560
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
    
//    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 250
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showQuestion {
            let cellID = SearchArticleCell.className + "Mind"
            
            var cell: SearchArticleCell? = tableView.dequeueReusableCell(withIdentifier: cellID) as? SearchArticleCell
            if cell == nil {
                cell = SearchArticleCell.init(style: UITableViewCellStyle.default, reuseIdentifier: cellID)
            }else{
            
//                while cell?.contentView.subviews.last != nil {
//                    cell?.contentView.subviews.last?.removeFromSuperview()
//                }

            }
            
            // Cell点击回调
            cell!.TappedAction({ (type, textSec, picSec, videoSec) in
                switch type {
                case.title:
                    // 当前cell对应的articleMind
                    if self.searchtype == .Project {
                        
                        let unarchiveResultVC = UndocBoxViewController()
                        AppNavigator.pushViewController(unarchiveResultVC, animated: true)
                        
                    }else{
                    
                        let articleMind = self.resultArticleArr[indexPath.row]
                        SpiderConfig.ArticleList.article = articleMind
                        let searchResultVC = ArticleListViewController()
                        AppNavigator.pushViewController(searchResultVC, animated: true)
                    }
                    
                case.text:
                    alert(textSec?.text, message: nil, parentVC: self)
                case.pic:
                    let sectionInfo = picSec?.owner.first
                    let tagInfo = picSec!.tags.filter(NSPredicate(format: "type == 0 AND content CONTAINS[c] %@", self.containsParameter)).toArray().first
                    let picDetailVC = PicDetailViewController.init(picSection: sectionInfo, photos: nil, toShowTag: tagInfo)
                    self.navigationController?.pushViewController(picDetailVC, animated: true)
                case.video:

                    let tagInfo = videoSec!.audio!.tags.filter(NSPredicate(format: "type == 0 AND content CONTAINS[c] %@", self.containsParameter)).toArray().first
                    let audioDetailVC = AudioSectionViewController(section: videoSec, toShowTag: tagInfo)
                    self.navigationController?.pushViewController(audioDetailVC, animated: true)
                    
                }
            })
            
            
            cell?.searchKey = containsParameter
            cell?.articleModel = questionDataSource![indexPath.row] as? ArticleModel
            

            return cell!
            
        }
        else{
            let searchHistoryTableViewCell = "searchHistoryTableViewCell";
            var cell = tableView.dequeueReusableCell(withIdentifier: searchHistoryTableViewCell)
            if cell == nil {
                
                cell                             = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "searchHistoryTableViewCell");
                cell?.contentView.addSubLayerWithFrame(CGRect(x: 0, y: 44 - 0.5, width: UIScreen.main.bounds.w, height: 0.5), color: RGBCOLOR(200, g: 199, b: 204).cgColor)
                cell?.textLabel?.backgroundColor = UIColor.white
            }
            
            cell?.imageView?.image = UIImage.init(named: "SearchHistory")
            cell!.textLabel!.text  = self.searchHistories[indexPath.row] as? String;
            cell!.textLabel!.font  = SYSTEMFONT(14)
            let rightBtn           = UIButton.init(type: UIButtonType.custom)
            rightBtn.frame         = CGRect(x: kScreenWidth - 44, y: 0, width: 44, height: 44)
            rightBtn.addTarget(self, action: #selector(rightBtnDidClick), for: UIControlEvents.touchUpInside)
            rightBtn.setImage(UIImage.init(named: "search_history_delete_icon"), for: UIControlState())
            rightBtn.tag           = indexPath.row
            cell?.contentView.addSubview(rightBtn)
            return cell!
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if showQuestion {
            // 点击问题跳转到问题详情
        
        }else{
            
            (self.parent as!SearchMainViewController).searchBar.text = searchHistories[indexPath.row] as? String
            self.containsParameter = searchHistories[indexPath.row] as? String
            getQuestionList(nil)
        }
    }
    
    /**
     * 删除某个历史搜索关键词
     */
    func rightBtnDidClick(_ sender:UIButton) -> Void {
        
        searchHistories.remove(searchHistories[sender.tag])
        Defaults[kArticleSearchHistory] = searchHistories
        Defaults.synchronize()
        reloadViewLayouts()
    }
    
    /**
     *  清除搜索记录
     */
    func clearHistoriesButtonClicked(_ sender:UIButton) -> Void {
        searchHistories.removeAllObjects()
        Defaults[kArticleSearchHistory] = searchHistories
        Defaults.synchronize()
        reloadViewLayouts()
    }

    // 开始查询
    func getQuestionList(_ startID:NSNumber?) -> Void {
//        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        questionDataSource?.removeAll()
        resultArticleArr.removeAll()
        unArchiveArr.removeAll()
        //[c]不区分大小写 [d]无音调  [cd]两个都不要  (断言编程指南)
        var articleSearchArray = [ArticleModel]()

        if searchtype == .Project {
            let articleModel:ArticleModel = ArticleModel()
            // 查询未归档
            let unarchivePredicate = NSPredicate(format: "type == 1 AND undocFlag == 1 AND deleteFlag == 0")
            let sectionArr = REALM.realm.objects(SectionObject.self).sorted(byKeyPath: "updateAt", ascending: false).filter(unarchivePredicate)
            // 查询文字段落
            let sectionTextArr = sectionArr.filter(NSPredicate(format: "type == 0 AND deleteFlag == 0 AND text CONTAINS[c] %@", containsParameter)).sorted(byKeyPath: "updateAt", ascending: false).toArray()
            
            // 查询图片段落
            let sectionPicArr = sectionArr.filter(NSPredicate(format: "type == 1 AND deleteFlag == 0")).sorted(byKeyPath: "updateAt", ascending: false).toArray()
            var picSecObjArr = [PicSectionObject]() // 存放符合条件的图片
            for picSection in sectionPicArr {
                // 每一个图片段落的每张图片包含的标签
                let picArray = picSection.pics
                for pigSecObj in picArray {
                    // 如果一张图片多个文字标签包含，那么取第一个文字标签
                    let picTag = pigSecObj.tags.filter(NSPredicate(format: "type == 0 AND content CONTAINS[c] %@", containsParameter)).toArray().first
                    if (picTag != nil) {
                        picSecObjArr.append(pigSecObj)
                    }
                }
            }
            
            // 查询音频段落
            let vedioSecArr = sectionArr.filter(NSPredicate(format: "type == 2 AND deleteFlag == 0")).sorted(byKeyPath: "updateAt", ascending: false).toArray()
            var vedioSecObjArr = [SectionObject]() // 存放符合条件的音频
            for vedioSection in vedioSecArr {
                // 每一个音频段落的每个文字标签
                // 如果一张图片多个文字标签包含，那么取第一个文字标签
                let vedioTag = vedioSection.audio?.tags.filter(NSPredicate(format: "type == 0 AND content CONTAINS[c] %@", containsParameter)).toArray().first
                if (vedioTag != nil) {
                    vedioSecObjArr.append(vedioSection)
                }
            }
            if sectionTextArr.count != 0 || picSecObjArr.count != 0 || vedioSecObjArr.count != 0 { // 段落包含
                articleModel.title = "未归档"
                articleModel.updateTime = nil
                articleModel.textSectionArr = sectionTextArr
                articleModel.picSectionArr = picSecObjArr
                articleModel.vedioSectionArr = vedioSecObjArr
                articleSearchArray.append(articleModel)
            }
            /******************************未归档*********************************/
        }
        
        
        
        // 1. 查询出所有文章
        let articlePredicate = NSPredicate(format: "type == 1 AND deleteFlag == 0")
        let allArticleArr = REALM.realm.objects(MindObject.self).sorted(byKeyPath: "updateAtTime", ascending: false).filter(articlePredicate)
        for articleObj in allArticleArr.toArray() {
            let articleModel:ArticleModel = ArticleModel()
            // 查询文字段落
            let sectionArr = articleObj.sections.filter(NSPredicate(format: "type == 0 AND deleteFlag == 0 AND text CONTAINS[c] %@", containsParameter)).sorted(byKeyPath: "updateAt", ascending: false).toArray()
            
            // 查询图片段落
            let sectionPicArr = articleObj.sections.filter(NSPredicate(format: "type == 1 AND deleteFlag == 0")).sorted(byKeyPath: "updateAt", ascending: false).toArray()
            var picSecObjArr = [PicSectionObject]() // 存放符合条件的图片
            for picSection in sectionPicArr {
                // 每一个图片段落的每张图片包含的标签
                let picArray = picSection.pics
                for pigSecObj in picArray {
                    // 如果一张图片多个文字标签包含，那么取第一个文字标签
                    let picTag = pigSecObj.tags.filter(NSPredicate(format: "type == 0 AND content CONTAINS[c] %@", containsParameter)).toArray().first
                    if (picTag != nil) {
                        picSecObjArr.append(pigSecObj)
                    }
                }
            }
            
            // 查询音频段落
            let vedioSecArr = articleObj.sections.filter(NSPredicate(format: "type == 2 AND deleteFlag == 0")).sorted(byKeyPath: "updateAt", ascending: false).toArray()
            var vedioSecObjArr = [SectionObject]() // 存放符合条件的音频
            for vedioSection in vedioSecArr {
                // 每一个音频段落的每个文字标签
                // 如果一张图片多个文字标签包含，那么取第一个文字标签
                let vedioTag = vedioSection.audio?.tags.filter(NSPredicate(format: "type == 0 AND content CONTAINS[c] %@", containsParameter)).toArray().first
                    if (vedioTag != nil) {
                        vedioSecObjArr.append(vedioSection)
                    }
            }

            if sectionArr.count != 0 || picSecObjArr.count != 0 || vedioSecObjArr.count != 0 || articleObj.name.contains("\(containsParameter)"){ // 段落包含 || 段落不包含标题包含也要显示
                articleModel.title = articleObj.name
                articleModel.updateTime = articleObj.updateAtTime
                articleModel.textSectionArr = sectionArr
                articleModel.picSectionArr = picSecObjArr
                articleModel.vedioSectionArr = vedioSecObjArr
                if SPIDERSTRUCT.currentMindPath == nil {
                    articleSearchArray.append(articleModel)
                    resultArticleArr.append(articleObj)
                }else{
                
                    let currentCount = SPIDERSTRUCT.currentMindPath!.components(separatedBy: " > ")
                    let queryCount = articleObj.structInfo.components(separatedBy: " > ")
                    if articleObj.structInfo.contains(SPIDERSTRUCT.currentMindPath!) && queryCount.count > currentCount.count { // 在当前结点搜索
                        articleSearchArray.append(articleModel)
                        resultArticleArr.append(articleObj)
                    }
                }
            }
        }

        questionDataSource = articleSearchArray

        showQuestion = true
        reloadViewLayouts()
    }
    
    func searchSection(_ article:MindObject) -> Void {
        
    }

    
}

