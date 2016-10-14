//
//  OutlineViewController.swift
//  Spider
//
//  Created by ooatuoo on 16/8/29.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit
import RealmSwift
import MBProgressHUD

enum OutlineState: String {
    case JustJump    = "跳转"
    case MoveMind    = "节点"
    case MoveSection = "长文"
}

class OutlineViewController: UIViewController {
    
    private var layout = OutlineLayout()
    private var layoutPool = [String: OutlineLayout]()
    
    private var tableView = OutlineTableView()
    
    private var state = OutlineState.MoveSection
    private var toMoveItems = [String]()
    private var toMoveItemIDs = [String]()
    private var addToMind: MindObject?
    
    private var currentID = ""
    
    private var doubleTap: UITapGestureRecognizer!
    private var tap: UITapGestureRecognizer!
    
    private lazy var editBar: OutlineEditBar = {
        let bar = OutlineEditBar(state: self.state)
        bar.addHandler = { [weak self] (text, type) in
            delay(0.3, work: {
                self?.addNewMind(text, type: type)
            })
        }
        
        bar.putInHandler = { [weak self] in
            self?.moveItems()
        }
        
        bar.hidden = true
        return bar
    }()
    
    private lazy var topBar: OutlineTopBar = {
        let bar = OutlineTopBar(jump: self.state == .JustJump, projectID: self.layout.projectID)
        
        bar.backHandler = { [weak self] in
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        bar.changeHandler = { [weak self] in
            self?.projectListView.addOrRemoveTo(self!.view)
        }
        
        return bar
    }()
    
    private lazy var projectListView: OutlineProjectListView = {
        let view = OutlineProjectListView(currentID: self.layout.projectID)
        view.selectHandler = { [weak self] project in
            self?.changeTo(project)
        }
        return view
    }()
    
    private lazy var headerView: OutlineHeaderView = {
        let view = OutlineHeaderView(state: self.state)
        view.putInHandler = { [weak self] in
            self?.moveItems(true)
        }
        
        view.addHandler = { [weak self] (text, type) in
            delay(0.3, work: {
                self?.addNewMind(text, type: type, atTop: true)
            })
        }
        return view
    }()

    init(state: OutlineState, toMoveItems: [String] = [String]()) {
        super.init(nibName: nil, bundle: nil)
        
        self.state = state
        self.toMoveItems = toMoveItems
    }
    
    deinit {
        println("OutlineViewController deinit")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        if let project = SpiderConfig.sharedInstance.project where project.deleteFlag == 0 {
            currentID = project.id
            layout = OutlineLayout(mainNote: project)
        } else {
            headerView.hidden = true
        }

        switch state {
            
        case .JustJump:
            
            doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
            doubleTap.numberOfTapsRequired = 2
            doubleTap.delaysTouchesBegan = true
            tableView.addGestureRecognizer(doubleTap)
            
        case .MoveMind:
            
            tableView.tableHeaderView = headerView
            guard let id = toMoveItems.first,
                mind = REALM.realm.objectForPrimaryKey(MindObject.self, key: id) else { return }
            
            toMoveItemIDs = toMoveItems
            toMoveItemIDs.insertAsFirst(mind.ownerID)
            
        case .MoveSection:
            
            tableView.tableHeaderView = headerView
            toMoveItemIDs = toMoveItems
            
            if let id = toMoveItems.first,
                section = REALM.realm.objectForPrimaryKey(SectionObject.self, key: id),
                ownerID = section.ownerID {
                
                toMoveItemIDs.append(ownerID)
            }
        }
                
        view.addSubview(topBar)
        tableView.addSubview(editBar)

        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(64)
            make.left.right.bottom.equalTo(view)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didDoubleTap(ges: UITapGestureRecognizer) {
        
        let location = ges.locationInView(tableView)
        
        guard let indexPath = tableView.indexPathForRowAtPoint(location) else { return }
        
        let mind = layout.minds[indexPath.item]
        
        if mind.type == 0 { // mind
            
            dismissViewControllerAnimated(false, completion: {
                SPIDERSTRUCT.sourceMindType = SourceMindControType.ComeFromSelf
                let mindVC = MindViewController(mind: mind)
                mindVC.view.backgroundColor = UIColor.whiteColor()
                AppNavigator.pushViewController(mindVC, animated: false)
            })
            
        } else {
            
            SpiderConfig.ArticleList.article = mind
            dismissViewControllerAnimated(false, completion: {
                SPIDERSTRUCT.sourceMindType = SourceMindControType.ComeFromSelf
                AppNavigator.pushViewController(ArticleListViewController(), animated: true)
            })
        }
    }
    
    private func addNewMind(text: String, type: MindType, atTop: Bool = false) {

        if atTop {
            
            let addMind = MindObject(name: text, type: type.rawValue)
            SpiderRealm.addMind(addMind, to: layout.projectID)
            
            layout.insertAtTop(addMind)
            
            if let index = layout.editIndex {
                editBar.center.y = kOutlineCellHeight * (CGFloat(index) + 1.5)
            }
            
            tableView.beginUpdates()
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
            tableView.endUpdates()
            
        } else {
            
            if let editIndex = layout.editIndex {
                
                let mind = layout.minds[editIndex]
                let addMind = MindObject(name: text, type: type.rawValue)
                
                if layout.statusOf(editIndex) == .Closed {
                    openMind(mind, index: editIndex)
                }
                
                SpiderRealm.addMind(addMind, to: mind)
                
                layout.minds.insert(addMind, atIndex: editIndex + 1)
                
                tableView.beginUpdates()
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: editIndex, inSection: 0)], withRowAnimation: .None)
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: editIndex + 1, inSection: 0)], withRowAnimation: .Fade)
                tableView.endUpdates()
            }
        }
    }
    
    private func showProgressHud(with handler: (() -> Void)) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            let hud = MBProgressHUD.showHUDAddedTo(self?.view, animated: true)
            hud.animationType = .Fade
            hud.minSize = CGSize(width: 80, height: 80)
            hud.minShowTime = 1
            hud.color = UIColor(white: 0.8, alpha: 0.5)
            
            hud.showAnimated(true, whileExecutingBlock: {
                dispatch_async(dispatch_get_main_queue(), {
                    hud.customView = UIImageView(image: UIImage(named: "Checkmark"))
                    hud.mode = .CustomView
                    hud.labelColor = SpiderConfig.Color.DarkText
                    hud.labelText = "已移入"
                    
                    handler()
                    
                    hud.hide(true)
                    
                })
            }, completionBlock: { [weak self] in
                self?.layout.recordOutlineInfo()
                self?.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    private func moveItems(toProject: Bool = false) {

        func getMoveItemMaxDepth() -> Int {
            var maxDepth = 0
            
            for id in toMoveItems {
                if let mind = REALM.realm.objectForPrimaryKey(MindObject.self, key: id) {
                    maxDepth = max(maxDepth, mind.depth)
                }
            }
            
            return maxDepth
        }
        
        if state == .MoveMind {
            if toProject {
                guard let id = toMoveItems.first,
                    mind = REALM.realm.objectForPrimaryKey(MindObject.self, key: id) else { return }
                
                if mind.level == 1 && mind.noteID == layout.projectID {
                    SpiderAlert.tellYou(message: "你所选的节点已经在该项目下了哦！", inViewController: self)
                } else {
                    showProgressHud(with: { [weak self] in
                        SpiderRealm.moveMinds(self!.toMoveItems, to: self!.layout.projectID)
                    })
                }
                
            } else {
                
                guard let inMind = layout.chooseMind else { return }
                
                if getMoveItemMaxDepth() + inMind.level > 5 {
                    SpiderAlert.tellYou(message: "你所选的内容层级过深，无法放入该节点", inViewController: self)
                } else {
                    showProgressHud(with: { [weak self] in
                        SpiderRealm.moveMinds(self!.toMoveItems, to: inMind)
                    })
                }
            }
            
        } else {
            guard let inMind = layout.chooseMind else { return }
            showProgressHud(with: { [weak self] in
                SpiderRealm.moveSections(self!.toMoveItems, to: inMind)
            })
        }
    }
    
    private func changeTo(project: ProjectObject) {
        
        topBar.projectName = project.name
        
        if layout.projectID != project.id {
            
            layout.offset = tableView.contentOffset
            layoutPool[layout.projectID] = layout
            
            if let currentLayout = layoutPool[project.id] {
                layout = currentLayout
            } else {
                layout = OutlineLayout(mainNote: project)
            }
            
            if let editIndex = layout.editIndex {
                moveEditBar(to: layout.minds[editIndex])
                editBar.hidden = false
            } else {
                editBar.hidden = true
            }
            
            tableView.reloadData()
            tableView.setContentOffset(layout.offset, animated: false)
        }
    }
}

extension OutlineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return layout.minds.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let mind = layout.minds[indexPath.item]
        return OutlineViewCell(mind: mind, status: layout.statusOf(indexPath.item), choosed: isChoosed(mind))
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let mind = layout.minds[indexPath.item]
        
        switch layout.statusOf(indexPath.item) {
            
        case .Closed:
            if canOpen(mind) {
                openMind(mind, index: indexPath.item)
            }
            
        case .Opened:
            guard let range = layout.closeMind(at: indexPath.item) else { return }
            deleteRowsAtRange(range)

        default:
            break
        }
        
        moveEditBar(to: mind)
    }
    
    func isChoosed(mind: MindObject) -> Bool {  //TODO:- optimize time & memory
        if state == .JustJump {
            return false
        }
        
        if currentID != layout.projectID {
            return false
        } else {
            for toMoveID in toMoveItemIDs {
                if mind.id == toMoveID {
                    return true
                }
            }
            
            return false
        }
    }
     
    func canOpen(mind: MindObject) -> Bool {
        if state == .JustJump {
            return true
        }
        
        if currentID != layout.projectID {
            return true
        } else {
            for toMoveID in toMoveItems {
                if mind.id == toMoveID {
                    return false
                }
            }
            
            return true
        }
    }
    
    func moveEditBar(to mind: MindObject) {
        guard let index = layout.minds.indexOf(mind) where !isChoosed(mind) else { return }
        
        switch state {
        case .MoveMind:
            if mind.type == 0 {
                layout.editIndex = index
                editBar.level = mind.level
                editBar.state = .InNewMind
                editBar.center.y = kOutlineCellHeight * (CGFloat(index) + 1.5)
                editBar.hidden = false
            }
            
        case .MoveSection:
            layout.editIndex = index
            editBar.level = mind.level
            editBar.state = OutlineEditBarState(rawValue: mind.type)!
            editBar.center.y = kOutlineCellHeight * (CGFloat(index) + 1.5)
            editBar.hidden = false
            
        default:
            break
        }
    }
    
    func openMind(mind: MindObject, index: Int) {
        if let toCloseRange = layout.closeOpenedMindOfLevel(at: index) {
            
            CATransaction.begin()
            
            CATransaction.setCompletionBlock({ [weak self] in
                guard let toOpenRange = self?.layout.openMind(mind) else { return }
                self?.insertRowsAtRange(toOpenRange)
            })
            
            deleteRowsAtRange(toCloseRange)
            
            CATransaction.commit()
            
        } else {
            
            guard let toOpenRange = layout.openMind(mind) else { return }
            insertRowsAtRange(toOpenRange)
        }
    }
    
    func insertRowsAtRange(range: Range<Int>) {
        let insertIndexPaths = range.map{ NSIndexPath(forRow: $0, inSection: 0) }
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(insertIndexPaths, withRowAnimation: .Bottom)
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: range.startIndex - 1, inSection: 0)], withRowAnimation: .None)
        tableView.endUpdates()
    }
    
    func deleteRowsAtRange(range: Range<Int>) {
        let deleteIndexPaths = range.map{ NSIndexPath(forRow: $0, inSection: 0) }
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: range.startIndex - 1, inSection: 0)], withRowAnimation: .None)
        tableView.deleteRowsAtIndexPaths(deleteIndexPaths, withRowAnimation: .None)
        tableView.endUpdates()
    }
}
