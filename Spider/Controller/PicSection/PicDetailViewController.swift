//
//  PicDetailViewController.swift
//  Spider
//
//  Created by 童星 on 5/30/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

private enum PicDetailStatus {
    case editing    // 编辑页
    case showing    // 浏览页
    case addAudio   // 正在添加音频标签
    case deleting   // 删除图片中
}

class PicDetailViewController: UIViewController {
    
    // MARK: - Some Info
    fileprivate var section: SectionObject?
    
    fileprivate var toShowTag: TagObject?
    
    fileprivate var picInfos = [PicSectionInfo]() {
        didSet {
            hasModified = true
        }
    }
    
    fileprivate var isNewSection = false
    
    fileprivate var deletedInfos = [PicSectionInfo]()
    
    fileprivate var picImageViews = [UIImageView]()
    
    fileprivate var tagViewPool = [String: PicTagView]()
    
    fileprivate var status = PicDetailStatus.editing
    
    fileprivate var hasModified = false
    
    fileprivate var tagLocation = CGPoint.zero   // 添加标签的位置
    fileprivate var tagPanOrigin = CGPoint()    // 用于标签移动时的计算
    
    fileprivate var showTag = true              // 浏览模式中隐藏和显示标签
    
    fileprivate var editToastID: String?        // 正在编辑的标签ID
    
    fileprivate var currentIndex: Int {     // 当前图片所在的位置
        return Int(picScrollView.contentOffset.x / kScreenWidth)
    }
    
    fileprivate var currentImageView: UIImageView {
        return picImageViews[currentIndex]
    }
    
    fileprivate var currentImageSize: CGSize {
        return currentImageView.frame.size
    }
    
    // MARK: - common views
    fileprivate var textTagDetailView: PicTextTagDetailView!
    fileprivate var playingAudioTag: PicAudioTagView? = nil  // 正在播放的音频标签
    
    fileprivate var editToast: PicTagEditToast! {
        didSet {
            
            editToast.editHandler = { [weak self] in
                self?.editTextTagClicked()
            }
            
            editToast.deleteHandler = { [weak self] in
                self?.deleteTagClicked()
            }
        }
    }
    
    fileprivate var addAudioTagView: PicAddAudioTagView! {
        didSet {
            
            addAudioTagView.cancelRecorderHandler = { [weak self] in
                self?.exitRecord()
            }
            
            addAudioTagView.saveRecorderHandler = { [weak self] (id, duration) in
                self?.saveRecord(id, duration: duration)
            }
        }
    }
    
    fileprivate var addTextTagView: SectionAddTextView! {
        didSet {
            addTextTagView.doneHandler = { [weak self] text in
                self?.editTextTagDone(text)
            }
        }
    }
    
    fileprivate lazy var editBar: PicTopBar! = {
        
        let bar = PicTopBar(images: self.picInfos.map({ $0.picInfo.image }))
        bar.isHidden = true
        self.view.addSubview(bar)
        
        bar.cancelHandler = { [weak self] in
            self?.cancelEdit()
        }
        
        bar.doneHandler = { [weak self] in
            self?.doneEdit()
        }
        
        bar.beginDeleteHandler = { [weak self] in
            self?.status = .deleting
        }
        
        bar.deleteHandler = { [weak self] index in
            self?.deletePicAt(index)
        }
        
        bar.selectPicHandler = { [weak self] index in
            self?.picScrollView.setContentOffset(CGPoint(x: CGFloat(index) * kScreenWidth, y: 0), animated: false)
        }
        
        bar.addPicHandler = { [weak self] in
            self?.choosePicToAdd()
        }
        
        return bar
    }()
    
    lazy fileprivate var browseBar: PicTopShowView! = {
        let bar = PicTopShowView(index: self.currentIndex, num: self.picInfos.count)
        bar.isHidden = true
        self.view.addSubview(bar)
        
        bar.backHandler = { [weak self] in
            
            if let navigator = self?.navigationController {
                navigator.popViewController(animated: true)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
        bar.editHandler = { [weak self] in
            self?.goToEdit()
        }
        
        return bar
    }()
    
    fileprivate lazy var picScrollView: PicScrollView = {
        let scrollV = PicScrollView(pageCount: self.picInfos.count)
        scrollV.delegate        = self
        self.view.addSubview(scrollV)
        
        return scrollV
    }()
    
    lazy fileprivate var addTagButton: UIButton = {
        let button = UIButton(frame: CGRect(x: kPicAddTagOx, y: kPicAddTagOy, width: kPicAddTagS, height: kPicAddTagS))
        button.setBackgroundImage(UIImage(named: "pic_add_tag_button"), for: UIControlState())
        button.isHidden = true
        self.view.addSubview(button)
        
        button.addTarget(self, action: #selector(addTagClicked), for: .touchUpInside)
        
        return button
    }()
    
    lazy fileprivate var addTagView: PicSelectTagTypeView! = {
        let view = PicSelectTagTypeView()
        view.isHidden = true
        self.view.addSubview(view)
        
        view.text.addTarget(self, action: #selector(addTextTagClicked), for: .touchUpInside)
        view.pic.addTarget(self, action: #selector(addPicTagClicked), for: .touchUpInside)
        view.audio.addTarget(self, action: #selector(addAudioTagClicked), for: .touchUpInside)
        
        return view
    }()

    lazy fileprivate var bottomView: PicBottomView = {
        let view = PicBottomView()
        view.isHidden = true
        self.view.addSubview(view)
        
        view.showTagButton.addTarget(self, action: #selector(showTagClicked), for: .touchUpInside)
        
        return view
    }()
    
    init(picSection: SectionObject? = nil, photos: [UIImage]? = nil, toShowTag: TagObject? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.section   = picSection
        self.toShowTag = toShowTag
        
        if let section = picSection  {  // 浏览图片段落
            
            picInfos = section.pics.map({ PicSectionInfo(object: $0) })
            
            hasModified = false
            
        } else {    // 新建图片段落
            
            guard let photos = photos else { return }
            
            picInfos = photos.map({ PicSectionInfo(photo: $0) })
            
            isNewSection = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Life Cycle
extension PicDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge()
        
        view.backgroundColor = SpiderConfig.Color.BackgroundDark
        
        if let _ = section {
            
            status = .showing
            picScrollView.isScrollEnabled = true
            
            bottomView.isHidden = true
            browseBar.isHidden = false
            editBar.isHidden = true    // 预先加载
            
        } else {
            
            status = .editing
            picScrollView.isScrollEnabled = false
            
            // 注意层级
            editBar.isHidden = false
            addTagButton.isHidden = false
            addTagView.isHidden = true
            
            navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        }
        
        makeUI()
        
        // tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        picScrollView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let tag = toShowTag, let ownerIndex = tag.picOwnerIndex else { return }
        
        picScrollView.setContentOffset(CGPoint(x: kScreenWidth * CGFloat(ownerIndex), y: 0), animated: true)
        didTap(tag.id)
        toShowTag = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.setStatusBarStyle(.default, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        print("preferred bar style")
        return .lightContent
    }
    
    func makeUI() {
        
        func addTagViews(_ tags: [String: PicTagInfo], toView superView: UIImageView, withImageSize imageSize: CGSize) {
            
            superView.resizeToFit(imageSize)
            let newSize = superView.frame.size
            
            for (id, tag) in tags {
                
                var tagView: PicTagView
                let per = tag.perXY
                
                let location = CGPoint(x: newSize.width * per.x, y: newSize.height * per.y)
                
                switch tag.type {
                    
                case .text:
                    tagView = PicTextTagView(location: location, text: tag.content!, direction: tag.direction, inSize: newSize)
                    
                case .pic:
                    tagView = PicPicTagView(location: location, picInfo: tag.picInfo!, direction: tag.direction, inSize: newSize)
                    
                case .audio:
                    tagView = PicAudioTagView(location: location, audioInfo: tag.audioInfo!, direction: tag.direction, inSize: newSize)
                }
                
                tagView.id = id
                tagView.delegate = self
                tagViewPool[id] = tagView
                
                superView.addSubview(tagView)
            }
        }
        
        /** pic scroll view */
        
        for i in 0 ..< picInfos.count {
            
            let picNode = picInfos[i]
            let centerP = CGPoint(x: kScreenWidth * (CGFloat(i) + 0.5), y: kPicDetailH / 2)
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kPicDetailH))
            imageView.isUserInteractionEnabled = true
            
            if let image = picNode.picInfo.image {
                
                imageView.image = image
                addTagViews(picNode.tags, toView: imageView, withImageSize: image.size)
                imageView.center = centerP
                
            } else {
                
                imageView.spider_showActivityIndicatorWhenLoading = true
                imageView.spider_setImageWith(picNode.picInfo, completion: { [weak self] image in
                    
                    guard let imageSize = image?.size else { return }
                    
                    self?.editBar.update(image, at: i)
                    
                    addTagViews(picNode.tags, toView: imageView, withImageSize: imageSize)
                    imageView.center = centerP
                })
            }
            
            picImageViews.append(imageView)
            picScrollView.addSubview(imageView)
        }
    }
    
    // MARK: - Gesture
    
    func tapped(_ sender: UITapGestureRecognizer) {
        
        switch status {
            
        case .deleting:
            status = .editing
            editBar.cancelDelete()
            
        case .editing:
            
            checkIfTagEditToastExist()
            
            if hasCurrentImageLoaded() {    // 若图片还没加载进来，不能添加标签
                let location = sender.location(in: currentImageView)
                
                if currentImageView.contains(location) {
                    tagLocation = location
                    addTagView.isHidden = false
                }
            }
            
        case .showing:
            
            if !checkIfTextTagDetailViewExist() {
                bottomView.isHidden = !bottomView.isHidden
            }
            
        case .addAudio:
            return
        }
    }
}

// MARK: - 浏览模式与编辑模式的切换
extension PicDetailViewController {
    
    func doneEdit() {    // 切换到浏览模式
        
        status = .showing
        picScrollView.isScrollEnabled = true
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        checkIfTagEditToastExist()
        
        bottomView.isHidden = true
        browseBar.isHidden = false
        browseBar.count = picInfos.count
        browseBar.currentIndex = currentIndex
        
        editBar.isHidden = true
        addTagButton.isHidden = true
        addTagView.isHidden = true
        
        /* 写入数据库 */
        saveToDataBase()
    }
    
    func goToEdit() {    // 切换到编辑模式
        
        status = .editing
        picScrollView.isScrollEnabled = false
        navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        checkIfTextTagDetailViewExist()
        
        if let tag = playingAudioTag {
            tag.stop()
        }
        
        bottomView.isHidden = true
        browseBar.isHidden = true
        
        // 注意显示层级
        editBar.isHidden = false
        editBar.updateIndex(currentIndex)
        
        addTagButton.isHidden = false
        addTagView.isHidden = true
        
        for (_, tagView) in tagViewPool {
            tagView.isHidden = false
        }
    }
    
    func showTagClicked() {     // 浏览模式中选择是否显示标签
        
        for (_, tagView) in tagViewPool {
            tagView.isHidden = showTag
        }
        
        showTag = !showTag
    }
    
    func cancelEdit() {      // 撤销等操作
        
        if isNewSection {
            
            SpiderAlert.confirmOrCancel(title: "", message: "确定放弃添加？", confirmTitle: "确定", cancelTitle: "取消", inViewController: self, withConfirmAction: { [weak self] in
                // TODO: - Clean useless source
                self?.dismiss(animated: true, completion: nil)
            }, cancelAction: { })
            
        } else {
            
            if hasModified {
                
                SpiderAlert.confirmOrCancel(title: "确定放弃修改?", message: "放弃修改，并回到上一次保存的状态？", confirmTitle: "确定", cancelTitle: "取消", inViewController: self, withConfirmAction: { [weak self] in
                    
                    self?.backToLastSaved()
                    
                }, cancelAction: { })
                
            } else {
                
                SpiderAlert.alert(title: "", message: "已经是上一次保存的状态", dismissTitle: "知道了", inViewController: self, withDismissAction: nil)
            }
        }
    }
    
    func backToLastSaved() {
        
        if let section = section, !isNewSection {
            picInfos = section.pics.map({ PicSectionInfo(object: $0) })
            
            for picView in picImageViews {
                picView.removeFromSuperview()
            }
            
            picImageViews.removeAll()
            
            tagViewPool.removeAll()
            
            makeUI()
            editBar.reset(picInfos.map({ $0.picInfo.image }))
        }
        
        hasModified = false
    }
    
    func saveToDataBase() {
        
        if isNewSection {
            
            isNewSection = false
            section = SpiderRealm.createPicSection(with: picInfos)
                        
        } else {
            
            guard let picSection = section, hasModified else { return }
            
            SpiderRealm.updatePicSection(picSection, with: picInfos)
            
            hasModified = false
        }
        
        SpiderAlert.alert(type: .SaveCompleted, inView: browseBar)

    }
    
    // MARK: - 图片的删除&添加
    
    func deletePicAt(_ index: Int) {
        status = .editing
        checkIfTagEditToastExist()
        
        deletedInfos.append(picInfos[index])
        picInfos.remove(at: index)
        
        picImageViews[index].removeFromSuperview()
        picImageViews.remove(at: index)
        
        for i in index ..< picInfos.count {
            picImageViews[i].shfit(-kScreenWidth)
        }
        
        var moveIndex = currentIndex
        
        if moveIndex > index {
            moveIndex -= 1
        }
        
        if moveIndex == index {
            if picInfos.count == 1 {
                moveIndex = 0
            } else if moveIndex == picInfos.count {
                moveIndex -= 1
            }
        }
                
        picScrollView.contentSize = CGSize(width: kScreenWidth * CGFloat(picInfos.count), height: kPicDetailH)
        picScrollView.setContentOffset(CGPoint(x: kScreenWidth * CGFloat(moveIndex), y: 0), animated: false)
    }
    
    func choosePicToAdd() {
        let count = MaxPicCount - picInfos.count
        
        let picker = TZImagePickerController(maxCount: count) { [weak self] photos in
            
            self?.addPics(photos)
            self?.editBar.addPics(photos)
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func addPics(_ images: [UIImage]) {
        
        for image in images {
            picInfos.append(PicSectionInfo(photo: image))
            
            let imageView = UIImageView()
            imageView.isUserInteractionEnabled = true
            imageView.resizeToFit(image.size)
            imageView.image = image
            
            imageView.center = CGPoint(x: kScreenWidth * (CGFloat(picInfos.count) - 0.5), y: kPicDetailH / 2)
            picImageViews.append(imageView)
            picScrollView.addSubview(imageView)
        }
        
        let offsetX = kScreenWidth * CGFloat(picInfos.count - images.count)
        picScrollView.contentSize = CGSize(width: kScreenWidth * CGFloat(picInfos.count), height: kPicDetailH)
        picScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }
}

// MARK: - 标签相关操作

extension PicDetailViewController {
    
    // MARK: - 添加标签按钮
    func addTagClicked() {
        if status == .deleting {
            status = .editing
            
        } else {
            
            checkIfTagEditToastExist()
            addTagView.isHidden = false
            
            // 放在中间区域
            tagLocation = CGPoint(x: currentImageView.frame.width / 2 + randomInRange(0...20), y: currentImageView.frame.height / 2 + randomInRange(0...20))
        }
    }
    
    func addTag(_ info: PicTagInfo) {
        var tagView: PicTagView
        
        switch info.type {
            
        case .text:
            tagView = PicTextTagView(location: info.perXY, text: info.content!, direction: .none, inSize: currentImageSize)
            
        case .pic:
            tagView = PicPicTagView(location: info.perXY, picInfo: info.picInfo!, direction: .none, inSize: currentImageSize)
            
        case .audio:
            tagView = PicAudioTagView(location: info.perXY, audioInfo: info.audioInfo!, direction: .none, inSize: currentImageSize)
        }
        
        tagView.id = info.id
        tagView.delegate = self
        
        tagViewPool[info.id] = tagView
        
        var info = info
        info.direction = tagView.direction
        info.perXY = CGPoint(x: tagLocation.x / currentImageSize.width, y: tagLocation.y / currentImageSize.height)
        picInfos[currentIndex].tags[info.id] = info
        
        currentImageView.addSubview(tagView)
    }
    
    // MARK: - 添加文字标签
    func addTextTagClicked() {
        
        addTagView.isHidden = true
        
        addTextTagView = SectionAddTextView(text: "")
        view.addSubview(addTextTagView)
    }
    
    func editTextTagClicked() {
        guard let editID = editToastID else { return }
        
        let textTag = picInfos[currentIndex].tags[editID]!
        
        addTextTagView = SectionAddTextView(text: textTag.content!)
        view.addSubview(addTextTagView)
    }
    
    func editTextTagDone(_ text: String) {
        if let editID = editToastID {
            
            var textTag = picInfos[currentIndex].tags[editID]!
            textTag.content = text
            picInfos[currentIndex].tags.updateValue(textTag, forKey: editID)
            
            (tagViewPool[editID] as! PicTextTagView).text = text
            editToastID = nil
            
        } else {
            
            let tagInfo = PicTagInfo(id: UUID().uuidString, type: .text, perXY: tagLocation, content: text)
            addTag(tagInfo)
        }
    }
    
    // MARK: - 添加图片标签
    
    func addPicTagClicked() {
        let picker = TZImagePickerController(maxCount: 1) { [weak self] photos in
            self?.savePicTag(photos[0])
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func savePicTag(_ pic: UIImage) {
        let id = UUID().uuidString
        pic.saveToDisk(withid: id)
        
        let picInfo = PicInfo(id: id, image: pic)
        let tagInfo = PicTagInfo(id: id, type: .pic, perXY: tagLocation, picInfo: picInfo)
        
        addTag(tagInfo)
    }
    
    // MARK: - 添加音频标签
    func addAudioTagClicked() {
        status = .addAudio
        addTagButton.isHidden = true
        addTagView.isHidden = true
        
        addAudioTagView = PicAddAudioTagView()
        view.addSubview(addAudioTagView)
    }
    
    func exitRecord() {
        status = .editing
        addTagButton.isHidden = false
        
        addAudioTagView.removeFromSuperview()
    }
    
    func saveRecord(_ audioID: String, duration: String) {
        exitRecord()
        
        let audioInfo = AudioInfo(id: audioID, duration: duration)
        let tagInfo = PicTagInfo(id: audioID, type: .audio, perXY: tagLocation, audioInfo: audioInfo)
        addTag(tagInfo)
    }
    
    // MARK: - 删除标签
    
    func deleteTagClicked() {
        guard let deleteID = editToastID else { return }
        
        picInfos[currentIndex].tags[deleteID]?.state = .deleted
        
        tagViewPool[deleteID]?.removeFromSuperview()
        tagViewPool.removeValue(forKey: deleteID)
        
        editToastID = nil
    }
}

// MARK: - tag Delegate: 标签的相关手势处理
extension PicDetailViewController: PicTagDelegate {
    
    func didPan(_ id: String, sender: UIPanGestureRecognizer) {
        
        if status == .editing {
            checkIfTagEditToastExist()
            
            guard let tagView = tagViewPool[id] else { return }
            
            switch sender.state {
                
            case .began:
                if status != .deleting {    // 用于取消图片删除状态
                    tagPanOrigin = tagView.frame.origin
                }
                
            case .changed:
                if status != .deleting {
                    let offset = sender.translation(in: picScrollView)
                    let point = tagPanOrigin.addOffset(offset)
                    tagView.moveInRect(currentImageView.bounds, with: point)
                }
                
            default:
                if status != .deleting {
                    
                    picInfos[currentIndex].tags[id]?.perXY = tagView.perXY
                    
                } else {
                    status = .editing
                    editBar.cancelDelete()
                }
            }
        }
    }
    
    func didTap(_ id: String) {
        
        guard let tagView = tagViewPool[id] else { return }
        
        if status == .editing { // 编辑模式中点击后旋转
            checkIfTagEditToastExist()
            
            tagView.rotate()
            picInfos[currentIndex].tags[id]?.direction = tagView.direction
            picInfos[currentIndex].tags[id]?.perXY = tagView.perXY
        }
        
        if status == .showing { // 浏览模式中点击后查看具体内容
            checkIfTextTagDetailViewExist()
            
            switch tagView.type {
                
            case .text:
                
                let tag = tagView as! PicTextTagView
                textTagDetailView = PicTextTagDetailView(text: tag.text)
                view.addSubview(textTagDetailView)
                bottomView.isHidden = true
                
            case .pic:
                
                guard let tagImage = picInfos[currentIndex].tags[id]?.picInfo?.image else { return }
                let picTagDetailView = PicPicTagDetailView(image: tagImage)
                view.addSubview(picTagDetailView)
                
            case .audio:
                
                if playingAudioTag?.id != tagView.id {
                    playingAudioTag?.stop()
                }
                
                let audioTag = tagView as! PicAudioTagView
                audioTag.play()
                playingAudioTag = audioTag
            }
        }
        
        if status == .deleting {
            status = .editing
            editBar.cancelDelete()
        }
    }
    
    func didLongPress(_ id: String, sender: UILongPressGestureRecognizer) {
        
        guard let tagView = tagViewPool[id] else { return }
        
        let toastC = CGPoint(x: tagView.center.x, y: tagView.origin.y - kpicTagEditTH / 2 - 6)
        
        if status == .editing { // 只在编辑模式中长按编辑标签
            
            if sender.state == .began {
                
                checkIfTagEditToastExist()
                
                switch tagView.type {
                    
                case .text:
                    editToast = PicTagEditToast(center: toastC, canEdit: true)
                    
                default:
                    editToast = PicTagEditToast(center: toastC, canEdit: false)
                }
                
                editToastID = id
                currentImageView.addSubview(editToast)
            }
        }
        
        if status == .deleting {
            status = .editing
            editBar.cancelDelete()
        }
    }
    
    // MARK: - Common Helper
    
    func hasCurrentImageLoaded() -> Bool {
        if let _ = picInfos[currentIndex].picInfo.image {
            return true
        } else {
            return false
        }
    }
    
    @discardableResult func checkIfTagEditToastExist() -> Bool {   // 移除标签编辑 toast
        
        if let _ = editToastID, editToast.isDescendant(of: view) {
            
            editToast.removeFromSuperview()
            editToastID = nil
            return true
            
        } else {
            
            return false
        }
    }
    
   @discardableResult func checkIfTextTagDetailViewExist() -> Bool { // 移除文字标签展示
        
        if textTagDetailView != nil {
            
            textTagDetailView.removeFromSuperview()
            textTagDetailView = nil
            bottomView.isHidden = true
            
            return true
            
        } else {
            return false
        }
    }
}

// MARK: - ScrollView Delegate
extension PicDetailViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        checkIfTextTagDetailViewExist()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkIfTagEditToastExist()
        
        if browseBar != nil {
            browseBar.currentIndex = currentIndex
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

    }
}
