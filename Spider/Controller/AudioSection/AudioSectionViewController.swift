//
//  AudioSectionViewController.swift
//  Spider
//
//  Created by ooatuoo on 16/7/14.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

private let cellID = "AudioSectionCellID"

class AudioSectionViewController: UIViewController {
    
    var type: AudioToolBarType = .Record
    
    private var lastSelectedIndex: NSIndexPath! {
        willSet {
            if newValue == nil {
                tagPlayButton.hidden = true
            }
        }
    }
    
    var tagSources = [AudioTagInfo]()
    
    var audioID: String?
    
    private var picking = false
    
    private var tagToast: AudioTagToast?
    
    private var playedTime: NSTimeInterval?
    private var section: SectionObject?
    
    private var toShowTag: TagObject?
    
    private lazy var tagPlayButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 48, height: 25))
        button.setBackgroundImage(UIImage(named: "audio_tag_play"), forState: .Normal)
        return button
    }()
    
    private var tableView: AudioTagTableView = {
        return AudioTagTableView()
    }()
    
    private var titleView: AudioTitleView = {
        return AudioTitleView()
    }()
    
    private var toolBar: AudioRecordToolBar!
    
    // MARK: - Life Cycle
    
    init(section: SectionObject? = nil, toShowTag: TagObject? = nil, playedTime: NSTimeInterval? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.section = section
        self.toShowTag = toShowTag
        self.playedTime = playedTime
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .None
        
        if let section = section, audioObject = section.audio {
            type = .Play
            
            titleView.title = section.ownerName
            
            if let playedTime = playedTime {
                
                if section.id != SpiderPlayer.sharedManager.playingID {
                    
                    SpiderPlayer.sharedManager.prepareToPlay(AudioInfo(section: section), at: playedTime)
                    SpiderPlayer.sharedManager.changed = true
                }
                
                toolBar = AudioRecordToolBar(inController: self, playedTime: playedTime)
                
            } else {
                
                let audioURL = APP_UTILITY.getAudioFilePath(audioObject.url)
                toolBar = AudioRecordToolBar(audioURL: audioURL, inController: self)
            }
            
            let tags = audioObject.tags.sorted("location", ascending: true)
            
            for tag in tags {
                tagSources.append(AudioTagInfo(tag: tag))
            }
            
        } else {
            
            type = .Record
            
            if let article = SpiderConfig.ArticleList.article {
                titleView.title = article.name
            } else {
                titleView.title = "未归档"
            }
            
            navigationController?.fd_fullscreenPopGestureRecognizer.enabled = false
            toolBar = AudioRecordToolBar(inController: self)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(titleView)
        view.addSubview(tableView)
        view.addSubview(toolBar)
        
        tagPlayButton.hidden = true
        tableView.addSubview(tagPlayButton)
        
        addActions()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let tag = toShowTag else { return }
        
        for i in 0 ..< tagSources.count {
            
            if tag.id == tagSources[i].id {
                
                let indexPath = NSIndexPath(forItem: i, inSection: 0)
                unFoldCellAt(indexPath)
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            }
        }
        
        toShowTag = nil
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !picking {
            toolBar.removeFromSuperview()
        }
    }
    
    deinit {
        print("deinit AudioSectionViewController")
        
    }
    
    // MARK: - View's Actions
    func addActions() {
        tagPlayButton.addTarget(self, action: #selector(tagPlayButtonClicked), forControlEvents: .TouchUpInside)
        
        // gesture
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        tableView.addGestureRecognizer(longPress)
        
        // view's actions
        toolBar.quitHandler = { [weak self] in
            
            if let navigator = self?.navigationController {
                navigator.popViewControllerAnimated(true)
            } else {
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        toolBar.doneHandler = { [weak self] duration in
            self?.doneRecord(with: duration)
        }
        
        toolBar.reRecordHandler = { [weak self] in
            self?.reRecord()
        }

        toolBar.markTextHandler = { [weak self] timeString in
            let addTextView = SectionAddTextView(text: "")
            self?.view.addSubview(addTextView)
            
            addTextView.doneHandler = { [weak self] text in
                self?.addTag(AudioTagInfo(content: text, selected: false, time: timeString))
            }
        }
        
        toolBar.markPicHandler = { [weak self] timeString in
            
            self?.picking = true
            
            let picker = TZImagePickerController(maxCount: 1, completion: { [weak self] photos in
                
                self?.addTag(AudioTagInfo(pic: photos[0], selected: false, time: timeString))
                self?.picking = false
            })
            
            self?.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func reRecord() {
        tagSources.removeAll()
        tableView.reloadData()
    }
    
    func doneRecord(with duration: String) {
        
        section = SpiderRealm.createAudioSection(toolBar.audioID!, duration: duration, with: tagSources)
        
        type = .Play
        navigationController?.fd_fullscreenPopGestureRecognizer.enabled = true
        foldCell()
    }
    
    func didLongPress(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .Began {
            
            let location = sender.locationInView(tableView)
            let indexPath = tableView.indexPathForRowAtPoint(location)
            
            if let indexPath = indexPath {
                
                let tagInfo = tagSources[indexPath.item]
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! AudioTagInfoCell
                let toastCenter = cell.convertPoint(cell.getCenter(), toView: view).addOffset(CGPoint(x: 0, y: -17))
                
                tagToast?.removeFromSuperview()
                tagToast = AudioTagToast(type: tagInfo.type == .Pic ? "PicToast" : "TextToast")
                tagToast!.center = toastCenter
                view.addSubview(tagToast!)
                
                tagToast?.editHandler = { [weak self] in
                    
                    let addTextView = SectionAddTextView(text: tagInfo.content!)
                    self?.view.addSubview(addTextView)
                    
                    addTextView.doneHandler = { [weak self] text in
                        self?.editTagAt(indexPath, with: text)
                    }
                }
                
                tagToast?.deleteHandler = { [weak self] in
                    self?.deleteTagAt(indexPath)
                }
            }
        }
    }
    
    // MARK: - Common Methods
    
    func addTag(info: AudioTagInfo) {
        var atIndex = -1
        
        for i in 0 ..< tagSources.count {
            let tagInfo = tagSources[i]
            if tagInfo.time >= info.time {
                atIndex = i
                break
            }
        }
        
        if atIndex == -1 {
            atIndex = tagSources.count
        }
        
        foldCell()
        
        tableView.beginUpdates()
        tagSources.insert(info, atIndex: atIndex)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: atIndex, inSection: 0)], withRowAnimation: .None)
        tableView.endUpdates()
        
        unFoldCellAt(NSIndexPath(forItem: atIndex, inSection: 0))
        
        if let section = section {
            SpiderRealm.addTag(TagObject(tagInfo: info), to: section, at: atIndex)
        }
    }
    
    func editTagAt(index: NSIndexPath, with text: String) {
        let tagInfo = tagSources[index.item]
        
        tagSources[index.item].content = text
        tableView.reloadData()
        
        if tagInfo.selected {
            let cell = tableView.cellForRowAtIndexPath(index) as! AudioTagInfoCell
            tagSources[index.item].height = cell.unfoldTag()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        if let section = section {
            SpiderRealm.updateTextTag(in: section, at: index.item, with: text)
        }
    }
    
    func deleteTagAt(index: NSIndexPath) {
        
        let tagInfo = tagSources[index.item]
        
        if tagInfo.selected {
           lastSelectedIndex = nil
        }
        
        tableView.beginUpdates()
        tagSources.removeAtIndex(index.item)
        tableView.deleteRowsAtIndexPaths([index], withRowAnimation: .Fade)
        tableView.endUpdates()
        
        if let section = section {
            SpiderRealm.deleteTag(in: section, at: index.item)
        }
    }
    
    func foldCell() {
        
        if let _ = tagToast where tagToast!.isDescendantOfView(view) {
            tagToast?.removeFromSuperview()
        }
        
        if lastSelectedIndex != nil {
            
            tagSources[lastSelectedIndex.item].selected = false
            
            tableView.beginUpdates()
            tagSources[lastSelectedIndex.item].height = kAudioTagCellHeight
            let lastCell = tableView.cellForRowAtIndexPath(lastSelectedIndex) as! AudioTagInfoCell
            lastCell.foldTag()
            tableView.endUpdates()
        }
    }
    
    func unFoldCellAt(indexPath: NSIndexPath) {
        if let _ = tagToast where tagToast!.isDescendantOfView(view) {
            tagToast?.removeFromSuperview()
        }
        
        let tagInfo = tagSources[indexPath.item]
        
        if tagInfo.selected {
            
        } else {
            // TODO: - 展开 & 折叠 动画细调
            foldCell()
            
            let nowCell = tableView.cellForRowAtIndexPath(indexPath) as! AudioTagInfoCell
            lastSelectedIndex = indexPath
            tagSources[indexPath.item].selected = true
            
            tableView.beginUpdates()
            tagSources[indexPath.item].height = nowCell.unfoldTag()
            tableView.endUpdates()
            
            if type == .Play {
                let buttonOrigin = CGPoint(x: 12, y: 4.5 + CGFloat(indexPath.item) * kAudioTagCellHeight)
                tagPlayButton.frame.origin = buttonOrigin
                tagPlayButton.hidden = false
            }
        }

    }
    
    func tagPlayButtonClicked() {
        let timeString = tagSources[lastSelectedIndex.item].time
        toolBar.playAt(timeString.toTime())
    }
}

// MARK: - TableView
extension AudioSectionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagSources.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = AudioTagInfoCell(info: tagSources[indexPath.item])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        unFoldCellAt(indexPath)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tagSources[indexPath.item].height
    }
}

extension AudioSectionViewController: AVAudioRecorderDelegate {
    // TODO: - 录音异常、中断的处理
}
