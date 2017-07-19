//
//  SearchMainViewController.swift
//  Spider
//
//  Created by 童星 on 16/7/18.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit


let kMindSearchHistory = "kMindSearchHistory"
let kArticleSearchHistory = "kArticleSearchHistory"
let kHeightForFooterInSection:CGFloat = 50
let kMinTableViewHeight:CGFloat = 0.01
let kSegmentHight:CGFloat = 40
let segmentArrayTitle = ["节点", "长文"]

enum SearchHistoriesNum:Int {
    case kMostNumber = 15
}

typealias CompletionBlock = () -> Void


class SearchMainViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate, LXDSegmentControlDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    var searchHistories:NSMutableArray       = NSMutableArray()// mian搜索记录
    var questionDataSource:Array<AnyObject>? = []

    var searchType: SearchType?
    
    /**判断列表的显示内容是搜索记录，节点，还是长文*/
    var showQuestion:Bool                    = false
    var currentPage:NSInteger!
    let searchMindResult                     = SearchMindResultVC()
    let searchArticleRes                     = SearchArticleResultVC()
    lazy var scrollView:UIScrollView = {
    
        let scrollV:UIScrollView = UIScrollView.init(frame: CGRect(x: 0, y: kSegmentHight, width: kScreenWidth, height: kScreenHeight - 64 - kSegmentHight))
        scrollV.showsHorizontalScrollIndicator = false
        scrollV.delegate = self
        scrollV.isPagingEnabled = true
        scrollV.isScrollEnabled = true
        scrollV.bounces = false
        scrollV.contentSize = CGSize(width: kScreenWidth * CGFloat(segmentArrayTitle.count), height: scrollV.h)
        return scrollV
        
    }()
    lazy var searchBar:CusSearchBar = {
    
        let searchB      = CusSearchBar.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 25))
        searchB.setShowsCancelButton(true, animated: true)
        searchB.delegate = self

        return searchB
    }()
    lazy var titleLabel:UILabel = {
    
        let titleL       = UILabel.init(frame: CGRect(x: 12, y: 14, width: 200, height: 16))
        titleL.textColor = RGBCOLOR(0, g: 104, b: 248)
        titleL.font      = SYSTEMFONT(14)
        return titleL
    }()
    lazy var segmentControl:LXDSegmentControl = {
    
        let config                           = LXDSegmentControlConfiguration.init(controlType: LXDSegmentControlTypeSlideBlock, items: segmentArrayTitle)
        config.itemSelectedColor             = UIColor.clear
        config.backgroundColor               = UIColor.white
        let segmentControl:LXDSegmentControl = LXDSegmentControl.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kSegmentHight), configuration: config, delegate: nil)
        segmentControl.addSubLayerWithFrame(CGRect(x: 0, y: segmentControl.frame.minY + 1, width: segmentControl.frame.width, height: 1), color: RGBCOLORV(0xdddddd).cgColor)
        segmentControl.addSubLayerWithFrame(CGRect(x: 0, y: segmentControl.frame.maxY - 1, width: segmentControl.frame.width, height: 1), color: RGBCOLORV(0xdddddd).cgColor)
        segmentControl.delegate              = self

        return segmentControl
    
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor                            = UIColor.white
        customLizeNavigationBarBackBtn()
        view.addSubview(self.segmentControl)
        searchArticleRes.searchtype = searchType
        self.addChildViewController(searchMindResult)
        self.addChildViewController(searchArticleRes)
        view.addSubview(self.scrollView)
        scrollViewAddView(searchMindResult.view, index: 0)
        scrollViewAddView(searchArticleRes.view, index: 1)
        currentPage                                     = 0

        showQuestion                                    = false
        navigationItem.titleView                        = self.searchBar
        navigationController?.navigationBar.setNeedsLayout()
        edgesForExtendedLayout                          = UIRectEdge()
        navigationController?.navigationBar.isTranslucent = true
        //        scrollToPage(0)
        let segmentItem = view.viewWithTag(10000) as! UIButton
        self.segmentControl.clickSegmentItem(segmentItem)
    }
    
    // MARK:控制器生命周期
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hiddenNavBottomLine()

        navigationController?.setBackgroundImage(UIImage.init(named: "search_navigationbar_background")!)

        UIApplication.shared.setStatusBarStyle(.default, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hiddenKeyBoard()
        
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func hiddenKeyBoard() -> Void {
        searchBar.resignFirstResponder()
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
    
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}


// MARK: -- LXDSegmentControlDelegate
extension SearchMainViewController{

    func segmentControl(_ segmentControl: LXDSegmentControl!, didSelectAt index: UInt) {
        
        scrollToPage(NSInteger(index))
        
        // 切换搜索源， 清空搜索框文字
        searchBar.text = ""
        if index == 0 {
            searchMindResult.reloadViewLayouts()
        }else{
        
            searchArticleRes.reloadViewLayouts()
        }

    }
}


// MARK: -- UISearchBarDelegate method
extension SearchMainViewController{

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.becomeFirstResponder()
        searchBar.setShowsCancelButton(true, animated: true)
        
        if currentPage == 0 {
            if searchMindResult.showQuestion {
                searchMindResult.showQuestion = false
            }
            searchMindResult.reloadViewLayouts()
        }else{
            if searchArticleRes.showQuestion {
                searchArticleRes.showQuestion = false
            }
            searchArticleRes.reloadViewLayouts()
        }
        
    }
    
    // 实时搜索
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.lengths <= 0 {
            return
        }
        if currentPage == 0 {
            if searchMindResult.showQuestion {
                searchMindResult.showQuestion = false
            }
            searchMindResult.containsParameter = searchText
            searchMindResult.getQuestionList(nil)

        }else{
            if searchArticleRes.showQuestion {
                searchArticleRes.showQuestion = false
            }
            searchArticleRes.containsParameter = searchText
            searchArticleRes.getQuestionList(nil)

        }
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        if searchBar.text?.length == 0 {
            return
        }
        
        if currentPage == 0 {
            if (searchMindResult.searchHistories.contains(searchBar.text!)) {
                searchMindResult.searchHistories.remove(searchBar.text!)
                
            }
            // 保存搜索记录，最多10条
            searchMindResult.searchHistories.insert(searchBar.text!, at: 0)
            if searchMindResult.searchHistories.count > SearchHistoriesNum.kMostNumber.rawValue {
                searchMindResult.searchHistories.removeLastObject()
            }
            
            Defaults[kMindSearchHistory] = searchMindResult.searchHistories
            Defaults.synchronize()
            
            // 开始搜索
            searchMindResult.getQuestionList(nil)
        }
        else{
            
            if (searchArticleRes.searchHistories.contains(searchBar.text!)) {
                searchArticleRes.searchHistories.remove(searchBar.text!)
                
            }
            
            // 保存搜索记录，最多10条
            searchArticleRes.searchHistories.insert(searchBar.text!, at: 0)
            if searchArticleRes.searchHistories.count > SearchHistoriesNum.kMostNumber.rawValue {
                searchArticleRes.searchHistories.removeLastObject()
            }
            
            Defaults[kArticleSearchHistory] = searchArticleRes.searchHistories
            Defaults.synchronize()
            
            // 开始搜索
            searchArticleRes.getQuestionList(nil)
        }
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        // 使用异步，防止点击取消按钮和键盘退出动画时间的冲突
        DispatchQueue.main.async { 
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
    }
    
}

// MARK: scrollerViewDelegate method
extension SearchMainViewController{
    
    
        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            if currentPage == (NSInteger)(scrollView.contentOffset.x / kScreenWidth) {
                return
            }
            else{
    
                let page = (NSInteger)(scrollView.contentOffset.x / kScreenWidth)
                setSegmentViewBtnWithPage(page)
                currentPage = page
    
            }
        }
    
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            if scrollView.className == "UIScrollView" {
                if currentPage == (NSInteger)(scrollView.contentOffset.x / kScreenWidth) {
                    return
                }
                else{
    
                    UIView.animate(withDuration: 0.5, animations: {
                        [weak self] in
                        let page = (NSInteger)(scrollView.contentOffset.x / kScreenWidth)
                        self!.setSegmentViewBtnWithPage(page)
                        self!.currentPage = page
                        })
    
                }
            }
    
        }
    
    
        func setSegmentViewBtnWithPage(_ page:NSInteger) -> Void {
            if currentPage == page {
                return
            }else{
    
                self.segmentControl.clickSegmentItem(view.viewWithTag(10000 + page) as! UIButton)
            }
        }
    
        func scrollViewAddView(_ view:UIView, index:Int) -> Void {
            let rect = self.scrollView.bounds
            view.frame = CGRect(x: CGFloat(index) * rect.width , y: 0, width: rect.width, height: rect.height )
            self.scrollView.addSubview(view)
    
        }
    
        func scrollToPage(_ page:NSInteger) -> Void {
            self.scrollView.scrollRectToVisible(CGRect(x: CGFloat(page) * kScreenWidth, y: self.scrollView.contentOffset.y, width: self.scrollView.w, height: self.scrollView.h), animated: true)
            
        }
    
}
