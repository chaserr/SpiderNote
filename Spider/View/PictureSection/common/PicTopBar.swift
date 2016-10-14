//
//  PicTopToolBar.swift
//  Spider
//
//  Created by Atuooo on 6/2/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

private let cellID = "PicTopThumbCell"

protocol PicTopBarDelegate: class {
    func didSelectItemAtIndex(index: Int)
    func addPicClicked()
    func beginDeleting()
    func deletePicAtIndex(index: Int)
}

class PicTopBar: UIView {
    
    weak var barDelegate: PicTopBarDelegate!
    
    var cancelHandler:      (() -> Void)?
    var doneHandler:        (() -> Void)?
    var deleteHandler:      (Int -> Void)?
    var beginDeleteHandler: (() -> Void)?
    var selectPicHandler:   (Int -> Void)?
    var addPicHandler:      (() -> Void)?
    
    private var picSource = [UIImage?]()
    
    private var lastIndex = NSIndexPath(forItem: 0, inSection: 0)
    private var deleteIndex: NSIndexPath? = nil
    private var cellFrames = [CGRect]()
    
    private lazy var cancelButton : UIButton! = {
        let button = UIButton(frame: CGRect(x: kPicBackRO, y: kPicBackOy, width: kPicBackS, height: kPicBackS))
        button.setBackgroundImage(UIImage(named: "pic_cancel_button"), forState: .Normal)
        button.addTarget(self, action: #selector(cancelButtonClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    private lazy var doneButton: UIButton! = {
        let button = UIButton(frame: CGRect(x: kPicDoneOx, y: kPicDoneOy, width: kPicDoneW, height: kPicDoneH))
        button.setBackgroundImage(UIImage(named: "pic_done_button"), forState: .Normal)
        button.addTarget(self, action: #selector(doneButtonClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    private lazy var thumbView: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kPicThumbS, height: kPicThumbS)
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        let view = UICollectionView(frame: CGRect(x: kPicThumbOx, y: kPicThumbOy - 10, width: kPicThumbsW, height: kPicThumbS+20), collectionViewLayout: layout)
        view.backgroundColor = UIColor.clearColor()
        view.registerClass(PicTopToolBarCell.self, forCellWithReuseIdentifier: cellID)
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
    
    func update(image: UIImage?, at index: Int) {   // 加载完图片资源后更新图片
        picSource[index] = image
        
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        guard let cell = thumbView.cellForItemAtIndexPath(indexPath) as? PicTopToolBarCell else { return }
        
        cell.imageView.image = image
    }
    
    func didLongPress(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .Began {
            
            cancelDelete()
            let location = sender.locationInView(thumbView)
            
            for i in 0 ..< cellFrames.count {
                
                if cellFrames.count > 2 {
                    
                    if CGRectContainsPoint(cellFrames[i], location) {
                        
                        if i != picSource.count - 1 {
                            
                            beginDeleteHandler?()
                            
                            deleteIndex = NSIndexPath(forItem: i, inSection: 0)
                            
                            let cell = thumbView.cellForItemAtIndexPath(deleteIndex!) as! PicTopToolBarCell
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
            let cell = thumbView.cellForItemAtIndexPath(deleteIndex!) as! PicTopToolBarCell
            cell.cancelDelete()
            deleteIndex = nil
        }
    }

    // 添加照片后更新
    
    func addPics(images: [UIImage]) {
        
        let lastCell = thumbView.cellForItemAtIndexPath(lastIndex) as! PicTopToolBarCell
        lastCell.deselct()
        
        lastIndex = NSIndexPath(forItem: picSource.count - 1, inSection: 0)
        picSource.removeLast()
        
        for image in images {
            picSource.append(image as UIImage?)
        }
        
        picSource.append(UIImage(named: "pic_add_pic_button")!)
        cellFrames = [CGRect]()
        thumbView.reloadData()
    }
    
    // 更新为当前显示的图片
    func updateIndex(index: Int) {
        
        let lastCell = thumbView.cellForItemAtIndexPath(lastIndex) as! PicTopToolBarCell
        lastCell.deselct()
        
        lastIndex = NSIndexPath(forItem: index, inSection: 0)
        let cell = thumbView.cellForItemAtIndexPath(lastIndex) as! PicTopToolBarCell
        cell.select()
    }
    
    // 重新载入
    func reset(images: [UIImage?]) {
        
        picSource = images
        picSource.append(UIImage(named: "pic_add_pic_button")!)
        
        cancelDelete()
        
        let lastCell = thumbView.cellForItemAtIndexPath(lastIndex) as! PicTopToolBarCell
        lastCell.deselct()
        
        lastIndex = NSIndexPath(forItem: 0, inSection: 0)

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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if deleteIndex != nil {
            if indexPath == deleteIndex! {  // 删除选中的图片
                cancelDelete()
                
                // -Bug: cell复用
                let lastCell = collectionView.cellForItemAtIndexPath(lastIndex) as! PicTopToolBarCell
                lastCell.deselct()
                
                picSource.removeAtIndex(indexPath.item)
                
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
                
                lastIndex = NSIndexPath(forItem: moveIndex, inSection: 0)
                
                cellFrames.removeAll()
                thumbView.reloadData()
                
                deleteHandler?(indexPath.item)
                
            } else {
                cancelDelete()
            }
            
        } else {
            
            let lastCell = collectionView.cellForItemAtIndexPath(lastIndex) as! PicTopToolBarCell
            
            if indexPath.item == (picSource.count - 1) && picSource.count < 5 {
                
                addPicHandler?()
                
            } else {
                
                lastIndex = indexPath
                lastCell.deselct()
                
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PicTopToolBarCell
                cell.select()
                
                selectPicHandler?(indexPath.item)
            }
        }
    }
}

extension PicTopBar: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if picSource.count == 5 {
            
            return 4
            
        } else {
            
            return picSource.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as! PicTopToolBarCell
        
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
