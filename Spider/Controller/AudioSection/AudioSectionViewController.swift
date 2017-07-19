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
    
    var type: AudioToolBarType = .record
    
    fileprivate var lastSelectedIndex: IndexPath! {
        willSet {
            if newValue == nil {
                tagPlayButton.isHidden = true
            }
        }
    }
    
    var tagSources = [AudioTagInfo]()
    
    var audioID: String?
    
    fileprivate var picking = false
    
    fileprivate var tagToast: AudioTagToast?
    
    fileprivate var playedTime: TimeInterval?
    fileprivate var section: SectionObject?
    
    fileprivate var toShowTag: TagObject?
    
    fileprivate lazy var tagPlayButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 48, height: 25))
        button.setBackgroundImage(UIImage(named: "audio_tag_play"), for: UIControlState())
        return button
    }()
    
    fileprivate var tableView: AudioTagTableView = {
        return AudioTagTableView()
    }()
    
    fileprivate var titleView: AudioTitleView = {
        return AudioTitleView()
    }()
    
    fileprivate var toolBar: AudioRecordToolBar!
    
    // MARK: - Life Cycle
    
    init(section: SectionObject? = nil, toShowTag: TagObject? = nil, playedTime: TimeInterval? = nil) {
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
        edgesForExtendedLayout = UIRectEdge()
        
        if let section = section, let audioObject = section.audio {
            type = .play
            
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
            let tags = audioObject.tags.sorted(byKeyPath: "location", ascending: true)
        
            for tag in tags {
                tagSources.append(AudioTagInfo(tag: tag))
            }
            
        } else {
            
            type = .record
            
            if let article = SpiderConfig.ArticleList.article {
                titleView.title = article.name
            } else {
                titleView.title = "未归档"
            }
            
            navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
            toolBar = AudioRecordToolBar(inController: self)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(titleView)
        view.addSubview(tableView)
        view.addSubview(toolBar)
        
        tagPlayButton.isHidden = true
        tableView.addSubview(tagPlayButton)
        
        addActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let tag = toShowTag else { return }
        
        for i in 0 ..< tagSources.count {
            
            if tag.id == tagSources[i].id {
                
                let indexPath = IndexPath(item: i, section: 0)
                unFoldCellAt(indexPath)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        
        toShowTag = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
        tagPlayButton.addTarget(self, action: #selector(tagPlayButtonClicked), for: .touchUpInside)
        
        // gesture
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        tableView.addGestureRecognizer(longPress)
        
        // view's actions
        toolBar.quitHandler = { [weak self] in
            
            if let navigator = self?.navigationController {
                navigator.popViewController(animated: true)
            } else {
                self?.dismiss(animated: true, completion: nil)
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
            
            self?.present(picker, animated: true, completion: nil)
        }
    }
    
    func reRecord() {
        tagSources.removeAll()
        tableView.reloadData()
    }
    
    func doneRecord(with duration: String) {
        
        section = SpiderRealm.createAudioSection(toolBar.audioID!, duration: duration, with: tagSources)
        
        type = .play
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        foldCell()
    }
    
    func didLongPress(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            
            let location = sender.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at: location)
            
            if let indexPath = indexPath {
                
                let tagInfo = tagSources[indexPath.item]
                let cell = tableView.cellForRow(at: indexPath) as! AudioTagInfoCell
                let toastCenter = cell.convert(cell.getCenter(), to: view).addOffset(CGPoint(x: 0, y: -17))
                
                tagToast?.removeFromSuperview()
                tagToast = AudioTagToast(type: tagInfo.type == .pic ? "PicToast" : "TextToast")
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
    
    func addTag(_ info: AudioTagInfo) {
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
        tagSources.insert(info, at: atIndex)
        tableView.insertRows(at: [IndexPath(row: atIndex, section: 0)], with: .none)
        tableView.endUpdates()
        
        unFoldCellAt(IndexPath(item: atIndex, section: 0))
        
        if let section = section {
            SpiderRealm.addTag(TagObject(tagInfo: info), to: section, at: atIndex)
        }
    }
    
    func editTagAt(_ index: IndexPath, with text: String) {
        let tagInfo = tagSources[index.item]
        
        tagSources[index.item].content = text
        tableView.reloadData()
        
        if tagInfo.selected {
            let cell = tableView.cellForRow(at: index) as! AudioTagInfoCell
            tagSources[index.item].height = cell.unfoldTag()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        if let section = section {
            SpiderRealm.updateTextTag(in: section, at: index.item, with: text)
        }
    }
    
    func deleteTagAt(_ index: IndexPath) {
        
        let tagInfo = tagSources[index.item]
        
        if tagInfo.selected {
           lastSelectedIndex = nil
        }
        
        tableView.beginUpdates()
        tagSources.remove(at: index.item)
        tableView.deleteRows(at: [index], with: .fade)
        tableView.endUpdates()
        
        if let section = section {
            SpiderRealm.deleteTag(in: section, at: index.item)
        }
    }
    
    func foldCell() {
        
        if let _ = tagToast, tagToast!.isDescendant(of: view) {
            tagToast?.removeFromSuperview()
        }
        
        if lastSelectedIndex != nil {
            
            tagSources[lastSelectedIndex.item].selected = false
            
            tableView.beginUpdates()
            tagSources[lastSelectedIndex.item].height = kAudioTagCellHeight
            let lastCell = tableView.cellForRow(at: lastSelectedIndex) as! AudioTagInfoCell
            lastCell.foldTag()
            tableView.endUpdates()
        }
    }
    
    func unFoldCellAt(_ indexPath: IndexPath) {
        if let _ = tagToast, tagToast!.isDescendant(of: view) {
            tagToast?.removeFromSuperview()
        }
        
        let tagInfo = tagSources[indexPath.item]
        
        if tagInfo.selected {
            
        } else {
            // TODO: - 展开 & 折叠 动画细调
            foldCell()
            
            let nowCell = tableView.cellForRow(at: indexPath) as! AudioTagInfoCell
            lastSelectedIndex = indexPath
            tagSources[indexPath.item].selected = true
            
            tableView.beginUpdates()
            tagSources[indexPath.item].height = nowCell.unfoldTag()
            tableView.endUpdates()
            
            if type == .play {
                let buttonOrigin = CGPoint(x: 12, y: 4.5 + CGFloat(indexPath.item) * kAudioTagCellHeight)
                tagPlayButton.frame.origin = buttonOrigin
                tagPlayButton.isHidden = false
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AudioTagInfoCell(info: tagSources[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        unFoldCellAt(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tagSources[indexPath.item].height
    }
}

extension AudioSectionViewController: AVAudioRecorderDelegate {
    // TODO: - 录音异常、中断的处理
}
