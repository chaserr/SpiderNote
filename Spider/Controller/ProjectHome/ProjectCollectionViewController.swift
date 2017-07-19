//
//  ProjectCollectionViewController.swift
//  Spider
//
//  Created by Atuooo on 5/6/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit
import RealmSwift

private let cellID = "ProjectViewCell"
private let colors = [0x66bb6a, 0xffc107, 0xef5350]

class ProjectCollectionViewController: MainViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var projects = SpiderRealm.getProjects()
    
    fileprivate var searchNavContr: UINavigationController!
    
    fileprivate var searchBtn: UIButton!
    
    fileprivate var addMediaButton =  AddMediaButton()
    
    fileprivate var collectionView = ProjectCollectionView()
    
    fileprivate lazy var undocButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 40, y: 0, width: 40, height: 40))
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 0)
        button.setImage(UIImage(named: "unchiveBox_button"), for: UIControlState())
        
        button.addSubview(self.undocCountLabel)
        button.addTarget(self, action: #selector(unchiveItemClicked), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var userButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 20)
        button.setImage(UIImage(named: "user_project_button"), for: UIControlState())
        button.addTarget(self, action: #selector(UIViewController.toggleLeft), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var searchButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.setImage(UIImage(named: "search_button"), for: UIControlState())
        button.addTarget(self, action: #selector(searchItemClicked), for: .touchUpInside)
        return button
    }()
    
    lazy var undocCountLabel = UndocCountLabel()
    
    lazy var topV: TopHitView? = {
    
        let topView = TopHitView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kTopBarHeight))
        return topView
    }()

    fileprivate lazy var rightItemView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        view.addSubview(self.searchButton)
        view.addSubview(self.undocButton)
        return view
    }()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightItemView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: userButton)
    
        navigationTitleLabel.text = "蜘蛛笔记"
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProjectViewCell.self, forCellWithReuseIdentifier: cellID)
        
        view.addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            make.top.bottom.right.left.equalTo(view)
        }
        
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPress)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
        edgesForExtendedLayout = UIRectEdge()
        automaticallyAdjustsScrollViewInsets = true
        UIApplication.shared.setStatusBarStyle(.default, animated: false)

        hiddenNavBottomLine()
        
//        let closeWarnLoginTime         = APP_USER.closeWarnLoginTime
//        let saveTime: NSDate?          = DateUtil.stringToNSDate(closeWarnLoginTime, format: kDU_YYYYMMddhhmmss)
//        let currentDateS               = DateUtil.getCurrentDateStringWithFormat(kDU_YYYYMMddhhmmss)
//        let currentTime: NSDate        = DateUtil.stringToNSDate(currentDateS, format: kDU_YYYYMMddhhmmss)
//        //
//        var timeMargin: NSTimeInterval?
//        if saveTime == nil {
//            
//            timeMargin = 0
//            
//        } else {
//        
//            timeMargin = currentTime.timeIntervalSinceDate(saveTime!)
//            
//        }

        // 获取关闭提示的时间
//        if !APP_UTILITY.checkCurrentUser() && REALM.realm.objects(MindObject).toArray().count >= 20 && (timeMargin == 0 || timeMargin > 7*24*60*60){
//        view.addSubview(self.topV!)
//        if topV != nil {
//            collectionView.y = topV!.h
//            topV?.dismissHandler = {
//                UIView.animateWithDuration(0.5, animations: {
//                    self.collectionView.y = 0
//                    }, completion: { (Bool) in
//                        
//                })
//            }
//        }
//            
//        topV!.showTopMessage("你已经写满了20条笔记，赶快去登陆同步吧~", config: [kTopBarIcon: UIImage(named: "pic_cancel_button")!], delay: 0) {
//                AppNavigator.openLoginController()
//            }
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 更新未归档数量
        delay(0.3) { [weak self] in
            self?.undocCountLabel.count = SpiderRealm.getUndocItemCount()
        }
        
        AppNavigator.getInstance().mainNav!.view.addSubview(addMediaButton)
        
        // 只要到了根节点，所有的全局结构都清空
        SPIDERSTRUCT.currentMindPath = nil
        SPIDERSTRUCT.currentLevel = 0
        SPIDERSTRUCT.structLevel = 0
        SPIDERSTRUCT.allPushMindPath = [String]()
        SPIDERSTRUCT.currentMindPath = nil // 当前结构路径
        SPIDERSTRUCT.lastMind = nil
        SPIDERSTRUCT.selectLevelItem = nil
        SPIDERSTRUCT.sourceMindType = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addMediaButton.removeFromSuperview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    deinit {
        collectionView.delegate = nil
    }
    
    // MARK: - Gesture
    func didLongPress(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            
            let location = sender.location(in: collectionView)
            
            if let indexPath = collectionView.indexPathForItem(at: location), indexPath.item != 0 {
                
                let project = projects[indexPath.item - 1]
                let editAlert = EditProjectAlertView(name: project.name)
                
                editAlert.deleteHanlder = { [weak self] in
                    SpiderRealm.remove(project)
                    self?.collectionView.deleteItems(at: [indexPath])
//                    self.shareViewAlert()
                }
                
                editAlert.editHandler = { [weak self] text in
                    SpiderRealm.update(project, text: text)
                    self?.collectionView.reloadData()
                }
                
                view.window?.addSubview(editAlert)
            }
        }
    }
    
    func unchiveItemClicked() {
        if SpiderConfig.sharedInstance.project == nil {
            SpiderConfig.sharedInstance.project = projects.first
        }
        
        let unchiveVC = UndocBoxViewController()
        navigationController?.pushViewController(unchiveVC, animated: true)
    }
    
    func searchItemClicked() {
        
        let searchMainController = SearchMainViewController()
        searchMainController.searchType = SearchType.Project
        // 防止多次push
        if !(navigationController!.topViewController!.isKind(of: SearchMainViewController.self)) {
            navigationController?.pushViewController(searchMainController, animated: true)
        }
    }
}

// MARK: - Collection View Delegate
extension ProjectCollectionViewController {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return projects.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ProjectViewCell
        
        if indexPath.item == 0 {
            cell.isFirst = true
            
        } else {
            
            cell.textLabel.text = projects[indexPath.item - 1].name
            cell.color = colors[(projects.count - indexPath.item) % 3]
            cell.isFirst = false
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0 {
            
            let alert = AddProjectAlertView()
            
            alert.addProjectHandler = { [unowned self] (text: String) in
                
                SpiderRealm.update(text: text)
                self.collectionView.insertItems(at: [IndexPath(item: indexPath.item + 1, section: 0)])
            }
            
            view.window!.addSubview(alert)
            
        } else {
            
            SPIDERSTRUCT.sourceMindType = SourceMindControType.comeFromHome
            
            let project = projects[indexPath.item - 1]
            SpiderConfig.sharedInstance.project = project
            let vc = MindViewController(ownerProject: project)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
     func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension ProjectCollectionViewController {

    // 弹出分享菜单
    func shareViewAlert() -> Void {
        let shareVC = ShareVC(title: nil, detailInfo: nil, shareImage: nil, shareUrl: nil)
        self.addChildViewController(shareVC)
        view.addSubview(shareVC.view)
        shareVC.popShareView()
    }
}
