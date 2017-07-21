//
//  PicTopToolBar.swift
//  Spider
//
//  Created by 童星 on 6/2/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

private let cellID = "PicTopThumbCell"

protocol PicTopBarDelegate: class {
    func didSelectItemAtIndex(_ index: Int)
    func addPicClicked()
    func beginDeleting()
    func deletePicAtIndex(_ index: Int)
}

class PicTopBar: UIView {
    
    weak var barDelegate: PicTopBarDelegate!
    
    var cancelHandler:      (() -> Void)?
    var doneHandler:        (() -> Void)?
    var deleteHandler:      ((Int) -> Void)?
    var beginDeleteHandler: (() -> Void)?
    var selectPicHandler:   ((Int) -> Void)?
    var addPicHandler:      (() -> Void)?
    
    fileprivate var picSource = [UIImage?]()
    
    fileprivate var lastIndex = IndexPath(item: 0, section: 0)
    fileprivate var deleteIndex: IndexPath? = nil
    fileprivate var cellFrames = [CGRect]()
    
    fileprivate lazy var cancelButton : UIButton! = {
        let button = UIButton(frame: CGRect(x: kPicBackRO, y: kPicBackOy, width: kPicBackS, height: kPicBackS))
        button.setBackgroundImage(UIImage(named: "pic_cancel_button"), for: UIControlState())
        button.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var doneButton: UIButton! = {
        let button = UIButton(frame: CGRect(x: kPicDoneOx, y: kPicDoneOy, width: kPicDoneW, height: kPicDoneH))
        button.setBackgroundImage(UIImage(named: "pic_done_button"), for: UIControlState())
        button.addTarget(self, action: #selector(doneButtonClicked), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var thumbView: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kPicThumbS, height: kPicThumbS)
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        let view = UICollectionView(frame: CGRect(x: kPicThumbOx, y: kPicThumbOy - 10, width: kPicThumbsW, height: kPicThumbS+20), collectionViewLayout: layout)
        view.backgroundColor = UIColor.clear
        view.register(PicTopToolBarCell.self, forCellWithReuseIdentifier: cellID)
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    // MARK: - Init
    init(images: [UIImage?]) {
        
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kPicThumbH))
        backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        picSource = images
        picSource.append(UIImage(named: "pic_add_pic_button")!)
        
        addSubview(doneButton)
        addSubview(cancelButton)
        addSubview(thumbView)
                
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        thumbView.addGestureRecognizer(longPress)
    }
    
    func update(_ image: UIImage?, at index: Int) {   // 加载完图片资源后更新图片
        picSource[index] = image
        
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = thumbView.cellForItem(at: indexPath) as? PicTopToolBarCell else { return }
        
        cell.imageView.image = image
    }
    
    func didLongPress(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            
            cancelDelete()
            let location = sender.location(in: thumbView)
            
            for i in 0 ..< cellFrames.count {
                
                if cellFrames.count > 2 {
                    
                    if cellFrames[i].contains(location) {
                        
                        if i != picSource.count - 1 {
                            
                            beginDeleteHandler?()
                            
                            deleteIndex = IndexPath(item: i, section: 0)
                            
                            let cell = thumbView.cellForItem(at: deleteIndex!) as! PicTopToolBarCell
                            cell.toDelete()
                        }
                        
                        break
                    }
                    
                } else {
                    
                    SpiderAlert.alert(type: .OnlyOnePic, inView: self)
                }
            }
        }
    }
    
    func cancelDelete() {
        
        if deleteIndex != nil {
            let cell = thumbView.cellForItem(at: deleteIndex!) as! PicTopToolBarCell
            cell.cancelDelete()
            deleteIndex = nil
        }
    }

    // 添加照片后更新
    
    func addPics(_ images: [UIImage]) {
        
        let lastCell = thumbView.cellForItem(at: lastIndex) as! PicTopToolBarCell
        lastCell.deselct()
        
        lastIndex = IndexPath(item: picSource.count - 1, section: 0)
        picSource.removeLast()
        
        for image in images {
            picSource.append(image as UIImage?)
        }
        
        picSource.append(UIImage(named: "pic_add_pic_button")!)
        cellFrames = [CGRect]()
        thumbView.reloadData()
    }
    
    // 更新为当前显示的图片
    func updateIndex(_ index: Int) {
        
        let lastCell = thumbView.cellForItem(at: lastIndex) as! PicTopToolBarCell
        lastCell.deselct()
        
        lastIndex = IndexPath(item: index, section: 0)
        let cell = thumbView.cellForItem(at: lastIndex) as! PicTopToolBarCell
        cell.select()
    }
    
    // 重新载入
    func reset(_ images: [UIImage?]) {
        
        picSource = images
        picSource.append(UIImage(named: "pic_add_pic_button")!)
        
        cancelDelete()
        
        let lastCell = thumbView.cellForItem(at: lastIndex) as! PicTopToolBarCell
        lastCell.deselct()
        
        lastIndex = IndexPath(item: 0, section: 0)

        thumbView.reloadData()
    }
    
    func cancelButtonClicked() {
        cancelHandler?()
    }
    
    func doneButtonClicked() {
        doneHandler?()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PicTopBar: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if deleteIndex != nil {
            if indexPath == deleteIndex! {  // 删除选中的图片
                cancelDelete()
                
                // -Bug: cell复用
                let lastCell = collectionView.cellForItem(at: lastIndex) as! PicTopToolBarCell
                lastCell.deselct()
                
                picSource.remove(at: indexPath.item)
                
                // 当前选框的移动
                var moveIndex = lastIndex.item
                
                if moveIndex > indexPath.item  {
                    moveIndex -= 1
                }
                
                if moveIndex == indexPath.item {
                    if picSource.count == 2 {
                        moveIndex = 0
                    } else if moveIndex == picSource.count - 1 {
                        moveIndex -= 1
                    }
                }
                
                lastIndex = IndexPath(item: moveIndex, section: 0)
                
                cellFrames.removeAll()
                thumbView.reloadData()
                
                deleteHandler?(indexPath.item)
                
            } else {
                cancelDelete()
            }
            
        } else {
            
            let lastCell = collectionView.cellForItem(at: lastIndex) as! PicTopToolBarCell
            
            if indexPath.item == (picSource.count - 1) && picSource.count < 5 {
                
                addPicHandler?()
                
            } else {
                
                lastIndex = indexPath
                lastCell.deselct()
                
                let cell = collectionView.cellForItem(at: indexPath) as! PicTopToolBarCell
                cell.select()
                
                selectPicHandler?(indexPath.item)
            }
        }
    }
}

extension PicTopBar: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if picSource.count == 5 {
            
            return 4
            
        } else {
            
            return picSource.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PicTopToolBarCell
        
        if let image = picSource[indexPath.item] {
            cell.imageView.image = image
        } else {
            cell.imageView.image = UIImage(named: "article_tmp_image")
        }
        
        if indexPath == lastIndex {
            cell.select()
        }
        
        cellFrames.append(cell.frame)
        
        return cell
    }
}
