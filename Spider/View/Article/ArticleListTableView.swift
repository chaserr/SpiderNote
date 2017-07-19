//
//  ArticleListTableView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/23.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit
import SnapKit

private let commonEdge = UIEdgeInsetsMake(kStatusBarHeight, 0, 44, 0)
private let editEdge   = UIEdgeInsetsMake(64, 4, 64, 4)

class ArticleListTableView: UITableView {
    var edgesContraint: Constraint? = nil
    var beEditing = false {
        
        didSet {
            
            backgroundColor = beEditing ? SpiderConfig.Color.EditTheme : UIColor.white
            edgesContraint?.updateInsets(amount: beEditing ? editEdge : commonEdge)
        }
    }

    init() {
        super.init(frame: CGRect.zero, style: .plain)

        backgroundColor = UIColor.white
        tableFooterView = UIView()
        separatorStyle  = .none
        bounces         = false
        
        showsVerticalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
