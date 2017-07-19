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
    
    fileprivate var layout = OutlineLayout()
    fileprivate var layoutPool = [String: OutlineLayout]()
    
    fileprivate var tableView = OutlineTableView()
    
    fileprivate var state = OutlineState.MoveSection
    fileprivate var toMoveItems = [String]()
    fileprivate var toMoveItemIDs = [String]()
    fileprivate var addToMind: MindObject?
    
    fileprivate var currentID = ""
    
    fileprivate var doubleTap: UITapGestureRecognizer!
    fileprivate var tap: UITapGestureRecognizer!
    
    fileprivate lazy var editBar: OutlineEditBar = {
        let bar = OutlineEditBar(state: self.state)
        bar.addHandler = { [weak self] (text, type) in
            delay(0.3, work: {
                self?.addNewMind(text, type: type)
            })
        }
        
        bar.putInHandler = { [weak self] in
            self?.moveItems()
        }
        
        bar.isHidden = true
        return bar
    }()
    
    fileprivate lazy var topBar: OutlineTopBar = {
        let bar = OutlineTopBar(jump: self.state == .JustJump, projectID: self.layout.projectID)
        
        bar.backHandler = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        bar.changeHandler = { [weak self] in
            self?.projectListView.addOrRemoveTo(self!.view)
        }
        
        return bar
    }()
    
    fileprivate lazy var projectListView: OutlineProjectListView = {
        let view = OutlineProjectListView(currentID: self.layout.projectID)
        view.selectHandler = { [weak self] project in
            self?.changeTo(project)
        }
        return view
    }()
    
    fileprivate lazy var headerView: OutlineHeaderView = {
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
        AODlog("OutlineViewController deinit")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        if let project = SpiderConfig.sharedInstance.project, project.deleteFlag == 0 {
            currentID = project.id
            layout = OutlineLayout(mainNote: project)
        } else {
            headerView.isHidden = true
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
                let mind = REALM.realm.object(ofType: MindObject.self, forPrimaryKey: id as AnyObject) else { return }
            
            toMoveItemIDs = toMoveItems
            toMoveItemIDs.insertAsFirst(mind.ownerID)
            
        case .MoveSection:
            
            tableView.tableHeaderView = headerView
            toMoveItemIDs = toMoveItems
            
            if let id = toMoveItems.first,
                let section = REALM.realm.object(ofType: SectionObject.self, forPrimaryKey: id as AnyObject),
                let ownerID = section.ownerID {
                
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.setStatusBarStyle(.default, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didDoubleTap(_ ges: UITapGestureRecognizer) {
        
        let location = ges.location(in: tableView)
        
        guard let indexPath = tableView.indexPathForRow(at: location) else { return }
        
        let mind = layout.minds[indexPath.item]
        
        if mind.type == 0 { // mind
            
            dismiss(animated: false, completion: {
                SPIDERSTRUCT.sourceMindType = SourceMindControType.comeFromSelf
                let mindVC = MindViewController(mind: mind)
                mindVC.view.backgroundColor = UIColor.white
                AppNavigator.pushViewController(mindVC, animated: false)
            })
            
        } else {
            
            SpiderConfig.ArticleList.article = mind
            dismiss(animated: false, completion: {
                SPIDERSTRUCT.sourceMindType = SourceMindControType.comeFromSelf
                AppNavigator.pushViewController(ArticleListViewController(), animated: true)
            })
        }
    }
    
    fileprivate func addNewMind(_ text: String, type: MindType, atTop: Bool = false) {

        if atTop {
            
            let addMind = MindObject(name: text, type: type.rawValue)
            SpiderRealm.addMind(addMind, to: layout.projectID)
            
            layout.insertAtTop(addMind)
            
            if let index = layout.editIndex {
                editBar.center.y = kOutlineCellHeight * (CGFloat(index) + 1.5)
            }
            
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            tableView.endUpdates()
            
        } else {
            
            if let editIndex = layout.editIndex {
                
                let mind = layout.minds[editIndex]
                let addMind = MindObject(name: text, type: type.rawValue)
                
                if layout.statusOf(editIndex) == .closed {
                    openMind(mind, index: editIndex)
                }
                
                SpiderRealm.addMind(addMind, to: mind)
                
                layout.minds.insert(addMind, at: editIndex + 1)
                
                tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(row: editIndex, section: 0)], with: .none)
                tableView.insertRows(at: [IndexPath(row: editIndex + 1, section: 0)], with: .fade)
                tableView.endUpdates()
            }
        }
    }
    
    fileprivate func showProgressHud(with handler: @escaping (() -> Void)) {
        DispatchQueue.main.async { [weak self] in
            let hud = MBProgressHUD.showAdded(to: (self?.view)!, animated: true)
            hud.animationType = .fade
            hud.minSize = CGSize(width: 80, height: 80)
            hud.minShowTime = 1
            hud.color = UIColor(white: 0.8, alpha: 0.5)
            
            hud.show(animated: true, whileExecuting: {
                DispatchQueue.main.async(execute: {
                    hud.customView = UIImageView(image: UIImage(named: "Checkmark"))
                    hud.mode = .customView
                    hud.labelColor = SpiderConfig.Color.DarkText
                    hud.labelText = "已移入"
                    
                    handler()
                    
                    hud.hide(true)
                    
                })
            }, completionBlock: { [weak self] in
                self?.layout.recordOutlineInfo()
                self?.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    fileprivate func moveItems(_ toProject: Bool = false) {

        func getMoveItemMaxDepth() -> Int {
            var maxDepth = 0
            
            for id in toMoveItems {
                if let mind = REALM.realm.object(ofType: MindObject.self, forPrimaryKey: id as AnyObject) {
                    maxDepth = max(maxDepth, mind.depth)
                }
            }
            
            return maxDepth
        }
        
        if state == .MoveMind {
            if toProject {
                guard let id = toMoveItems.first,
                    let mind = REALM.realm.object(ofType: MindObject.self, forPrimaryKey: id as AnyObject) else { return }
                
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
    
    fileprivate func changeTo(_ project: ProjectObject) {
        
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
                editBar.isHidden = false
            } else {
                editBar.isHidden = true
            }
            
            tableView.reloadData()
            tableView.setContentOffset(layout.offset, animated: false)
        }
    }
}

extension OutlineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return layout.minds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mind = layout.minds[indexPath.item]
        return OutlineViewCell(mind: mind, status: layout.statusOf(indexPath.item), choosed: isChoosed(mind))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let mind = layout.minds[indexPath.item]
        
        switch layout.statusOf(indexPath.item) {
            
        case .closed:
            if canOpen(mind) {
                openMind(mind, index: indexPath.item)
            }
            
        case .opened:
            guard let range = layout.closeMind(at: indexPath.item) else { return }
            deleteRowsAtRange(range)

        default:
            break
        }
        
        moveEditBar(to: mind)
    }
    
    func isChoosed(_ mind: MindObject) -> Bool {  //TODO:- optimize time & memory
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
     
    func canOpen(_ mind: MindObject) -> Bool {
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
        guard let index = layout.minds.index(of: mind), !isChoosed(mind) else { return }
        
        switch state {
        case .MoveMind:
            if mind.type == 0 {
                layout.editIndex = index
                editBar.level = mind.level
                editBar.state = .inNewMind
                editBar.center.y = kOutlineCellHeight * (CGFloat(index) + 1.5)
                editBar.isHidden = false
            }
            
        case .MoveSection:
            layout.editIndex = index
            editBar.level = mind.level
            editBar.state = OutlineEditBarState(rawValue: mind.type)!
            editBar.center.y = kOutlineCellHeight * (CGFloat(index) + 1.5)
            editBar.isHidden = false
            
        default:
            break
        }
    }
    
    func openMind(_ mind: MindObject, index: Int) {
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
    
    func insertRowsAtRange(_ range: CountableClosedRange<Int>) {
        let insertIndexPaths = range.map{ IndexPath(row: $0, section: 0) }
        
        tableView.beginUpdates()
        tableView.insertRows(at: insertIndexPaths, with: .bottom)
        tableView.reloadRows(at: [IndexPath(row: range.lowerBound - 1, section: 0)], with: .none)
        tableView.endUpdates()
    }
    
    func deleteRowsAtRange(_ range: CountableClosedRange<Int>) {
        let deleteIndexPaths = range.map{ IndexPath(row: $0, section: 0) }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: range.lowerBound - 1, section: 0)], with: .none)
        tableView.deleteRows(at: deleteIndexPaths, with: .none)
        tableView.endUpdates()
    }
}
