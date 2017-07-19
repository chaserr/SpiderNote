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
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 46))
        
        textAlignment = .center
        font = UIFont.systemFont(ofSize: 18)
        backgroundColor = UIColor.clear
        textColor = UIColor.color(withHex: 0x282828)
        text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
