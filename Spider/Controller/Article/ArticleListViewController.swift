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
    
    fileprivate var articleName: String = ""
    
    fileprivate var sections: Results<SectionObject>!
    
    fileprivate var sectionItems = [SectionObject]()
    
    fileprivate var notificationToken: NotificationToken?
    
    fileprivate var toShowIndexPath: IndexPath?
    
    fileprivate var originIndex: Int = 0
    
    // undoc box
    fileprivate var dragInSectionID = ""
    fileprivate var dragCancelled = false
    fileprivate var unboxDragging = false
    fileprivate var dragInSection: SectionObject?
    fileprivate var undocGes: UILongPressGestureRecognizer!
    fileprivate var cellSnapView: UnBoxToArticleSnapView?
    
    // editing
    fileprivate var beEditing = false
    fileprivate var hasMoved = false
    fileprivate var outlineShowed = false
    fileprivate var catchedView: UIImageView!
    fileprivate var movingIndexPath: IndexPath?
    fileprivate var displayLink: CADisplayLink?
    fileprivate var scrollSpeed = CGFloat(0)
    fileprivate var longPressGes: UILongPressGestureRecognizer!
    fileprivate var isFirstMove = false
    fileprivate var hasChoosedAll = false
    
    fileprivate var chooseCount = 0 {
        didSet {
            bottomBar.choosedCount = chooseCount
        }
    }
    
    // common view
    
    fileprivate var statusBar: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, w: kScreenWidth, h: kStatusBarHeight))
        view.backgroundColor = SpiderConfig.Color.BackgroundDark
        return view
    }()
    
    fileprivate lazy var unboxView = ArticleUndocBoxView()
    
    fileprivate lazy var toolBar: ArticleBottomBar = {
        let bar = ArticleBottomBar()
        bar.backHandler = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        bar.unchiveHandler = { [weak self] in
            self?.pushUnchiveView()
        }
        
        return bar
    }()
    
    fileprivate lazy var bottomBar: EditMindBottomBar = {
        let bar = EditMindBottomBar()
        bar.deleteHandler = { [weak self] in
            self?.deleteChoosedSections()
        }
        
        bar.moveHandler = { [weak self] in
            self?.moveInOutline()
        }
        return bar
    }()
    
    fileprivate lazy var topBar: EditMindTopBar = {
        let bar = EditMindTopBar(title: self.articleName)
        bar.doneHandler = { [weak self] in
            self?.changeModel()
        }
        
        bar.chooseAllHandler = { [weak self] in
            self?.choosedAllSections()
        }
        return bar
    }()
    
    fileprivate lazy var addSectoinButton: UIButton? = {
        let button = UIButton()
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        button.setImage(UIImage(named: "article_add_button"), for: UIControlState())
        button.addTarget(self, action: #selector(addSectionClicked), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var toUndocView = MoveMindUpView(toUndoc: true)
    
    fileprivate lazy var tableView = ArticleListTableView()
    
    fileprivate lazy var addSectionIndicator: UIImageView? = {
        return UIImageView(image: UIImage(named: "article_nil_background"))
    }()
    
    fileprivate lazy var addSectionView = AddMediaView(unDoc: false)
    
    fileprivate var layoutPool = LayoutPool()
    
    // MARK: - Life Cycle
    convenience init(id: String) {
        self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let article = SpiderConfig.ArticleList.article else { return }
        articleName = article.name
        
        sections = article.sections.filter("deleteFlag == 0")
        sectionItems.append(contentsOf: sections)

        notificationToken = sections.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let tableView = self?.tableView, let sSelf = self else { return }
            
            switch changes {
                
            case .initial:
                break
                
            case .update(let results, let delete, let insert, let modifications):
                
                if !delete.isEmpty && sSelf.outlineShowed {   // disappear to outlineVC
                    sSelf.hasMoved = true
                }
                
                if !insert.isEmpty && delete.isEmpty && modifications.isEmpty {
                    
                    guard let index = insert.first else { return }
                    
                    let section = results[index], indexPath = IndexPath(row: index, section: 1)
                    
                    if section.id != sSelf.dragInSectionID {
                        sSelf.sectionItems.insert(section, at: index)
                        
                        if section.type == 0 {  // TextSection
                            tableView.insertRows(at: [indexPath], with: .fade)
                        } else {
                            sSelf.toShowIndexPath = indexPath
                        }
                    }
                }
                
                if !sSelf.sections.isEmpty {
                    sSelf.addSectionIndicator?.removeFromSuperview()
                    sSelf.addSectoinButton?.removeFromSuperview()
                }
                
                guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ArticleTitleCell else {
                    return
                }

                cell.sectionCountLabel.text = "\(results.count)个段落"
                
            case .error(let error):
                print(error)
            }
        }
        
        SpiderPlayer.sharedManager.addObserver(self, forKeyPath: "changed", options: .old, context: &myContext)
        
        longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        tableView.addGestureRecognizer(longPressGes)
        
        tableView.register(ArticlePicsCell.self, forCellReuseIdentifier: articlePicsCellID)
        tableView.register(ArticleTextCell.self, forCellReuseIdentifier: articleTextCellID)
        tableView.register(ArticleAudioCell.self, forCellReuseIdentifier: articleAudioCellID)
        tableView.register(ArticleTitleCell.self, forCellReuseIdentifier: articleTitleCellID)
        
        makeUI()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &myContext {
            if let key = keyPath, key == "changed" {
                guard let _ = toShowIndexPath else {    // 如有新增段落，跳过updateUI
                    DispatchQueue.main.async(execute: {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        UIApplication.shared.setStatusBarStyle(beEditing ? .default : .lightContent, animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let indexPath = toShowIndexPath {    // 新建图片、音频段落
            toShowIndexPath = nil
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        
        if hasMoved {       // 通过大纲移动
            hasMoved = false
            outlineShowed = false
            deleteChoosedSections(doInRealm: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParentViewController {
            notificationToken?.stop()
            
            SpiderPlayer.sharedManager.removeObserver(self, forKeyPath: "changed", context: &myContext)
            SpiderPlayer.sharedManager.reset()
            
            UIApplication.shared.setStatusBarStyle(.default, animated: false)
            
            SpiderConfig.ArticleList.reset()
            
            println(" ArticleListViewController: release RealmToken, reset SpiderPlayer & ArticleList")
        }
    }

    fileprivate func makeUI() {
        view.backgroundColor = UIColor.white
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
            
            addSectionIndicator!.snp_makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 150, height: 245))
                make.center.equalTo(view)
            })
            
            addSectoinButton!.snp_makeConstraints({ (make) in
                make.size.equalTo(40)
                make.centerX.equalTo(view)
                make.top.equalTo(addSectionIndicator!.snp_bottom)
            })
        }
    }
    
    func pushUnchiveView() {
        unboxView.articleDelegate = self
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        unboxView.moveTo(view)
    }
    
    func addSectionClicked() {
        addSectionView.addTo(view)
    }
}

// MARK: - Move & Edit
extension ArticleListViewController {
    
    func didLongPress(_ ges: UILongPressGestureRecognizer) {
        var location = ges.location(in: tableView)
        
        switch ges.state {
            
        case .began:
            
            guard let indexPath = tableView.indexPathForRow(at: location), indexPath.section != 0 else { return }
            
            toUndocView.moveToView(tableView)
            
            if !beEditing {
                changeModel()
            }
            
            if let moveCell = tableView.cellForRow(at: indexPath) {
                
                catchedView = moveCell.getSnapshotImageView()
                tableView.addSubview(catchedView)
                
                movingIndexPath = indexPath
                originIndex = indexPath.item
                
                DispatchQueue.main.async(execute: {
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

        case .changed:
            
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
                
                displayLink?.isPaused = scrollSpeed == 0.0
            }
            
        default:
            
            guard let choosedIndexPath = movingIndexPath else { return }
            
            if toUndocView.isHighlight {    // 移入碎片盒
                
                SpiderRealm.unchiveSection(sectionItems[choosedIndexPath.item])
                
                movingIndexPath = nil

                UIView.move(catchedView, toPoint: toUndocView.center, withScalor: 40 / catchedView.frame.width, completion: { [weak self] done in
                    self?.toUndocView.removeFromSuperview()
                    self?.tableView.beginUpdates()
                    self!.sectionItems.remove(at: choosedIndexPath.item)
                    self?.tableView.deleteRows(at: [choosedIndexPath], with: .none)
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
                tableView.reloadRows(at: [choosedIndexPath], with: .none)
            }
        
            displayLink?.isPaused = true
            
            break
        }
    }
    
    func moveCatchedViewToLocation(_ location: CGPoint) {
        let y = min(max(location.y, tableView.bounds.origin.y), tableView.bounds.origin.y + tableView.bounds.height)
        catchedView.center = CGPoint(x: location.x, y: y)
        
        if toUndocView.frame.contains(catchedView.center) {
            toUndocView.isHighlight = true
        } else {
            toUndocView.isHighlight = false
        }
        
        guard let newIndexPath = tableView.indexPathForRow(at: catchedView.center),
                  let currentIndexPath = movingIndexPath, newIndexPath != currentIndexPath
        else { return }
        
        guard let cell = tableView.cellForRow(at: newIndexPath) else { return }
        
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
    
    func moveSection(at aIndexP: IndexPath, to bIndexP: IndexPath) {
        
        if bIndexP.section == 1 {
            
            if dragCancelled {
                
                dragCancelled = false
                
                if let section = dragInSection {
                    
                    movingIndexPath = bIndexP
                    sectionItems.insert(section, at: bIndexP.item)
                    tableView.insertRows(at: [bIndexP], with: .fade)
                }
                
            } else {
                
                swap(&sectionItems[aIndexP.item], &sectionItems[bIndexP.item])
                
                movingIndexPath = bIndexP
                tableView.moveRow(at: aIndexP, to: bIndexP)
            }
        
        } else {
            
            if unboxDragging && !dragCancelled {
                dragCancelled = true
                movingIndexPath = bIndexP
                sectionItems.remove(at: aIndexP.item)
                tableView.beginUpdates()
                tableView.deleteRows(at: [aIndexP], with: .top)
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
            
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
            navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
            
            view.backgroundColor = UIColor.white
            toolBar.isHidden = false
            chooseCount = 0
            layoutPool.chooseAllItem(false)
            bottomBar.removeFromSuperview()
            
            tableView.reloadData()
            
        } else {
            
            beEditing = true
            isFirstMove = true
            UIApplication.shared.setStatusBarStyle(.default, animated: false)
            navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
            
            view.backgroundColor = SpiderConfig.Color.EditTheme
            
            tableView.beEditing = true
            tableView.reloadData()
            
            toolBar.isHidden = true
            topBar.addToView(view)
            bottomBar.addToView(view)
            
            displayLink = CADisplayLink(target: self, selector: #selector(scrollEvent))
            displayLink?.add(to: .main, forMode: RunLoopMode.defaultRunLoopMode)
            displayLink?.isPaused = true
        }
    }
    
    func scrollEvent() {
        tableView.contentOffset.y = min(max(0.0, tableView.contentOffset.y + scrollSpeed), tableView.contentSize.height - tableView.frame.height)
        
        toUndocView.center.y = tableView.contentOffset.y + kScreenHeight / 2 - 60
        
        moveCatchedViewToLocation(longPressGes.location(in: tableView))
    }
    
    func choosedAllSections() {
        hasChoosedAll = !hasChoosedAll
        
        layoutPool.chooseAllItem(hasChoosedAll)
        tableView.reloadData()
        
        chooseCount = hasChoosedAll ? sectionItems.count : 0
    }
    
    func deleteChoosedSections(doInRealm: Bool = true) {
        guard let article = SpiderConfig.ArticleList.article else { return }
        
        let ids = layoutPool.deleteChoosed()
        var sections = [SectionObject]()

        for id in ids {
            
            guard let index = sectionItems.index(where: { $0.id == id }) else { return }
            
            sections.append(sectionItems[index])

            sectionItems.remove(at: index)
            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(item: index, section: 1)], with: .top)
            tableView.endUpdates()
        }
        
        if doInRealm { SpiderRealm.removeSections(sections, in: article) }
        chooseCount = 0
    }
    
    func moveInOutline() {
        outlineShowed = true
        present(OutlineViewController(state: .MoveSection, toMoveItems: layoutPool.choosedItems()), animated: true, completion: nil)
    }
}

// MARK: - ArticleUndocBoxDelegate

extension ArticleListViewController: ArticleUndocBoxDelegate {
    
    func didBeginToDragSeciton(_ section: SectionObject, layout: UndocBoxLayout, ges: UILongPressGestureRecognizer) {

        if let snapView = UnBoxToArticleSnapView(info: layout) {
            
            displayLink = CADisplayLink(target: self, selector: #selector(undocScrollEvent))
            displayLink?.add(to: .main, forMode: RunLoopMode.defaultRunLoopMode)
            displayLink?.isPaused = true
            unboxDragging = true
            dragInSection = section
            
            let point = ges.location(in: tableView)
            undocGes = ges

            cellSnapView = snapView
            snapView.center = point
            tableView.addSubview(snapView)
            
            guard let indexPath = tableView.indexPathForRow(at: point) , indexPath.section != 0 else { return }
            
            movingIndexPath = indexPath
            originIndex = indexPath.item
            sectionItems.insert(section, at: indexPath.item)
            tableView.insertRows(at: [indexPath], with: .none)
        }
    }
    
    func didChange(_ ges: UILongPressGestureRecognizer) {
        
        if let snapView = cellSnapView {
            
            let loc = undocGes.location(in: tableView)
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
                
                displayLink?.isPaused = scrollSpeed == 0.0
            }
        }
    }
    
    func didEndDrag(_ location: CGPoint) {
        unboxView.articleDelegate = nil
        unboxView.removeFromSuperview()
        cellSnapView?.removeFromSuperview()
        
        displayLink?.invalidate()
        undocGes = nil
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        
        if let choosedIndexPath = movingIndexPath, let undocSection = dragInSection {
            
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
                tableView.reloadRows(at: [choosedIndexPath], with: .none)
            }
            
            dragInSectionID = undocSection.id
        }
        
        dragInSection = nil
        dragCancelled = false
        unboxDragging = false
    }
    
    func didQuitUndocBox() {
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
    
    func moveUndocItemToLocation(_ location: CGPoint) {
        let y = min(max(location.y, tableView.bounds.origin.y), tableView.bounds.origin.y + tableView.bounds.height)
        cellSnapView?.center = CGPoint(x: location.x, y: y)
        
        guard let newIndexPath = tableView.indexPathForRow(at: location),
            let currentIndexPath = movingIndexPath, newIndexPath != currentIndexPath
            else { return }
        
        guard let cell = tableView.cellForRow(at: newIndexPath) else { return }
        
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
        moveUndocItemToLocation(undocGes.location(in: tableView))
    }
}

// MARK: - TableView Delegate

extension ArticleListViewController: UITableViewDataSource, UITableViewDelegate {
    fileprivate enum Section: Int {
        case title = 0
        case content = 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        
        switch section {
            
        case .title:
            return 1
            
        case .content:
            return sectionItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        
        func cellForSection(_ section: SectionObject) -> UITableViewCell {
            
            let type = SectionType(rawValue: section.type)!
            
            switch type {
                
            case .pic:
                let cell = tableView.dequeueReusableCell(withIdentifier: articlePicsCellID, for: indexPath) as! ArticlePicsCell
                return cell
                
            case .audio:
                let cell = tableView.dequeueReusableCell(withIdentifier: articleAudioCellID, for: indexPath) as! ArticleAudioCell
                return cell
                
            case .text:
                let cell = tableView.dequeueReusableCell(withIdentifier: articleTextCellID, for: indexPath) as! ArticleTextCell
                return cell
            }
        }
        
        switch section {
            
        case .title:
            
            return tableView.dequeueReusableCell(withIdentifier: articleTitleCellID, for: indexPath) as! ArticleTitleCell
            
        case .content:
            
            let sectionInfo = sectionItems[indexPath.item]
            return cellForSection(sectionInfo)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section),
                  let cell = cell as? ArticleBaseCell else {
            return
        }
        
        cell.addSectionHandler = { [weak self] in
            
            if let indexPath = tableView.indexPath(for: cell) {
                
                if indexPath.section == 0 {
                    SpiderConfig.ArticleList.insertIndex = 0
                } else {
                    guard let index = self?.sectionItems[indexPath.item].indexOfOwner else { return }
                    SpiderConfig.ArticleList.insertIndex = index + 1
                }
            }
        }
        
        func configureSectionCell(_ cell: UITableViewCell, withSection section: SectionObject) {
            
            var layout = layoutPool.cellLayoutOfSection(section)
            let type = SectionType(rawValue: section.type)!
            
            switch type {
                
            case .text:
                
                guard let cell = cell as? ArticleTextCell else { return }
                
                cell.tapAction = { [weak self] in
                    
                    if self!.beEditing {
                        
                        self!.chooseCount += self!.layoutPool.updateSelectState(section) ? 1 : -1
                        tableView.reloadRows(at: [tableView.indexPath(for: cell)!], with: .none)
                        
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
                
            case .pic:
                
                guard let cell = cell as? ArticlePicsCell else { return }
                
                cell.tapAction = { [weak self] in
                    
                    guard let indexPath = tableView.indexPath(for: cell) else { return }
                    
                    if self!.beEditing {
                        
                        self!.chooseCount += self!.layoutPool.updateSelectState(section) ? 1 : -1
                        tableView.reloadRows(at: [indexPath], with: .none)
                        
                    } else {
                        
                        SpiderPlayer.sharedManager.player?.stop()
                        
                        let sectionInfo = self?.sectionItems[indexPath.item]
                        let picDetailVC = PicDetailViewController(picSection: sectionInfo)
                        self?.navigationController?.pushViewController(picDetailVC, animated: true)
                    }
                }
                    
                cell.congfigureWithSection(section, layout: layout, editing: beEditing)
                
            case .audio:
                
                guard let cell = cell as? ArticleAudioCell else { return }
                layout = layoutPool.updatePlayedTimeOfSection(section)
                cell.congfigureWithSection(section, layout: layout, editing: beEditing)
            }
        }
        
        switch section {
            
        case .title:
            
            guard let cell = cell as? ArticleTitleCell  else { return }
            cell.isHidden = beEditing
            cell.configureTitleCell(articleName, sectionCount: sections.count)
            
        case .content:
            
            if let movingIndexP = movingIndexPath, movingIndexP == indexPath {
                
                cell.isHidden = true
                
            } else {
                
                let sectionInfo = sectionItems[indexPath.item]
                configureSectionCell(cell, withSection: sectionInfo)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else { return 0 }
        
        switch section {
            
        case .title:
            return beEditing ? 0 : 80 + kArticleCellBottomOffset
            
        case .content:
            let sectionInfo = sectionItems[indexPath.item]
            return layoutPool.heightOfSection(sectionInfo)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        if section != .title {
            
            let sectionObject = sectionItems[indexPath.item]
            let type = SectionType(rawValue: sectionObject.type)!
            
            switch type {
            case .audio:
                
                if beEditing {
                    
                    chooseCount += layoutPool.updateSelectState(sectionObject) ? 1 : -1
                    tableView.reloadRows(at: [indexPath], with: .none)
                    
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
