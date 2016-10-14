//
//  ArticleListViewController.swift
//  Spider
//
//  Created by ooatuoo on 16/7/7.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import RealmSwift

private let articlePicsCellID  = "ArticlePicsCell"
private let articleAudioCellID = "ArticleAudioCell"
private let articleTextCellID  = "ArticleTextCell"
private let articleTitleCellID = "ArticleTitleCell"

private var myContext = 0

class ArticleListViewController: UIViewController {
    
    private var articleName: String = ""
    
    private var sections: Results<SectionObject>!
    
    private var sectionItems = [SectionObject]()
    
    private var notificationToken: NotificationToken?
    
    private var toShowIndexPath: NSIndexPath?
    
    private var originIndex: Int = 0
    
    // undoc box
    private var dragInSectionID = ""
    private var dragCancelled = false
    private var unboxDragging = false
    private var dragInSection: SectionObject?
    private var undocGes: UILongPressGestureRecognizer!
    private var cellSnapView: UnBoxToArticleSnapView?
    
    // editing
    private var beEditing = false
    private var hasMoved = false
    private var outlineShowed = false
    private var catchedView: UIImageView!
    private var movingIndexPath: NSIndexPath?
    private var displayLink: CADisplayLink?
    private var scrollSpeed = CGFloat(0)
    private var longPressGes: UILongPressGestureRecognizer!
    private var isFirstMove = false
    private var hasChoosedAll = false
    
    private var chooseCount = 0 {
        didSet {
            bottomBar.choosedCount = chooseCount
        }
    }
    
    // common view
    
    private var statusBar: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, w: kScreenWidth, h: kStatusBarHeight))
        view.backgroundColor = SpiderConfig.Color.BackgroundDark
        return view
    }()
    
    private lazy var unboxView = ArticleUndocBoxView()
    
    private lazy var toolBar: ArticleBottomBar = {
        let bar = ArticleBottomBar()
        bar.backHandler = { [weak self] in
            self?.navigationController?.popViewControllerAnimated(true)
        }
        
        bar.unchiveHandler = { [weak self] in
            self?.pushUnchiveView()
        }
        
        return bar
    }()
    
    private lazy var bottomBar: EditMindBottomBar = {
        let bar = EditMindBottomBar()
        bar.deleteHandler = { [weak self] in
            self?.deleteChoosedSections()
        }
        
        bar.moveHandler = { [weak self] in
            self?.moveInOutline()
        }
        return bar
    }()
    
    private lazy var topBar: EditMindTopBar = {
        let bar = EditMindTopBar(title: self.articleName)
        bar.doneHandler = { [weak self] in
            self?.changeModel()
        }
        
        bar.chooseAllHandler = { [weak self] in
            self?.choosedAllSections()
        }
        return bar
    }()
    
    private lazy var addSectoinButton: UIButton? = {
        let button = UIButton()
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        button.setImage(UIImage(named: "article_add_button"), forState: .Normal)
        button.addTarget(self, action: #selector(addSectionClicked), forControlEvents: .TouchUpInside)
        return button
    }()

    private lazy var toUndocView = MoveMindUpView(toUndoc: true)
    
    private lazy var tableView = ArticleListTableView()
    
    private lazy var addSectionIndicator: UIImageView? = {
        return UIImageView(image: UIImage(named: "article_nil_background"))
    }()
    
    private lazy var addSectionView = AddMediaView(unDoc: false)
    
    private var layoutPool = LayoutPool()
    
    // MARK: - Life Cycle
    convenience init(id: String) {
        self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let article = SpiderConfig.ArticleList.article else { return }
        articleName = article.name
        
        sections = article.sections.filter("deleteFlag == 0")
        sectionItems.appendContentsOf(sections)

        notificationToken = sections.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let tableView = self?.tableView, sSelf = self else { return }
            
            switch changes {
                
            case .Initial:
                break
                
            case .Update(let results, let delete, let insert, let modifications):
                
                if !delete.isEmpty && sSelf.outlineShowed {   // disappear to outlineVC
                    sSelf.hasMoved = true
                }
                
                if !insert.isEmpty && delete.isEmpty && modifications.isEmpty {
                    
                    guard let index = insert.first else { return }
                    
                    let section = results[index], indexPath = NSIndexPath(forRow: index, inSection: 1)
                    
                    if section.id != sSelf.dragInSectionID {
                        sSelf.sectionItems.insert(section, atIndex: index)
                        
                        if section.type == 0 {  // TextSection
                            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        } else {
                            sSelf.toShowIndexPath = indexPath
                        }
                    }
                }
                
                if !sSelf.sections.isEmpty {
                    sSelf.addSectionIndicator?.removeFromSuperview()
                    sSelf.addSectoinButton?.removeFromSuperview()
                }
                
                guard let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? ArticleTitleCell else {
                    return
                }

                cell.sectionCountLabel.text = "\(results.count)个段落"
                
            case .Error(let error):
                print(error)
            }
        }
        
        SpiderPlayer.sharedManager.addObserver(self, forKeyPath: "changed", options: .Old, context: &myContext)
        
        longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        tableView.addGestureRecognizer(longPressGes)
        
        tableView.registerClass(ArticlePicsCell.self, forCellReuseIdentifier: articlePicsCellID)
        tableView.registerClass(ArticleTextCell.self, forCellReuseIdentifier: articleTextCellID)
        tableView.registerClass(ArticleAudioCell.self, forCellReuseIdentifier: articleAudioCellID)
        tableView.registerClass(ArticleTitleCell.self, forCellReuseIdentifier: articleTitleCellID)
        
        makeUI()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context == &myContext {
            if let key = keyPath where key == "changed" {
                guard let _ = toShowIndexPath else {    // 如有新增段落，跳过updateUI
                    dispatch_async(dispatch_get_main_queue(), {
                        let lastID = SpiderPlayer.sharedManager.lastID
                        let time = SpiderPlayer.sharedManager.lastPlayedTime
                        
                        self.layoutPool.sectionLayoutHash[lastID]?.playedTime = time
                        self.tableView.reloadData()  // TODO: - just reload related items
                    })
                    
                    return
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        UIApplication.sharedApplication().setStatusBarStyle(beEditing ? .Default : .LightContent, animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let indexPath = toShowIndexPath {    // 新建图片、音频段落
            toShowIndexPath = nil
            tableView.beginUpdates()
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
        
        if hasMoved {       // 通过大纲移动
            hasMoved = false
            outlineShowed = false
            deleteChoosedSections(doInRealm: false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParentViewController() {
            notificationToken?.stop()
            
            SpiderPlayer.sharedManager.removeObserver(self, forKeyPath: "changed", context: &myContext)
            SpiderPlayer.sharedManager.reset()
            
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
            
            SpiderConfig.ArticleList.reset()
            
            println(" ArticleListViewController: release RealmToken, reset SpiderPlayer & ArticleList")
        }
    }

    private func makeUI() {
        view.backgroundColor = UIColor.whiteColor()
        tableView.delegate        = self
        tableView.dataSource      = self
        
        view.addSubview(statusBar)
        view.addSubview(toolBar)
        view.addSubview(tableView)
        
        tableView.snp_makeConstraints { (make) in
            tableView.edgesContraint = make.edges.equalTo(view).inset(UIEdgeInsetsMake(kStatusBarHeight, 0, 44, 0)).constraint
        }
        
        if sections.isEmpty {
            view.addSubview(addSectoinButton!)
            view.addSubview(addSectionIndicator!)
            
            addSectionIndicator!.snp_makeConstraints(closure: { (make) in
                make.size.equalTo(CGSize(width: 150, height: 245))
                make.center.equalTo(view)
            })
            
            addSectoinButton!.snp_makeConstraints(closure: { (make) in
                make.size.equalTo(40)
                make.centerX.equalTo(view)
                make.top.equalTo(addSectionIndicator!.snp_bottom)
            })
        }
    }
    
    func pushUnchiveView() {
        unboxView.articleDelegate = self
        navigationController?.fd_fullscreenPopGestureRecognizer.enabled = false
        unboxView.moveTo(view)
    }
    
    func addSectionClicked() {
        addSectionView.addTo(view)
    }
}

// MARK: - Move & Edit
extension ArticleListViewController {
    
    func didLongPress(ges: UILongPressGestureRecognizer) {
        var location = ges.locationInView(tableView)
        
        switch ges.state {
            
        case .Began:
            
            guard let indexPath = tableView.indexPathForRowAtPoint(location) where indexPath.section != 0 else { return }
            
            toUndocView.moveToView(tableView)
            
            if !beEditing {
                changeModel()
            }
            
            if let moveCell = tableView.cellForRowAtIndexPath(indexPath) {
                
                catchedView = moveCell.getSnapshotImageView()
                tableView.addSubview(catchedView)
                
                movingIndexPath = indexPath
                originIndex = indexPath.item
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
                if isFirstMove {
                    isFirstMove = false
                    location = CGPoint(x: location.x, y: location.y - kArticleCellBottomOffset - 20)
                }
                
                catchedView.animateMoveTo(point: location, withScalor: 0.7)
                
            } else {
                
                changeModel()
            }

        case .Changed:
            
            moveCatchedViewToLocation(location)

            scrollSpeed = 0.0
            
            if tableView.contentSize.height > tableView.frame.height {
                
                let halfCellHeight = 0.5 * catchedView.frame.height
                let cellCenterY = catchedView.center.y - tableView.bounds.origin.y
                
                if cellCenterY < halfCellHeight {
                    
                    scrollSpeed = 8.0*(cellCenterY/halfCellHeight - 1.1)
                }
                    
                else if cellCenterY > tableView.frame.height - halfCellHeight {
                    
                    scrollSpeed = 8.0*((cellCenterY - tableView.frame.height)/halfCellHeight + 1.1)
                }
                
                displayLink?.paused = scrollSpeed == 0.0
            }
            
        default:
            
            guard let choosedIndexPath = movingIndexPath else { return }
            
            if toUndocView.isHighlight {    // 移入碎片盒
                
                SpiderRealm.unchiveSection(sectionItems[choosedIndexPath.item])
                
                movingIndexPath = nil

                UIView.move(catchedView, toPoint: toUndocView.center, withScalor: 40 / catchedView.frame.width, completion: { [weak self] done in
                    self?.toUndocView.removeFromSuperview()
                    self?.tableView.beginUpdates()
                    self!.sectionItems.removeAtIndex(choosedIndexPath.item)
                    self?.tableView.deleteRowsAtIndexPaths([choosedIndexPath], withRowAnimation: .None)
                    self?.tableView.endUpdates()
                })
                
            } else {
                
                if choosedIndexPath.item > originIndex {
                    SpiderRealm.move(sectionItems[choosedIndexPath.item], to: sectionItems[choosedIndexPath.item - 1])
                } else if choosedIndexPath.item < originIndex {
                    SpiderRealm.move(sectionItems[choosedIndexPath.item], to: sectionItems[choosedIndexPath.item + 1])
                }
                
                movingIndexPath = nil
                
                catchedView.removeFromSuperview()
                toUndocView.removeFromSuperview()
                tableView.reloadRowsAtIndexPaths([choosedIndexPath], withRowAnimation: .None)
            }
        
            displayLink?.paused = true
            
            break
        }
    }
    
    func moveCatchedViewToLocation(location: CGPoint) {
        let y = min(max(location.y, tableView.bounds.origin.y), tableView.bounds.origin.y + tableView.bounds.height)
        catchedView.center = CGPoint(x: location.x, y: y)
        
        if toUndocView.frame.contains(catchedView.center) {
            toUndocView.isHighlight = true
        } else {
            toUndocView.isHighlight = false
        }
        
        guard let newIndexPath = tableView.indexPathForRowAtPoint(catchedView.center),
                  currentIndexPath = movingIndexPath where newIndexPath != currentIndexPath
        else { return }
        
        guard let cell = tableView.cellForRowAtIndexPath(newIndexPath) else { return }
        
        if newIndexPath.item < currentIndexPath.item {
            if catchedView.center.y < cell.frame.origin.y + 30 {
                moveSection(at: currentIndexPath, to: newIndexPath)
            }
        } else {
            if catchedView.center.y > cell.frame.maxY - 30 {
                moveSection(at: currentIndexPath, to: newIndexPath)
            }
        }
    }
    
    func moveSection(at aIndexP: NSIndexPath, to bIndexP: NSIndexPath) {
        
        if bIndexP.section == 1 {
            
            if dragCancelled {
                
                dragCancelled = false
                
                if let section = dragInSection {
                    
                    movingIndexPath = bIndexP
                    sectionItems.insert(section, atIndex: bIndexP.item)
                    tableView.insertRowsAtIndexPaths([bIndexP], withRowAnimation: .Fade)
                }
                
            } else {
                
                swap(&sectionItems[aIndexP.item], &sectionItems[bIndexP.item])
                
                movingIndexPath = bIndexP
                tableView.moveRowAtIndexPath(aIndexP, toIndexPath: bIndexP)
            }
        
        } else {
            
            if unboxDragging && !dragCancelled {
                dragCancelled = true
                movingIndexPath = bIndexP
                sectionItems.removeAtIndex(aIndexP.item)
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([aIndexP], withRowAnimation: .Top)
                tableView.endUpdates()
            }
        }
    }
    
    func changeModel() {
        
        if beEditing {
            
            beEditing = false
            isFirstMove = false
            displayLink?.invalidate()
            tableView.beEditing = false
            
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
            navigationController?.fd_fullscreenPopGestureRecognizer.enabled = true
            
            view.backgroundColor = UIColor.whiteColor()
            toolBar.hidden = false
            chooseCount = 0
            layoutPool.chooseAllItem(false)
            bottomBar.removeFromSuperview()
            
            tableView.reloadData()
            
        } else {
            
            beEditing = true
            isFirstMove = true
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
            navigationController?.fd_fullscreenPopGestureRecognizer.enabled = false
            
            view.backgroundColor = SpiderConfig.Color.EditTheme
            
            tableView.beEditing = true
            tableView.reloadData()
            
            toolBar.hidden = true
            topBar.addToView(view)
            bottomBar.addToView(view)
            
            displayLink = CADisplayLink(target: self, selector: #selector(scrollEvent))
            displayLink?.addToRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            displayLink?.paused = true
        }
    }
    
    func scrollEvent() {
        tableView.contentOffset.y = min(max(0.0, tableView.contentOffset.y + scrollSpeed), tableView.contentSize.height - tableView.frame.height)
        
        toUndocView.center.y = tableView.contentOffset.y + kScreenHeight / 2 - 60
        
        moveCatchedViewToLocation(longPressGes.locationInView(tableView))
    }
    
    func choosedAllSections() {
        hasChoosedAll = !hasChoosedAll
        
        layoutPool.chooseAllItem(hasChoosedAll)
        tableView.reloadData()
        
        chooseCount = hasChoosedAll ? sectionItems.count : 0
    }
    
    func deleteChoosedSections(doInRealm doInRealm: Bool = true) {
        guard let article = SpiderConfig.ArticleList.article else { return }
        
        let ids = layoutPool.deleteChoosed()
        var sections = [SectionObject]()

        for id in ids {
            
            guard let index = sectionItems.indexOf({ $0.id == id }) else { return }
            
            sections.append(sectionItems[index])

            sectionItems.removeAtIndex(index)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 1)], withRowAnimation: .Top)
            tableView.endUpdates()
        }
        
        if doInRealm { SpiderRealm.removeSections(sections, in: article) }
        chooseCount = 0
    }
    
    func moveInOutline() {
        outlineShowed = true
        presentViewController(OutlineViewController(state: .MoveSection, toMoveItems: layoutPool.choosedItems()), animated: true, completion: nil)
    }
}

// MARK: - ArticleUndocBoxDelegate

extension ArticleListViewController: ArticleUndocBoxDelegate {
    
    func didBeginToDragSeciton(section: SectionObject, layout: UndocBoxLayout, ges: UILongPressGestureRecognizer) {

        if let snapView = UnBoxToArticleSnapView(info: layout) {
            
            displayLink = CADisplayLink(target: self, selector: #selector(undocScrollEvent))
            displayLink?.addToRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            displayLink?.paused = true
            unboxDragging = true
            dragInSection = section
            
            let point = ges.locationInView(tableView)
            undocGes = ges

            cellSnapView = snapView
            snapView.center = point
            tableView.addSubview(snapView)
            
            guard let indexPath = tableView.indexPathForRowAtPoint(point) where indexPath.section != 0 else { return }
            
            movingIndexPath = indexPath
            originIndex = indexPath.item
            sectionItems.insert(section, atIndex: indexPath.item)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
    }
    
    func didChange(ges: UILongPressGestureRecognizer) {
        
        if let snapView = cellSnapView {
            
            let loc = undocGes.locationInView(tableView)
            moveUndocItemToLocation(loc)
            
            if tableView.contentSize.height > tableView.frame.height {
                
                let halfCellHeight = 0.5 * snapView.frame.height
                let cellCenterY = snapView.center.y - tableView.bounds.origin.y
                
                if cellCenterY < halfCellHeight {
                    
                    scrollSpeed = 6.0 * (cellCenterY / halfCellHeight - 1.0)
                    
                } else if cellCenterY > tableView.frame.height - halfCellHeight {
                    
                    scrollSpeed = 6.0 * ((cellCenterY - tableView.frame.height) / halfCellHeight + 1.0)
                    
                } else {
                    
                    scrollSpeed = 0
                }
                
                displayLink?.paused = scrollSpeed == 0.0
            }
        }
    }
    
    func didEndDrag(location: CGPoint) {
        unboxView.articleDelegate = nil
        unboxView.removeFromSuperview()
        cellSnapView?.removeFromSuperview()
        
        displayLink?.invalidate()
        undocGes = nil
        navigationController?.fd_fullscreenPopGestureRecognizer.enabled = true
        
        if let choosedIndexPath = movingIndexPath, undocSection = dragInSection {
            
            if choosedIndexPath.section == 1 {
                
                if sectionItems.count == 1 {
                    SpiderRealm.insertUndocSection(undocSection)
                } else {
                    if choosedIndexPath.item + 1 == sectionItems.count {
                        SpiderRealm.insertUndocSection(undocSection)
                    } else if choosedIndexPath.item == 0 {
                        SpiderRealm.insertUndocSection(undocSection, to: 0)
                    } else {
                        SpiderRealm.insertUndocSection(undocSection, before: sectionItems[choosedIndexPath.item + 1])
                    }
                }
   
                movingIndexPath = nil
                tableView.reloadRowsAtIndexPaths([choosedIndexPath], withRowAnimation: .None)
            }
            
            dragInSectionID = undocSection.id
        }
        
        dragInSection = nil
        dragCancelled = false
        unboxDragging = false
    }
    
    func didQuitUndocBox() {
        navigationController?.fd_fullscreenPopGestureRecognizer.enabled = true
    }
    
    func moveUndocItemToLocation(location: CGPoint) {
        let y = min(max(location.y, tableView.bounds.origin.y), tableView.bounds.origin.y + tableView.bounds.height)
        cellSnapView?.center = CGPoint(x: location.x, y: y)
        
        guard let newIndexPath = tableView.indexPathForRowAtPoint(location),
            currentIndexPath = movingIndexPath where newIndexPath != currentIndexPath
            else { return }
        
        guard let cell = tableView.cellForRowAtIndexPath(newIndexPath) else { return }
        
        if newIndexPath.item < currentIndexPath.item {
            if cellSnapView!.center.y < cell.frame.origin.y + 30 {
                moveSection(at: currentIndexPath, to: newIndexPath)
            }
        } else {
            if cellSnapView!.center.y > cell.frame.maxY - 30 {
                moveSection(at: currentIndexPath, to: newIndexPath)
            }
        }
    }
    
    func undocScrollEvent() {
        tableView.contentOffset.y = min(max(0.0, tableView.contentOffset.y + scrollSpeed), tableView.contentSize.height - tableView.frame.height)
        moveUndocItemToLocation(undocGes.locationInView(tableView))
    }
}

// MARK: - TableView Delegate

extension ArticleListViewController: UITableViewDataSource, UITableViewDelegate {
    private enum Section: Int {
        case Title = 0
        case Content = 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        
        switch section {
            
        case .Title:
            return 1
            
        case .Content:
            return sectionItems.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        
        func cellForSection(section: SectionObject) -> UITableViewCell {
            
            let type = SectionType(rawValue: section.type)!
            
            switch type {
                
            case .Pic:
                let cell = tableView.dequeueReusableCellWithIdentifier(articlePicsCellID, forIndexPath: indexPath) as! ArticlePicsCell
                return cell
                
            case .Audio:
                let cell = tableView.dequeueReusableCellWithIdentifier(articleAudioCellID, forIndexPath: indexPath) as! ArticleAudioCell
                return cell
                
            case .Text:
                let cell = tableView.dequeueReusableCellWithIdentifier(articleTextCellID, forIndexPath: indexPath) as! ArticleTextCell
                return cell
            }
        }
        
        switch section {
            
        case .Title:
            
            return tableView.dequeueReusableCellWithIdentifier(articleTitleCellID, forIndexPath: indexPath) as! ArticleTitleCell
            
        case .Content:
            
            let sectionInfo = sectionItems[indexPath.item]
            return cellForSection(sectionInfo)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let section = Section(rawValue: indexPath.section),
                  cell = cell as? ArticleBaseCell else {
            return
        }
        
        cell.addSectionHandler = { [weak self] in
            
            if let indexPath = tableView.indexPathForCell(cell) {
                
                if indexPath.section == 0 {
                    SpiderConfig.ArticleList.insertIndex = 0
                } else {
                    guard let index = self?.sectionItems[indexPath.item].indexOfOwner else { return }
                    SpiderConfig.ArticleList.insertIndex = index + 1
                }
            }
        }
        
        func configureSectionCell(cell: UITableViewCell, withSection section: SectionObject) {
            
            var layout = layoutPool.cellLayoutOfSection(section)
            let type = SectionType(rawValue: section.type)!
            
            switch type {
                
            case .Text:
                
                guard let cell = cell as? ArticleTextCell else { return }
                
                cell.tapAction = { [weak self] in
                    
                    if self!.beEditing {
                        
                        self!.chooseCount += self!.layoutPool.updateSelectState(section) ? 1 : -1
                        tableView.reloadRowsAtIndexPaths([tableView.indexPathForCell(cell)!], withRowAnimation: .None)
                        
                    } else {

                        let editTextView = AddTextSectionView(text: section.text!)
                        
                        editTextView.doneHandler = { text in
                            try! REALM.realm.write({
                                section.text = text
                            })
                        }
                        
                        editTextView.moveTo(self!.view)
                    }
                }
                
                cell.configurationWithSection(section, layout: layout, editing: beEditing)
                
            case .Pic:
                
                guard let cell = cell as? ArticlePicsCell else { return }
                
                cell.tapAction = { [weak self] in
                    
                    guard let indexPath = tableView.indexPathForCell(cell) else { return }
                    
                    if self!.beEditing {
                        
                        self!.chooseCount += self!.layoutPool.updateSelectState(section) ? 1 : -1
                        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                        
                    } else {
                        
                        SpiderPlayer.sharedManager.player?.stop()
                        
                        let sectionInfo = self?.sectionItems[indexPath.item]
                        let picDetailVC = PicDetailViewController(picSection: sectionInfo)
                        self?.navigationController?.pushViewController(picDetailVC, animated: true)
                    }
                }
                    
                cell.congfigureWithSection(section, layout: layout, editing: beEditing)
                
            case .Audio:
                
                guard let cell = cell as? ArticleAudioCell else { return }
                layout = layoutPool.updatePlayedTimeOfSection(section)
                cell.congfigureWithSection(section, layout: layout, editing: beEditing)
            }
        }
        
        switch section {
            
        case .Title:
            
            guard let cell = cell as? ArticleTitleCell  else { return }
            cell.hidden = beEditing
            cell.configureTitleCell(articleName, sectionCount: sections.count)
            
        case .Content:
            
            if let movingIndexP = movingIndexPath where movingIndexP == indexPath {
                
                cell.hidden = true
                
            } else {
                
                let sectionInfo = sectionItems[indexPath.item]
                configureSectionCell(cell, withSection: sectionInfo)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else { return 0 }
        
        switch section {
            
        case .Title:
            return beEditing ? 0 : 80 + kArticleCellBottomOffset
            
        case .Content:
            let sectionInfo = sectionItems[indexPath.item]
            return layoutPool.heightOfSection(sectionInfo)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        if section != .Title {
            
            let sectionObject = sectionItems[indexPath.item]
            let type = SectionType(rawValue: sectionObject.type)!
            
            switch type {
            case .Audio:
                
                if beEditing {
                    
                    chooseCount += layoutPool.updateSelectState(sectionObject) ? 1 : -1
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    
                } else {
                    
                    if sectionObject.id != SpiderPlayer.sharedManager.playingID {
                        SpiderPlayer.sharedManager.player?.stop()
                    }
                    
                    let layout = layoutPool.cellLayoutOfSection(sectionObject)
                    
                    let vc = AudioSectionViewController(section: sectionObject, playedTime: layout.playedTime)
                    navigationController?.pushViewController(vc, animated: true)
                }
                
            default:
                break
            }
        }
    }
}
