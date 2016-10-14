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
        super.init(frame: CGRectZero, style: .Plain)
        
        rowHeight = kOutlineCellHeight
//        sectionHeaderHeight = kOutlineCellHeight
        tableFooterView = UIView()
        separatorStyle = .None
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
