//
//  UndocBoxCollectionView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/16.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import SnapKit

class UndocBoxCollectionView: UICollectionView {
    var bottomConstraint: Constraint? = nil
    
    var beEditing = false {
        
        didSet {
            
            if beEditing {
                
                bottomConstraint?.updateOffset(-60)
                backgroundColor = UIColor.color(withHex: 0xc1c1c1)
                
                let layout = collectionViewLayout as! UICollectionViewFlowLayout
                layout.minimumInteritemSpacing = 4
                layout.minimumLineSpacing = 4
                layout.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4)
                layout.itemSize = CGSize(width: kScreenWidth / 2 - 6, height: kScreenWidth / 2 - 6)
                
            } else {
                
                bottomConstraint?.updateOffset(0)
                backgroundColor = UIColor.white
                
                let layout = collectionViewLayout as! UICollectionViewFlowLayout
                layout.itemSize = CGSize(width: kScreenWidth / 2, height: kScreenWidth / 2)
                layout.sectionInset = UIEdgeInsets.zero
                layout.minimumInteritemSpacing = 0
                layout.minimumLineSpacing = 0
            }
        }
    }
    
    init() {
        
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: kScreenWidth / 2, height: kScreenWidth / 2)
        layout.headerReferenceSize = CGSize(width: kBoxHeaderHeight, height: kBoxHeaderHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        if #available(iOS 9.0, *) {
            layout.sectionHeadersPinToVisibleBounds = true
        }
        
        super.init(frame: CGRect.zero, collectionViewLayout: layout)
        
        backgroundColor = UIColor.white
        showsVerticalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
