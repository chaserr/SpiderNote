//
//  StructLevelItem.swift
//  Spider
//
//  Created by 童星 on 16/8/2.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import RealmSwift
class StructLevelItem: UIButton {
    
    var onClick = {(element:StructLevelItem) -> Void in}
    var currenMind:Object!
    
    // 重写setter方法，去掉高亮
    override var highlighted: Bool {
        get{
        
            return false
        }
        set{}
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        titleLabel?.numberOfLines = 1
        titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
