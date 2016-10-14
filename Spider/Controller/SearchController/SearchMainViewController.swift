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
    
        let scrollV:UIScrollView = UIScrollView.init(frame: CGRectMake(0, kSegmentHight, kScreenWidth, kScreenHeight - 64 - kSegmentHight))
        scrollV.showsHorizontalScrollIndicator = false
        scrollV.delegate = self
        scrollV.pagingEnabled = true
        scrollV.scrollEnabled = true
        scrollV.bounces = false
        scrollV.contentSize = CGSizeMake(kScreenWidth * CGFloat(segmentArrayTitle.count), scrollV.h)
        return scrollV
        
    }()
    lazy var searchBar:CusSearchBar = {
    
        let searchB      = CusSearchBar.init(frame: CGRectMake(0, 0, kScreenWidth, 25))
        searchB.setShowsCancelButton(true, animated: true)
        searchB.delegate = self

        return searchB
    }()
    lazy var titleLabel:UILabel = {
    
        let titleL       = UILabel.init(frame: CGRectMake(12, 14, 200, 16))
        titleL.textColor = RGBCOLOR(0, g: 104, b: 248)
        titleL.font      = SYSTEMFONT(14)
        return titleL
    }()
    lazy var segmentControl:LXDSegmentControl = {
    
        let config                           = LXDSegmentControlConfiguration.init(controlType: LXDSegmentControlTypeSlideBlock, items: segmentArrayTitle)
        config.itemSelectedColor             = UIColor.clearColor()
        config.backgroundColor               = UIColor.whiteColor()
        let segmentControl:LXDSegmentControl = LXDSegmentControl.init(frame: CGRectMake(0, 0, kScreenWidth, kSegmentHight), configuration: config, delegate: nil)
        segmentControl.addSubLayerWithFrame(CGRectMake(0, CGRectGetMinY(segmentControl.frame) + 1, CGRectGetWidth(segmentControl.frame), 1), color: RGBCOLORV(0xdddddd).CGColor)
        segmentControl.addSubLayerWithFrame(CGRectMake(0, CGRectGetMaxY(segmentControl.frame) - 1, CGRectGetWidth(segmentControl.frame), 1), color: RGBCOLORV(0xdddddd).CGColor)
        segmentControl.delegate              = self

        return segmentControl
    
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor                            = UIColor.whiteColor()
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
        edgesForExtendedLayout                          = UIRectEdge.None
        navigationController?.navigationBar.translucent = true
        //        scrollToPage(0)
        let segmentItem = view.viewWithTag(10000) as! UIButton
        self.segmentControl.clickSegmentItem(segmentItem)
    }
    
    // MARK:控制器生命周期
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hiddenNavBottomLine()

        navigationController?.setBackgroundImage(UIImage.init(named: "search_navigationbar_background")!)

        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        hiddenKeyBoard()
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func hiddenKeyBoard() -> Void {
        searchBar.resignFirstResponder()
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
    
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}


// MARK: -- LXDSegmentControlDelegate
extension SearchMainViewController{

    func segmentControl(segmentControl: LXDSegmentControl!, didSelectAtIndex index: UInt) {
        
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

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
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
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
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
    
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        if searchBar.text?.length == 0 {
            return
        }
        
        if currentPage == 0 {
            if (searchMindResult.searchHistories.containsObject(searchBar.text!)) {
                searchMindResult.searchHistories.removeObject(searchBar.text!)
                
            }
            // 保存搜索记录，最多10条
            searchMindResult.searchHistories.insertObject(searchBar.text!, atIndex: 0)
            if searchMindResult.searchHistories.count > SearchHistoriesNum.kMostNumber.rawValue {
                searchMindResult.searchHistories.removeLastObject()
            }
            
            Defaults[kMindSearchHistory] = searchMindResult.searchHistories
            Defaults.synchronize()
            
            // 开始搜索
            searchMindResult.getQuestionList(nil)
        }
        else{
            
            if (searchArticleRes.searchHistories.containsObject(searchBar.text!)) {
                searchArticleRes.searchHistories.removeObject(searchBar.text!)
                
            }
            
            // 保存搜索记录，最多10条
            searchArticleRes.searchHistories.insertObject(searchBar.text!, atIndex: 0)
            if searchArticleRes.searchHistories.count > SearchHistoriesNum.kMostNumber.rawValue {
                searchArticleRes.searchHistories.removeLastObject()
            }
            
            Defaults[kArticleSearchHistory] = searchArticleRes.searchHistories
            Defaults.synchronize()
            
            // 开始搜索
            searchArticleRes.getQuestionList(nil)
        }
        
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        // 使用异步，防止点击取消按钮和键盘退出动画时间的冲突
        dispatch_async(dispatch_get_main_queue()) { 
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
    }
    
}

// MARK: scrollerViewDelegate method
extension SearchMainViewController{
    
    
        func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
            if currentPage == (NSInteger)(scrollView.contentOffset.x / kScreenWidth) {
                return
            }
            else{
    
                let page = (NSInteger)(scrollView.contentOffset.x / kScreenWidth)
                setSegmentViewBtnWithPage(page)
                currentPage = page
    
            }
        }
    
        func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
            if scrollView.className == "UIScrollView" {
                if currentPage == (NSInteger)(scrollView.contentOffset.x / kScreenWidth) {
                    return
                }
                else{
    
                    UIView.animateWithDuration(0.5, animations: {
                        [weak self] in
                        let page = (NSInteger)(scrollView.contentOffset.x / kScreenWidth)
                        self!.setSegmentViewBtnWithPage(page)
                        self!.currentPage = page
                        })
    
                }
            }
    
        }
    
    
        func setSegmentViewBtnWithPage(page:NSInteger) -> Void {
            if currentPage == page {
                return
            }else{
    
                self.segmentControl.clickSegmentItem(view.viewWithTag(10000 + page) as! UIButton)
            }
        }
    
        func scrollViewAddView(view:UIView, index:Int) -> Void {
            let rect = self.scrollView.bounds
            view.frame = CGRectMake(CGFloat(index) * CGRectGetWidth(rect) , 0, CGRectGetWidth(rect), CGRectGetHeight(rect) )
            self.scrollView.addSubview(view)
    
        }
    
        func scrollToPage(page:NSInteger) -> Void {
            self.scrollView.scrollRectToVisible(CGRectMake(CGFloat(page) * kScreenWidth, self.scrollView.contentOffset.y, self.scrollView.w, self.scrollView.h), animated: true)
            
        }
    
}
