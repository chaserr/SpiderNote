//
//  ArticleUndocBoxView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/25.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

private let boxWidth    = kScreenWidth * 0.8
private let headID      = "ArticleUndocHeaderCell"
private let textCellID  = "ArticelUndocBoxTextCell"
private let picCellID   = "ArticelUndocBoxPicCell"
private let audioCellID = "ArticelUndocBoxAudioCell"

protocol ArticleUndocBoxDelegate: class {
    func didBeginToDragSeciton(_ section: SectionObject, layout: UndocBoxLayout, ges: UILongPressGestureRecognizer)
    func didChange(_ ges: UILongPressGestureRecognizer)
    func didEndDrag(_ location: CGPoint)
    func didQuitUndocBox()
}

class ArticleUndocBoxView: UIView {
    
    weak var articleDelegate: ArticleUndocBoxDelegate?
    
    fileprivate var layoutPool = UndocBoxLayoutPool()
    fileprivate var unDocItems = [[SectionObject]]()
    fileprivate var catchedView: UIImageView!

    fileprivate var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: boxWidth / 2, height: boxWidth / 2)
        layout.headerReferenceSize = CGSize(width: kBoxHeaderHeight, height: kBoxHeaderHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        if #available(iOS 9.0, *) {
            layout.sectionHeadersPinToVisibleBounds = true
        }
        
        let rect = CGRect(x: kScreenWidth - boxWidth, y: 40, width: boxWidth, height: kScreenHeight - kStatusBarHeight - 40)
        let view = UICollectionView(frame: rect, collectionViewLayout: layout)
        view.backgroundColor = UIColor.white
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    fileprivate var toolBar: UIView = {
        let view = UIView(frame: CGRect(x: kScreenWidth - boxWidth, y: 0, width: boxWidth, height: 40))
        view.backgroundColor = UIColor.white
        return view
    }()
    
    fileprivate var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: boxWidth / 4, y: 0, width: boxWidth / 2, height: 40))
        label.text = "拖动碎片放入"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.backgroundColor = UIColor.white
        return label
    }()
    
    fileprivate lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 10, y: 0, width: 40, height: 40))
        button.imageEdgeInsets = UIEdgeInsetsMake(11, 8, 11, 10)
        button.setImage(UIImage(named: "article_unbox_back"), for: UIControlState())
        button.addTarget(self, action: #selector(removeFromSuperview), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(frame: CGRect(x: kScreenWidth, y: kStatusBarHeight, width: kScreenWidth, height: kScreenHeight - kStatusBarHeight))
        
        backgroundColor = UIColor(white: 0, alpha: 0.6)
        
        unDocItems = SpiderRealm.groupUndocItems()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UndocTextCell.self, forCellWithReuseIdentifier: textCellID)
        collectionView.register(UndocPicCell.self, forCellWithReuseIdentifier: picCellID)
        collectionView.register(UndocAudioCell.self, forCellWithReuseIdentifier: audioCellID)
        collectionView.register(UndocHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headID)
        
        toolBar.addSubview(titleLabel)
        toolBar.addSubview(backButton)
        addSubview(toolBar)
        addSubview(collectionView)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPress)))
    }
    
    func didLongPress(_ ges: UILongPressGestureRecognizer) {
        let location = ges.location(in: self.superview!)
        
        switch ges.state {
            
        case .began:
            
            guard let indexPath = collectionView.indexPathForItem(at: ges.location(in: collectionView)) else { return }
            
            let section = unDocItems[indexPath.section][indexPath.item]
            let layout = layoutPool.cellLayoutOfSection(section)
            
            articleDelegate?.didBeginToDragSeciton(section, layout: layout, ges: ges)
            
            backgroundColor = UIColor(white: 1, alpha: 0)

            UIView.animate(withDuration: 0.3, animations: {
                self.frame.origin.x = kScreenWidth
            })
            
        case .changed:
            
            articleDelegate?.didChange(ges)
            
        default:
            
            articleDelegate?.didEndDrag(location)
        }
    }
    
    func didTap(_ ges: UITapGestureRecognizer) {
        
        let location = ges.location(in: self)
        let rect = CGRect(x: 0, y: 0, width: kScreenWidth - boxWidth, height: kScreenHeight)
        
        if rect.contains(location) {
            removeFromSuperview()
        }
    }
    
    func moveTo(_ view: UIView) {
        view.addSubview(self)
        isHidden = false
        
        unDocItems = SpiderRealm.groupUndocItems()
        collectionView.reloadData()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = UIColor(white: 0, alpha: 0.6)
            self.frame.origin.x = 0
        }) 
    }
    
    override func removeFromSuperview() {
        backgroundColor = UIColor(white: 1, alpha: 0)
        articleDelegate?.didQuitUndocBox()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.x = kScreenWidth
        }, completion: { done in
            super.removeFromSuperview()
        }) 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ArticleUndocBoxView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return unDocItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return unDocItems[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = SectionType(rawValue: unDocItems[indexPath.section][indexPath.item].type) else { return UICollectionViewCell() }
        
        switch type {
            
        case .text:
            return collectionView.dequeueReusableCell(withReuseIdentifier: textCellID, for: indexPath) as! UndocTextCell
            
        case .pic:
            return collectionView.dequeueReusableCell(withReuseIdentifier: picCellID, for: indexPath) as! UndocPicCell
            
        case .audio:
            return collectionView.dequeueReusableCell(withReuseIdentifier: audioCellID, for: indexPath) as! UndocAudioCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let undocItem = unDocItems[indexPath.section][indexPath.item]
        let layout  = layoutPool.cellLayoutOfSection(undocItem)
        
        guard let type = SectionType(rawValue: undocItem.type) else { return }
        
        switch type {
            
        case .text:
            guard let cell = cell as? UndocTextCell else { return }
            cell.configureWithInfo(layout)
            
        case .pic:
            guard let cell = cell as? UndocPicCell else { return }
            cell.configureWithInfo(layout)
            
        case .audio:
            guard let cell = cell as? UndocAudioCell else { return }
            cell.configureWithInfo(layout)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headID, for: indexPath) as! UndocHeaderView
        
        if let time = unDocItems[indexPath.section].first?.updateAt {
            header.configureWith(time)
        }
        
        return header
    }
}
