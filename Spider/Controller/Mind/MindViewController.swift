//
//  MindViewController.swift
//  Spider
//
//  Created by Atuooo on 5/23/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import SwiftyJSON
import UIKit
import RealmSwift

private let cellID = "MindTableViewCell"
private let mindReuseID = "MindTableViewCell_Submind"
private let articleReuseID = "MindTableViewCell_Article"

class MindViewController: BaseTableViewController, UISearchBarDelegate, UINavigationControllerDelegate {
    
    /** 从搜索页进来，定位到搜索节点 */
    var structLevelView:StructLevelView!
    
    var searchResultMind: MindObject?
    
    private var mindUIInfos = [MindUIInfo]()
    
    private var ownerProject: ProjectObject?
    private var ownerMind: MindObject?
    private var structInfo: String = ""
    
    private var minds = [MindObject]()
    private var mindResult: Results<MindObject>!
    private var notificationToken: NotificationToken?
    
    private var beEditing = false
    
    private var ownerName = ""
    
    private var hasChoosedAll = false
    
    private var choosedCount = 0 {
        willSet {
            editBottomBar.choosedCount = newValue
        }
    }
    
    private var outlineShowed = false
    private var hasMoved = false
    private var isFirstMove = true
    
    private var currentLevel = Int(0)
    
    private var movingIndexPath: NSIndexPath?
    private var putInIndexPath: NSIndexPath?
    
    private var catchedView: UIImageView!
    
    private var displayLink: CADisplayLink!
    private var scrollSpeed = CGFloat(0)
    private var longPress: UILongPressGestureRecognizer!

    private var addMindView = AddMindView()
    
    private lazy var editTopBar: EditMindTopBar = {
        return EditMindTopBar(title: self.ownerName)
    }()
    
    private lazy var editBottomBar: EditMindBottomBar = {
        return EditMindBottomBar()
    }()
    
    private var moveMindUpView: MoveMindUpView?
    
    private var topButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, w: 36, h: 40))
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 0)
        button.setImage(UIImage(named: "mind_top_button"), forState: .Normal)
        return button
    }()
    
    private var searchBar = CustomSearchBar()
    
    // MARK: - Controller life cycle
    convenience init(ownerProject: ProjectObject) {
        self.init()
        self.ownerProject = ownerProject
        mindResult = ownerProject.usefulMinds
        minds.appendContentsOf(mindResult)
        ownerName = ownerProject.name
        structInfo = ownerProject.name
    }
    
    convenience init(ownerMind: MindObject) {
        self.init()
        self.ownerMind = ownerMind
        mindResult = ownerMind.usefulMinds
        minds.appendContentsOf(mindResult)
        ownerName = ownerMind.name
        structInfo = ownerMind.structInfo
    }
    
    convenience init(mind: MindObject) {
        self.init()
        
        if let superMind = mind.ownerMind.first {
            self.ownerMind = mind.ownerMind.first
            ownerName = superMind.name
            mindResult = superMind.usefulMinds
            minds.appendContentsOf(mindResult)
            structInfo = superMind.structInfo

        } else if let superNote = mind.ownerProject.first {
            self.ownerProject = mind.ownerProject.first
            ownerName = superNote.name
            mindResult = superNote.usefulMinds
            minds.appendContentsOf(mindResult)
            structInfo = superNote.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        customLizeNavigationBarBackBtn()
        
        searchBar.delegate = self
        structLevelView = StructLevelView.init(frame:CGRectMake(0, 0, kScreenWidth, 40))
        structLevelView.addBottomFillLineWithColor(RGBCOLORV(0xeaeaea).CGColor)
        view.addSubview(structLevelView)
        
        structLevelView.onTap = { [weak self] in
            self?.presentViewController(OutlineViewController(state: .JustJump), animated: true, completion: nil)
        }

        createLevelMenu()
        
        // 回调点击事件
        TriggerBtnCallBack()
        
        tableView.frame = CGRectMake(0, structLevelView.h, kScreenWidth, kScreenHeight - structLevelView.h - 50)
        tableView.registerClass(MindViewCell.self, forCellReuseIdentifier: mindReuseID)
        tableView.registerClass(MindViewCell.self, forCellReuseIdentifier: articleReuseID)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        currentLevel = SpiderStruct.sharedInstance.currentLevel

        if searchResultMind != nil && !mindUIInfos.isEmpty {
            let index = minds.indexOf(searchResultMind!)!
            tableView.scrollToRowAtIndexPath(NSIndexPath.init(forRow: index, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
        currentLevel = SpiderStruct.sharedInstance.currentLevel

        makeUI()
        addActions()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
        
        if !beEditing {
            setDataSource()
            SpiderStruct.sharedInstance.currentLevel = currentLevel
            if searchResultMind != nil && !minds.isEmpty {
                let index = minds.indexOf(searchResultMind!)!
                tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true, scrollPosition: .Bottom)
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        rfreshCurrentLevelMenu()
        
        if beEditing && hasMoved {
            outlineShowed = false
            hasMoved = false
            
            deleteChoosedMinds(doInRealm: false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }
    
    override func backAction() {
        
        AppNavigator.popViewControllerAnimated(false)
        
    }
    
    deinit {
        
    }
    
    func rfreshCurrentLevelMenu() -> Void {
        if SPIDERSTRUCT.sourceMindType == SourceMindControType.ComeFromSelf || SPIDERSTRUCT.sourceMindType == SourceMindControType.ComeFromHome { // 如果是push进来的，那么点击一下structView
            recodeCurrentLightLevel()
        }
    }
    
    // 创建层级菜单
    func createLevelMenu() -> Void {
        let levelCount = structInfo.componentsSeparatedByString(" > ")
        SPIDERSTRUCT.currentLevel = levelCount.count - 1
        SPIDERSTRUCT.currentMindPath = structInfo
        
        if SPIDERSTRUCT.allPushMindPath.containsArray(levelCount) && SPIDERSTRUCT.allPushMindPath.count > levelCount.count { // 是否包含当前路径
            structLevelView.createLevelBtn(SPIDERSTRUCT.allPushMindPath, currentObj: SPIDERSTRUCT.lastMind)
            recodeCurrentLightLevel()
        }
        else{
            
            SPIDERSTRUCT.allPushMindPath = levelCount // 正常push情况下，存储被push过的结点的最长路径（当从搜索界面进入需要!）
            if levelCount.count == 1 {
                structLevelView.createLevelBtn(levelCount, currentObj: ownerProject)
                structLevelView.btnAction(structLevelView.containMindArr[0])
            }else{
                structLevelView.createLevelBtn(levelCount, currentObj: ownerMind)
                SPIDERSTRUCT.lastMind = ownerMind
                recodeCurrentLightLevel()
            }
        }
    }
    
    // 创建控制器
    func TriggerBtnCallBack() -> Void {
        
        for item:UIButton in structLevelView.containMindArr {
            
            (item as! StructLevelItem).onClick = {[weak self]
                
                (structItem:StructLevelItem) -> Void in
                
                SPIDERSTRUCT.sourceMindType = SourceMindControType.ComeFromStructLevel
                // 构造的控制器数量 ：(levelCount?.count)! + 1
                var newController:[UIViewController] = [MindViewController]()
                var mindObjVC_Parent:MindViewController!
                
                if structItem.currenMind.isKindOfClass(MindObject.self) {
                    let currentMind = structItem.currenMind as! MindObject
                    let levelCount = currentMind.structInfo.componentsSeparatedByString(" > ")
                    var superMind:MindObject?            = (currentMind.ownerMind.first) // 父节点
                    var superProject:ProjectObject?      = (currentMind.ownerProject.first)
                    let vc = MindViewController(ownerMind: currentMind)
                    newController.append(vc) // 先添加自身结点
                    
                    for _ in 0..<levelCount.count - 1 {
                        if superMind != nil {
                            mindObjVC_Parent = MindViewController.init(ownerMind: superMind!)
                            newController.append(mindObjVC_Parent)
                            superProject     = superMind?.ownerProject.first
                            superMind        = superMind!.ownerMind.first
                        }else{

                            // 先判断父级结点是否是mind, 如果不是，那就是项目结点，否则在进行赋值
                            mindObjVC_Parent = MindViewController.init(ownerProject: superProject!)
                            newController.append(mindObjVC_Parent)
                            break
                            // 结束for循环
                        }
                    }
                    
                }
                else{
                    
                    let currentMind = structItem.currenMind as! ProjectObject
                    mindObjVC_Parent = MindViewController.init(ownerProject: currentMind)
                    newController.append(mindObjVC_Parent)
                    
                }
                
                // 数组倒序插入
                let reveredArr:[UIViewController] = Array(newController.reverse())
                APP_NAVIGATOR.mainNav?.viewControllers.replaceRange(Range(1...(APP_NAVIGATOR.mainNav?.viewControllers.count)!-1), with: reveredArr)
            }
        }
    }
    
    // 记录当前控制器的层级点击状态
    func recodeCurrentLightLevel() -> Void {
        
        for (index, obj) in structLevelView.containMindArr.enumerate() {
            
            if index % 2 == 0 {
                if ownerMind == obj.currenMind {
                    structLevelView.isTriggerEvent = true
                    structLevelView.btnAction(structLevelView.containMindArr[index])
                } else if ownerProject == obj.currenMind {
                
                    structLevelView.isTriggerEvent = true
                    structLevelView.btnAction(structLevelView.containMindArr[index])
                }
            }
        }
    }
    
    // MARK: - Data Source
    private func setDataSource() {
        mindUIInfos.removeAll()
        
        for i in 0 ..< minds.count {
            
            let mind = minds[i]
            mindUIInfos.append(MindUIInfo(mind: mind, isFirst: i == 0))
        }
        
        self.tableView.reloadData()
    }
    
    private func makeUI() {
        // hierarchy
        view.addSubview(addMindView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: topButton)

        navigationItem.titleView = searchBar
        navigationController?.navigationBar.setNeedsLayout()
        navigationController?.navigationBar.translucent = true
        
        addMindView.translatesAutoresizingMaskIntoConstraints = false
        addMindView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 92))
            make.bottom.equalTo(-20)
            make.right.equalTo(-12)
        }
    }
    
    private func addActions() {
        /** 添加节点 or 长文 */
        addMindView.addMindHandler = { [weak self] type in
            self?.addMind(type)
        }
        
        /** navigation item actions */
        topButton.addTarget(self, action: #selector(topItemClicked), forControlEvents: .TouchUpInside)
        
        /** add gesture */
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        tableView.addGestureRecognizer(longPress)
        
        /** edit tool bar */
        editTopBar.doneHandler = { [weak self] in
            self?.changeModel()
        }
        
        editTopBar.chooseAllHandler = { [weak self] in
            self?.chooseAllMinds()
        }
        
        editBottomBar.moveHandler = { [weak self] in
            self?.moveChoosedMinds()
        }
        
        editBottomBar.deleteHandler = { [weak self] in
            self?.deleteChoosedMinds()
        }
    }
    
    func didLongPress(ges: UIGestureRecognizer) {
        var location = ges.locationInView(tableView)
        
        switch ges.state {
            
        case .Began:
            
            if let indexPath = tableView.indexPathForRowAtPoint(location) {
                
                if let _ = ownerMind {
                    moveMindUpView = MoveMindUpView()
                    moveMindUpView!.moveToView(tableView)
                }
                
                if !beEditing {
                    changeModel()
                }
                
                let moveCell = tableView.cellForRowAtIndexPath(indexPath) as! MindViewCell
                catchedView = moveCell.getSnapshotImageView()
                
                movingIndexPath = indexPath
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
                if isFirstMove {
                    isFirstMove = false
                    location = CGPoint(x: location.x, y: location.y + 40)
                }
                
                catchedView.animateMoveTo(point: location, withScalor: 0.7)
                tableView.addSubview(catchedView)
            }
            
        case .Changed:
            
            moveCatchedViewToLocation(location)
            
            scrollSpeed = 0.0
            
            if tableView.contentSize.height > tableView.frame.height {
                
                let halfCellHeight = 0.5 * catchedView.frame.height
                let cellCenterY = catchedView.center.y - tableView.bounds.origin.y
                
                if cellCenterY < halfCellHeight {
                    
                    scrollSpeed = 5.0*(cellCenterY/halfCellHeight - 1.1)
                }
                else if cellCenterY > tableView.frame.height - halfCellHeight {
                    
                    scrollSpeed = 5.0*((cellCenterY - tableView.frame.height)/halfCellHeight + 1.1)
                }
                
                displayLink.paused = scrollSpeed == 0.0
            }
            
        default:
            guard let choosedIndexPath = movingIndexPath else { return }
            
            movingIndexPath = nil
            
            defer {
                choosedCount = mindUIInfos.filter({$0.choosed}).count    // 所有操作完成后，更新数据
            }
            
            if let moveView = moveMindUpView where moveView.isHighlight { // 移入上一级
                /** UI */
                mindUIInfos.removeAtIndex(choosedIndexPath.item)

                UIView.move(catchedView, toPoint: moveView.center, withScalor: 40 / catchedView.frame.width, completion: { done in
                    moveView.removeFromSuperview()
                    
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths([choosedIndexPath], withRowAnimation: .None)
                    self.tableView.endUpdates()
                })
                
                
                operationToRefreshStructLevel(minds[choosedIndexPath.item])
                
                /** dataSource */
                SpiderRealm.removeMindUp(minds[choosedIndexPath.item])
                minds.removeAtIndex(choosedIndexPath.item)
                
                return  // 防止 reload
            }
                
            if let putIndexPath = putInIndexPath,
               let putInCell = tableView.cellForRowAtIndexPath(putIndexPath) as? MindViewCell   // 移入兄弟节点
            {
                putInIndexPath = nil
                
                // 更新相应的 cellHeight
                if choosedIndexPath.item == 0 {
                    mindUIInfos[choosedIndexPath.item + 1].cellHeight += kMindVerticalSpacing
                }
                
                self.mindUIInfos.removeAtIndex(choosedIndexPath.item)
                
                /** UI */
                UIView.move(catchedView, toPoint: putInCell.center, withScalor: 0.5, completion: { done in
                    putInCell.unHighlight()
                    
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths([choosedIndexPath], withRowAnimation: .None)
                    self.tableView.endUpdates()
                })
                
                /** dataSource */
                SpiderRealm.move(minds[choosedIndexPath.item], to: minds[putIndexPath.item])
                minds.removeAtIndex(choosedIndexPath.item)
                
            } else {
                
                catchedView.removeFromSuperview()
                tableView.reloadRowsAtIndexPaths([choosedIndexPath], withRowAnimation: .None)
            }
            
            displayLink.paused = true
            moveMindUpView?.removeFromSuperview()
        }
    }
    
    func scrollEvent() {
        tableView.contentOffset.y = min(max(0.0, tableView.contentOffset.y + scrollSpeed), tableView.contentSize.height - tableView.frame.height)
        
        if let moveView = moveMindUpView {
            moveView.center.y = tableView.contentOffset.y + kScreenHeight / 2 - 60
        }
        
        moveCatchedViewToLocation(longPress.locationInView(tableView))
    }
    
    func moveCatchedViewToLocation(location: CGPoint) {
        let y = min(max(location.y, tableView.bounds.origin.y), tableView.bounds.origin.y + tableView.bounds.height)
        catchedView.center = CGPoint(x: location.x, y: y)
        
        if let moveUpView = moveMindUpView {    // 移动到上一级
            if moveUpView.frame.contains(catchedView.center) {
                moveUpView.isHighlight = true
            } else {
                moveUpView.isHighlight = false
            }
        }
        
        guard let newIndexPath = tableView.indexPathForRowAtPoint(catchedView.center),
                  currentIndexPath = movingIndexPath
            where newIndexPath != currentIndexPath
            else { return }
        
        guard let cell = tableView.cellForRowAtIndexPath(newIndexPath) as? MindViewCell else { return }
        
        if mindUIInfos[newIndexPath.item].type == .Mind {
            if cell.frame.contains(catchedView.frame) {     // 移动到兄弟节点
                putInIndexPath = newIndexPath
                cell.hightlight()
            } else {
                cell.unHighlight()
                putInIndexPath = nil
            }
        }
        
        if newIndexPath.item < currentIndexPath.item {
            if catchedView.center.y < (cell.frame.origin.y + 18) {
                moveMindAt(currentIndexPath, to: newIndexPath)
            }
        } else {
            if catchedView.center.y > cell.frame.maxY - 18 {
                moveMindAt(currentIndexPath, to: newIndexPath)
            }
        }
    }
    
    func moveMindAt(currentIndexPath: NSIndexPath, to newIndexPath: NSIndexPath) {
        if currentIndexPath.item == 0 {
            mindUIInfos[currentIndexPath.item].cellHeight -= kMindVerticalSpacing
            mindUIInfos[newIndexPath.item].cellHeight += kMindVerticalSpacing
        }
        
        if newIndexPath.item == 0 {
            mindUIInfos[0].cellHeight -= kMindVerticalSpacing
            mindUIInfos[currentIndexPath.item].cellHeight += kMindVerticalSpacing
        }
        
        let info = mindUIInfos[currentIndexPath.item]
        mindUIInfos.removeAtIndex(currentIndexPath.item)
        mindUIInfos.insert(info, atIndex: newIndexPath.item)
        
        movingIndexPath = newIndexPath
        
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([currentIndexPath], withRowAnimation: .Top)
        tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Top)
        tableView.endUpdates()
        
        SpiderRealm.swap(minds[currentIndexPath.item], minds[newIndexPath.item], in: ownerMind ?? ownerProject)
        
        swap(&minds[currentIndexPath.item], &minds[newIndexPath.item])
    }
    
    func changeModel() {
        
        if beEditing {
            notificationToken?.stop()

            beEditing = false
            isFirstMove = true
            displayLink.invalidate()
            navigationController?.fd_fullscreenPopGestureRecognizer.enabled = true
            
            tableView.frame.size = view.frame.size
            tableView.backgroundColor = UIColor.whiteColor()
            tableView.sectionHeaderHeight = 40
            
            editBottomBar.removeFromSuperview()
            
            UIView.animateWithDuration(0.3, animations: { 
                self.addMindView.alpha = 1
                self.structLevelView.alpha = 1
            })
            
            UIView.animateWithDuration(0.1, animations: {
                self.tableView.frame = CGRect(x: 0, y: 40, w: kScreenWidth, h: self.view.frame.height - 40)
                self.tableView.reloadData()
            })
            
            SPIDERSTRUCT.sourceMindType = SourceMindControType.ComeFromSelf
            recodeCurrentLightLevel()
            
        } else {
            
            notificationToken = mindResult.addNotificationBlock({ [weak self] change in
                guard let sSelf = self else { return }

                switch change {
                case .Update(_, let delete, _, _):
                    if sSelf.outlineShowed && !delete.isEmpty {
                        sSelf.hasMoved = true
                    }
                default:
                    break
                }
            })
            
            beEditing = true
            tableView.backgroundColor = UIColor.color(withHex: 0xebebeb)
            
            navigationController?.fd_fullscreenPopGestureRecognizer.enabled = false
            
            structLevelView.alpha = 0
            addMindView.alpha = 0
            
            self.tableView.frame = CGRect(x: 0, y: 0, w: kScreenWidth, h: view.frame.height - 60)
            tableView.reloadData()
            
            editTopBar.addToView(navigationController!.view)
            editBottomBar.addToView(view)
            displayLink = CADisplayLink(target: self, selector: #selector(scrollEvent))
            displayLink.addToRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            displayLink.paused = true
        }
    }
    
    func chooseAllMinds() {
        hasChoosedAll = !hasChoosedAll
        
        for i in 0 ..< mindUIInfos.count {
            mindUIInfos[i].choosed = hasChoosedAll
        }
        
        choosedCount = hasChoosedAll ? mindUIInfos.count : 0
        
        tableView.reloadData()
    }
    
    // MARK: - Edit Minds
    func addMind(type: MindType) {
        let alert = CreateMindView()
        alert.moveTo(view.window!)
        
        alert.doneHandler = { [weak self] text in

            let mind = MindObject(name: text, type: type.rawValue)
            let info = MindUIInfo(mind: mind, isFirst: self!.minds.isEmpty)
            self?.mindUIInfos.append(info)
            self?.minds.append(mind)
            SpiderRealm.updateMind(mind, to: self?.ownerMind ?? self?.ownerProject)
            
            self?.tableView.reloadData()
        }
    }
    
    func deleteChoosedMinds(doInRealm doInRealm: Bool = true) {
        var deleteCount = 0
        let infos = mindUIInfos
        
        for i in 0 ..< infos.count {
            
            if infos[i].choosed {
                let index = i - deleteCount
                mindUIInfos.removeAtIndex(index)
                deleteCount += 1
                
                /** UI */
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
                tableView.endUpdates()
                
                // 在数据库删掉之前先刷新层级菜单
                operationToRefreshStructLevel(minds[index])

                /** dataSource */
                if doInRealm { SpiderRealm.removeMind(minds[index], in: ownerMind ?? ownerProject) }
                minds.removeAtIndex(index)
            }
        }
        
        if !mindUIInfos.isEmpty {
            mindUIInfos[0].cellHeight += kMindVerticalSpacing
        }
        
        choosedCount = 0
    }
    
    func moveChoosedMinds() {
        var choosedMindIDs = [String]()

        for info in mindUIInfos {
            if info.choosed { choosedMindIDs.append(info.id) }
        }
        
        outlineShowed = true
        let outlineVC = OutlineViewController(state: .MoveMind, toMoveItems: choosedMindIDs)
        presentViewController(outlineVC, animated: true, completion: nil)
    }
    
    func editMindAt(index: Int) {
        let alert = CreateMindView(text: mindUIInfos[index].name)
        
        alert.doneHandler = { [weak self] text in
            SpiderRealm.updateMind(self!.minds[index], text: text)
            
            let rect = text.boundingRectWithSize(CGSize(width: kMindTextLabelWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: [NSFontAttributeName: SpiderConfig.Font.Text], context: nil)
            
            self?.mindUIInfos[index].name = text
            self?.mindUIInfos[index].labelHeight = rect.height
            
            self?.tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: index, inSection: 0)], withRowAnimation: .Fade)
        }
        
        alert.moveTo(view.window!)
    }
    
    // MARK: - Button actions
    func topItemClicked() {
        SpiderStruct.sharedInstance.currentLevel = 0
        AppNavigator.popToRootViewController(true)
    }

    func updateHeight(index: Int) {
        
        if mindUIInfos[index].foldable {
            mindUIInfos[index].cellHeight += mindUIInfos[index].labelHeight - kMindTextLabelMinHeight
        }

        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func fold(index: Int) {
        mindUIInfos[index].cellHeight = 95
        
        if index == 0 {
            mindUIInfos[index].cellHeight += kMindVerticalSpacing
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func operationToRefreshStructLevel(mind: MindObject) -> Void {
        // 在数据库删掉之前先刷新层级菜单
        for item in structLevelView.currentMindArray {
            if item.isKindOfClass(MindObject.self) && (item as! MindObject).id == mind.id {
                // 删除的是当前层级菜单的下一级
                SPIDERSTRUCT.lastMind = ownerMind
                SPIDERSTRUCT.allPushMindPath = structInfo.componentsSeparatedByString(" > ")
                break
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touch begin dismiss keyboard")
        view.endEditing(true)
    }
}

// MARK: - TableView DelegatetableViewview
extension MindViewController {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if beEditing {
            
            let choosed = mindUIInfos[indexPath.item].choosed
            mindUIInfos[indexPath.item].choosed = !choosed
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            choosedCount = mindUIInfos.filter({$0.choosed}).count
            
        } else {
            
            let mind = mindUIInfos[indexPath.item]
            let currentLevel = SPIDERSTRUCT.currentLevel
            
            if mind.type == .Mind {
                
                if currentLevel <= 3 {
                    
                    SPIDERSTRUCT.currentLevel += 1
                    let vc = MindViewController(ownerMind: minds[indexPath.item])
                    SPIDERSTRUCT.sourceMindType = SourceMindControType.ComeFromSelf
                    AppNavigator.pushViewController(vc, animated: false)
                    
                } else {
                    
                    SpiderAlert.tellYou(message: "已经到第五级了哦！", inViewController: self)
                }
                
            } else {
                
                SpiderConfig.ArticleList.article = minds[indexPath.item]
                let vc = ArticleListViewController()
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if beEditing {
            return 100
        } else {
            return mindUIInfos[indexPath.item].cellHeight
        }
    }
}

// MARK: - TableView DataSource
extension MindViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mindUIInfos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let info = mindUIInfos[indexPath.item]
        
        if beEditing {
            let cell = MindViewCell(info: info, editing: true)

            /** 编辑 */
            cell.editHandler = { [weak self] in
                let index = tableView.indexPathForCell(cell)!.item
                self?.editMindAt(index)
            }
            
            if indexPath == movingIndexPath {
                cell.hidden = true
            }
            
            return cell
            
        } else {
            
            let cell = MindViewCell(info: info, isFirst: indexPath.item == 0)
            
            /** 展开 */
            cell.unfoldHandler = { [weak self] in
                self?.updateHeight(indexPath.item)
                self?.mindUIInfos[indexPath.item].folding = false
            }
            
            /** 收起 */
            cell.foldHandler = { [weak self] in
                self?.fold(indexPath.item)
                self?.mindUIInfos[indexPath.item].folding = true
            }
            
            return cell
        }
    }
}

//MARK: searchBarDelegate

extension MindViewController {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchHeaderViewClick()
    }
    
    func searchHeaderViewClick() -> Void {
        let searchMainController = SearchMainViewController()
        // 防止多次push
        if !(navigationController!.topViewController!.isKindOfClass(SearchMainViewController)) {
            navigationController?.pushViewController(searchMainController, animated: true)
            
        }
    }
}


