//
//  UndocBoxViewController.swift
//  Spider
//
//  Created by ooatuoo on 16/8/16.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import RealmSwift

private let headID      = "UndocHeaderCell"
private let textCellID  = "UndocBoxTextCell"
private let picCellID   = "UndocBoxPicCell"
private let audioCellID = "UndocBoxAudioCell"

class UndocBoxViewController: UIViewController {
    
    private var unDocItems = [[SectionObject]]()
    
    private var unDocResults = SpiderRealm.getUndocItems()
    
    private var notificationToken: NotificationToken?
    
    private var layoutPool = UndocBoxLayoutPool()
    
    private var toShowSection: SectionObject?
    
    private var showedMoreView = false
    
    private var moreIndexPath: NSIndexPath!
    
    // edit
    private var outlineShowed = false
    private var hasMoved = false
    private var beEditing = false
    private var hasChoosedAll = false
    
    private var choosedCount = 0 {
        didSet {
            bottomBar.choosedCount = choosedCount
        }
    }
    
    private lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, w: 40, h: 40))
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 14)
        button.setImage(UIImage(named: "unchive_back_button"), forState: .Normal)
        
        button.addTarget(self, action: #selector(backItemClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, w: 40, h: 40))
        button.imageEdgeInsets = UIEdgeInsets(top: 18, left: 15, bottom: 18, right: 0)
        button.setImage(UIImage(named: "unchive_more_button"), forState: .Normal)
        
        button.addTarget(self, action: #selector(moreItemClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    var collectionView = UndocBoxCollectionView()
    
    private lazy var moreView = UndocBoxMoreView()
    
    private lazy var cellMoreView: UndocCellMoreView = {
        return UndocCellMoreView(handler: { [weak self] type in
            self?.cellMoreAction(type)
        })
    }()
    
    private lazy var bottomBar: EditMindBottomBar = {
        let bar = EditMindBottomBar()
        bar.deleteHandler = { [weak self] in
            self?.deleteChoosedSections()
        }
        
        bar.moveHandler = { [weak self] in
            self?.moveSections()
        }
        
        return bar
    }()
    
    private lazy var topBar: EditMindTopBar = {
        let bar = EditMindTopBar(title: "碎片盒")
        
        bar.doneHandler = { [weak self] in
            self?.changeModel()
        }
        
        bar.chooseAllHandler = { [weak self] in
            self?.choosedAllSections()
        }
        
        return bar
    }()
    
    init(toShowSection: SectionObject? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.toShowSection = toShowSection
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationToken = unDocResults.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let collectionView = self?.collectionView, let sSelf = self else { return }
            
            switch changes {
            case .Initial:
                break
                
            case .Update(let _, let deletions, let insertions, let modifications):
                
                print(deletions, insertions, modifications)
                
                if sSelf.outlineShowed && !deletions.isEmpty {
                    sSelf.hasMoved = true
                }
                
                if !modifications.isEmpty || !insertions.isEmpty {
                    
                    sSelf.unDocItems = SpiderRealm.groupUndocItems(self!.unDocResults)
                    collectionView.reloadData()
                    
                    collectionView.setContentOffset(CGPointZero, animated: true)
                }

            case .Error:
                println("error")
                break
            }
        }
        
        unDocItems = SpiderRealm.groupUndocItems(unDocResults)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.titleView = NavigationItemTitleView(title: "碎片盒")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(UndocTextCell.self, forCellWithReuseIdentifier: textCellID)
        collectionView.registerClass(UndocPicCell.self, forCellWithReuseIdentifier: picCellID)
        collectionView.registerClass(UndocAudioCell.self, forCellWithReuseIdentifier: audioCellID)
        collectionView.registerClass(UndocHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headID)
        
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPress)))
        
        view.addSubview(collectionView)
        
        collectionView.snp_makeConstraints { (make) in
            collectionView.bottomConstraint = make.bottom.equalTo(view).constraint
            make.left.right.top.equalTo(view)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
        edgesForExtendedLayout = .None
        hiddenNavBottomLine()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        showNavBottomLine()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if hasMoved {
            hasMoved = false
            outlineShowed = false
            
            if beEditing {
                deleteChoosedSections(doInRealm: false)
            } else {
                unDocItems[moreIndexPath.section].removeAtIndex(moreIndexPath.item)
                collectionView.deleteItemsAtIndexPaths([moreIndexPath])
            }
        }
        
        if let section = toShowSection {
            toShowSection = nil
            
            let indexPath = SpiderRealm.indexPathOf(section, in: unDocItems)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParentViewController() {
            notificationToken?.stop()
            println(" UndocBoxViewController: realse RealmToken ")
        }
    }

    // MARK: - Actions
    func moreItemClicked() {
        cellMoreView.removeFromSuperview()
        
        navigationController?.view.addSubview(moreView)
    }
    
    func backItemClicked() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func didLongPress(sender: UILongPressGestureRecognizer) {
        
        if !beEditing {
            
            let location = sender.locationInView(collectionView)
            guard let indexPath = collectionView.indexPathForItemAtPoint(location),
                cell = collectionView.cellForItemAtIndexPath(indexPath) else { return }
            
            moreIndexPath = indexPath
            cellMoreView.center = cell.center
            
            cellMoreView.hidden = false
            
            if !cellMoreView.isDescendantOfView(collectionView) {
                collectionView.addSubview(cellMoreView)
            }
        }
    }
    
    func cellMoreAction(type: UndocCellMoreType) {
        
        switch type {
            
        case .Delete:
            
            SpiderRealm.removeSection(unDocItems[moreIndexPath.section][moreIndexPath.item])
            unDocItems[moreIndexPath.section].removeAtIndex(moreIndexPath.item)
            collectionView.deleteItemsAtIndexPaths([moreIndexPath])
            
        case .More:
            
            changeModel()
            
        case .Move:
            moveSections()
        }
    }
    
    func choosedAllSections() {
        hasChoosedAll = !hasChoosedAll
        
        layoutPool.chooseAllItem(hasChoosedAll)
        collectionView.reloadData()
        
        choosedCount = hasChoosedAll ? unDocResults.count : 0
    }
    
    func changeModel() {
        
        if beEditing {
            
            beEditing = false
            navigationController?.fd_fullscreenPopGestureRecognizer.enabled = true

            choosedCount = 0
            layoutPool.chooseAllItem(false)

            collectionView.beEditing = false
            bottomBar.removeFromSuperview()
            
        } else {
            
            beEditing = true
            collectionView.beEditing = true
            navigationController?.fd_fullscreenPopGestureRecognizer.enabled = false
            
            topBar.addToView(navigationController!.view)
            bottomBar.addToView(view)
        }
        
        collectionView.reloadData()
    }
    
    func moveSections() {
        outlineShowed = true
        
        var moveItemIDs = beEditing ? layoutPool.chooseItemIDs() : [unDocItems[moreIndexPath.section][moreIndexPath.item].id]
        presentViewController(OutlineViewController(state: .MoveSection, toMoveItems: moveItemIDs), animated: true, completion: nil)
    }
    
    func deleteChoosedSections(doInRealm doInRealm: Bool = true) {
        if doInRealm { SpiderRealm.removeSections(with: layoutPool.deleteChoosed()) }
        unDocItems = SpiderRealm.groupUndocItems(unDocResults)
        collectionView.reloadData()
        
        choosedCount = 0
    }
}

extension UndocBoxViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return unDocItems.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return unDocItems[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let type = SectionType(rawValue: unDocItems[indexPath.section][indexPath.item].type) else { return UICollectionViewCell() }
        
        switch type {
            
        case .Text:
            return collectionView.dequeueReusableCellWithReuseIdentifier(textCellID, forIndexPath: indexPath) as! UndocTextCell
        
        case .Pic:
            return collectionView.dequeueReusableCellWithReuseIdentifier(picCellID, forIndexPath: indexPath) as! UndocPicCell
            
        case .Audio:
            return collectionView.dequeueReusableCellWithReuseIdentifier(audioCellID, forIndexPath: indexPath) as! UndocAudioCell
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let undocItem = unDocItems[indexPath.section][indexPath.item]
        let layout  = layoutPool.cellLayoutOfSection(undocItem)
                
        guard let type = SectionType(rawValue: undocItem.type) else { return }
        
        switch type {
            
        case .Text:
            guard let cell = cell as? UndocTextCell else { return }
            cell.configureWithInfo(layout, editing: beEditing)
            
        case .Pic:
            guard let cell = cell as? UndocPicCell else { return }
            cell.configureWithInfo(layout, editing: beEditing)
    
        case .Audio:
            guard let cell = cell as? UndocAudioCell else { return }
            cell.configureWithInfo(layout, editing: beEditing)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let undocItem = unDocItems[indexPath.section][indexPath.item]
        
        if beEditing {
            
            choosedCount += layoutPool.updateSelectState(undocItem) ? 1 : -1
            collectionView.reloadItemsAtIndexPaths([indexPath])
            
        } else {
            
            guard let type = SectionType(rawValue: undocItem.type) else { return }
            
            switch type {
                
            case .Pic:
                let picVC = PicDetailViewController(picSection: undocItem)
                navigationController?.pushViewController(picVC, animated: true)
                
            case .Audio:
                let audioVC = AudioSectionViewController(section: undocItem)
                navigationController?.pushViewController(audioVC, animated: true)
                
            case .Text:
                let textView = AddUndocTextView(object: undocItem)
                textView.moveTo(navigationController!.view)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: headID, forIndexPath: indexPath) as! UndocHeaderView
        
        if let time = unDocItems[indexPath.section].first?.updateAt {
            header.configureWith(time, beEditing: beEditing)
        }
        
        return header
    }
}
