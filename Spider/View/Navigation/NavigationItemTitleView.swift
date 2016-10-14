//
//  HomeTitleView.swift
//  Spider
//
//  Created by Atuooo on 5/10/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class NavigationItemTitleView: UILabel {
    
    init(title: String) {
        super.init(frame: CGRectMake(0, 0, 200, 46))
        
        textAlignment = .Center
        font = UIFont.systemFontOfSize(18)
        backgroundColor = UIColor.clearColor()
        textColor = UIColor.color(withHex: 0x282828)
        text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
