//
//  OutlineTableView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/29.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

class OutlineTableView: UITableView {

    init() {
        super.init(frame: CGRect.zero, style: .plain)
        
        rowHeight = kOutlineCellHeight
//        sectionHeaderHeight = kOutlineCellHeight
        tableFooterView = UIView()
        separatorStyle = .none
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
