//
//  ProjectCollectionView.swift
//  Spider
//
//  Created by ooatuoo on 16/7/22.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

private let cellID = "ProjectCollectionViewCell"

class ProjectCollectionView: UICollectionView {
    
    init() {
        
        let offset = CGFloat(5)
        let width = (kScreenWidth - offset * 3) / 2
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width, height: width * 1.2)
        layout.minimumLineSpacing = offset
        layout.minimumInteritemSpacing = offset
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        
        super.init(frame: CGRectZero, collectionViewLayout: layout)
        
        backgroundColor = SpiderConfig.Color.Line
        showsVerticalScrollIndicator = false
        keyboardDismissMode = .OnDrag
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
