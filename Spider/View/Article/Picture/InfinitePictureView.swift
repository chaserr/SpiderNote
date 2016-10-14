//
//  InfinitePictureView.swift
//  GuttlerPageControl
//
//  Created by Atuooo on 4/27/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit
import Kingfisher

private let cellID = "InfiniteCell"

class InfinitePictureView: UIView {

    private var picInfos = [PicInfo]()
    
    var collectionView: UICollectionView!
    private var pageControl: UIPageControl!
    
    private var prefetcher: ImagePrefetcher?

//    private var timer: NSTimer!
//    private var timerDuration: NSTimeInterval = 3.0
    
    private var currentIndex = 1
    private var pictureCount = 0
    
    init() {
        super.init(frame: CGRectZero)
        
        // handle dataSource
        picInfos = [PicInfo()]
        pictureCount = 1

        // set collection view
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kScreenWidth, height: 250)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .Horizontal
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 250), collectionViewLayout: layout)
        collectionView.pagingEnabled = true
        collectionView.bounces = false
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.layer.masksToBounds = true
        
        collectionView.registerClass(InfinitePictureViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
        
        // set page control
        pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = pictureCount
        pageControl.currentPage = 0
        addSubview(pageControl)
        
        pageControl.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(20)
        }
    }
    
    func prepareForReuse() {
        picInfos = [PicInfo()]
        pictureCount = 1
        
        collectionView.reloadData()
    }
    
    func update(picInfo: [PicInfo]) {
        
        /** 预加载 */
        var resources = [Resource]()
        
        let _ = picInfo.map({ info in
            if let url = info.url {
                resources.append(Resource(downloadURL: url, cacheKey: info.id))
            }
        })
        
        prefetcher = ImagePrefetcher(resources: resources)
        prefetcher?.start()
        
        /** update */
        
        if picInfo.count == 1 {
            
            picInfos = picInfo
            pictureCount = 1
            
            pageControl.numberOfPages = pictureCount
            collectionView.reloadData()
            
        } else {
            
            picInfos = picInfo
            
            picInfos.append(picInfo.first!)
            picInfos.insert(picInfo.last!, atIndex: 0)
            pictureCount = picInfo.count
            
            pageControl.numberOfPages = pictureCount
            collectionView.reloadData()
            
            collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: .None, animated: false)
            
            // set timer
//            timer = NSTimer(timeInterval: timerDuration, target: self, selector: #selector(updatePictureView), userInfo: nil, repeats: true)
//            timer.tolerance = timerDuration * 0.1
//            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        }
        
//        let prefetcher = ImagePrefetcher()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        prefetcher?.stop()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
//        if timer != nil {
//            timer.invalidate()
//            timer = nil
//        }
    }
    
// MARK: - timer function
    func updatePictureView() {
        if !collectionView.tracking && !collectionView.decelerating {
            currentIndex += 1
            collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0), atScrollPosition: .None, animated: true)
        }
    }
}

// MARK: - UICollectionView Delegate
extension InfinitePictureView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picInfos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as! InfinitePictureViewCell

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let cell = cell as? InfinitePictureViewCell else {
            return
        }
        
        cell.configureCellWith(picInfos[indexPath.item])
    }
}

// MARK: - UIScrollView Delegate 
extension InfinitePictureView {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let lastItemOffsetX = collectionView.contentSize.width - collectionView.frame.width
        let firstItemOffsetX = collectionView.frame.width
        
        if scrollView.contentOffset.x >= lastItemOffsetX {
            scrollView.contentOffset = CGPoint(x: frame.width, y: 0)
            currentIndex = 1
        } else if scrollView.contentOffset.x < firstItemOffsetX {
            scrollView.contentOffset = CGPoint(x: lastItemOffsetX - frame.width, y: 0)
            currentIndex = pictureCount
        } else {
            currentIndex = Int(collectionView.contentOffset.x / frame.width)
        }
        pageControl.currentPage = currentIndex - 1
        
//        timer = NSTimer(timeInterval: timerDuration, target: self, selector: #selector(updatePictureView), userInfo: nil, repeats: true)
//        timer.tolerance = timerDuration * 0.1
//        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if currentIndex == picInfos.count - 1 {
            collectionView.contentOffset = CGPoint(x: frame.width, y: 0)
            currentIndex = 1
        }
        pageControl.currentPage = currentIndex - 1
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        if timer != nil {
//            timer.invalidate()
//            timer = nil
//        }
    }
}
