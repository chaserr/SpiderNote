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
    
    fileprivate var unDocItems = [[SectionObject]]()
    
    fileprivate var unDocResults = SpiderRealm.getUndocItems()
    
    fileprivate var notificationToken: NotificationToken?
    
    fileprivate var layoutPool = UndocBoxLayoutPool()
    
    fileprivate var toShowSection: SectionObject?
    
    fileprivate var showedMoreView = false
    
    fileprivate var moreIndexPath: IndexPath!
    
    // edit
    fileprivate var outlineShowed = false
    fileprivate var hasMoved = false
    fileprivate var beEditing = false
    fileprivate var hasChoosedAll = false
    
    fileprivate var choosedCount = 0 {
        didSet {
            bottomBar.choosedCount = choosedCount
        }
    }
    
    fileprivate lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, w: 40, h: 40))
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 14)
        button.setImage(UIImage(named: "unchive_back_button"), for: UIControlState())
        
        button.addTarget(self, action: #selector(backItemClicked), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var moreButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, w: 40, h: 40))
        button.imageEdgeInsets = UIEdgeInsets(top: 18, left: 15, bottom: 18, right: 0)
        button.setImage(UIImage(named: "unchive_more_button"), for: UIControlState())
        
        button.addTarget(self, action: #selector(moreItemClicked), for: .touchUpInside)
        return button
    }()
    
    var collectionView = UndocBoxCollectionView()
    
    fileprivate lazy var moreView = UndocBoxMoreView()
    
    fileprivate lazy var cellMoreView: UndocCellMoreView = {
        return UndocCellMoreView(handler: { [weak self] type in
            self?.cellMoreAction(type)
        })
    }()
    
    fileprivate lazy var bottomBar: EditMindBottomBar = {
        let bar = EditMindBottomBar()
        bar.deleteHandler = { [weak self] in
            self?.deleteChoosedSections()
        }
        
        bar.moveHandler = { [weak self] in
            self?.moveSections()
        }
        
        return bar
    }()
    
    fileprivate lazy var topBar: EditMindTopBar = {
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
            case .initial:
                break
                
            case .update(let _, let deletions, let insertions, let modifications):
                
                print(deletions, insertions, modifications)
                
                if sSelf.outlineShowed && !deletions.isEmpty {
                    sSelf.hasMoved = true
                }
                
                if !modifications.isEmpty || !insertions.isEmpty {
                    
                    sSelf.unDocItems = SpiderRealm.groupUndocItems(self!.unDocResults)
                    collectionView.reloadData()
                    
                    collectionView.setContentOffset(CGPoint.zero, animated: true)
                }

            case .error:
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
        collectionView.register(UndocTextCell.self, forCellWithReuseIdentifier: textCellID)
        collectionView.register(UndocPicCell.self, forCellWithReuseIdentifier: picCellID)
        collectionView.register(UndocAudioCell.self, forCellWithReuseIdentifier: audioCellID)
        collectionView.register(UndocHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headID)
        
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPress)))
        
        view.addSubview(collectionView)
        
        collectionView.snp_makeConstraints { (make) in
            collectionView.bottomConstraint = make.bottom.equalTo(view).constraint
            make.left.right.top.equalTo(view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.setStatusBarStyle(.default, animated: false)
        edgesForExtendedLayout = UIRectEdge()
        hiddenNavBottomLine()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showNavBottomLine()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if hasMoved {
            hasMoved = false
            outlineShowed = false
            
            if beEditing {
                deleteChoosedSections(doInRealm: false)
            } else {
                unDocItems[moreIndexPath.section].remove(at: moreIndexPath.item)
                collectionView.deleteItems(at: [moreIndexPath])
            }
        }
        
        if let section = toShowSection {
            toShowSection = nil
            
            let indexPath = SpiderRealm.indexPathOf(section, in: unDocItems)
            collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParentViewController {
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
        navigationController?.popViewController(animated: true)
    }
    
    func didLongPress(_ sender: UILongPressGestureRecognizer) {
        
        if !beEditing {
            
            let location = sender.location(in: collectionView)
            guard let indexPath = collectionView.indexPathForItem(at: location),
                let cell = collectionView.cellForItem(at: indexPath) else { return }
            
            moreIndexPath = indexPath
            cellMoreView.center = cell.center
            
            cellMoreView.isHidden = false
            
            if !cellMoreView.isDescendant(of: collectionView) {
                collectionView.addSubview(cellMoreView)
            }
        }
    }
    
    func cellMoreAction(_ type: UndocCellMoreType) {
        
        switch type {
            
        case .delete:
            
            SpiderRealm.removeSection(unDocItems[moreIndexPath.section][moreIndexPath.item])
            unDocItems[moreIndexPath.section].remove(at: moreIndexPath.item)
            collectionView.deleteItems(at: [moreIndexPath])
            
        case .more:
            
            changeModel()
            
        case .move:
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
            navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true

            choosedCount = 0
            layoutPool.chooseAllItem(false)

            collectionView.beEditing = false
            bottomBar.removeFromSuperview()
            
        } else {
            
            beEditing = true
            collectionView.beEditing = true
            navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
            
            topBar.addToView(navigationController!.view)
            bottomBar.addToView(view)
        }
        
        collectionView.reloadData()
    }
    
    func moveSections() {
        outlineShowed = true
        
        let moveItemIDs = beEditing ? layoutPool.chooseItemIDs() : [unDocItems[moreIndexPath.section][moreIndexPath.item].id]
        present(OutlineViewController(state: .MoveSection, toMoveItems: moveItemIDs), animated: true, completion: nil)
    }
    
    func deleteChoosedSections(doInRealm: Bool = true) {
        if doInRealm { SpiderRealm.removeSections(with: layoutPool.deleteChoosed()) }
        unDocItems = SpiderRealm.groupUndocItems(unDocResults)
        collectionView.reloadData()
        
        choosedCount = 0
    }
}

extension UndocBoxViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return unDocItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return unDocItems[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = SectionType(rawValue: unDocItems[indexPath.section][indexPath.item].type) else { return UICollectionViewCell() }
        
        switch type {
            
        case .text:
            return collectionView.dequeueReusableCell(withReuseIdentifier: textCellID, for: indexPath) as! UndocTextCell
        
        case .pic:
            return collectionView.dequeueReusableCell(withReuseIdentifier: picCellID, for: indexPath) as! UndocPicCell
            
        case .audio:
            return collectionView.dequeueReusableCell(withReuseIdentifier: audioCellID, for: indexPath) as! UndocAudioCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let undocItem = unDocItems[indexPath.section][indexPath.item]
        let layout  = layoutPool.cellLayoutOfSection(undocItem)
                
        guard let type = SectionType(rawValue: undocItem.type) else { return }
        
        switch type {
            
        case .text:
            guard let cell = cell as? UndocTextCell else { return }
            cell.configureWithInfo(layout, editing: beEditing)
            
        case .pic:
            guard let cell = cell as? UndocPicCell else { return }
            cell.configureWithInfo(layout, editing: beEditing)
    
        case .audio:
            guard let cell = cell as? UndocAudioCell else { return }
            cell.configureWithInfo(layout, editing: beEditing)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let undocItem = unDocItems[indexPath.section][indexPath.item]
        
        if beEditing {
            
            choosedCount += layoutPool.updateSelectState(undocItem) ? 1 : -1
            collectionView.reloadItems(at: [indexPath])
            
        } else {
            
            guard let type = SectionType(rawValue: undocItem.type) else { return }
            
            switch type {
                
            case .pic:
                let picVC = PicDetailViewController(picSection: undocItem)
                navigationController?.pushViewController(picVC, animated: true)
                
            case .audio:
                let audioVC = AudioSectionViewController(coder: undocItem)
                navigationController?.pushViewController(audioVC, animated: true)
                
            case .text:
                let textView = AddUndocTextView(object: undocItem)
                textView.moveTo(navigationController!.view)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headID, for: indexPath) as! UndocHeaderView
        
        if let time = unDocItems[indexPath.section].first?.updateAt {
            header.configureWith(time, beEditing: beEditing)
        }
        
        return header
    }
}
