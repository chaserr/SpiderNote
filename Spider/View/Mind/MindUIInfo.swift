//
//  MindUIInfo.swift
//  Spider
//
//  Created by ooatuoo on 16/8/13.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation

public struct MindUIInfo {
    
    var id: String
    var name: String
    var type: MindType
    var foldable = false
    var folding  = true
    var choosed = false
    var cellHeight: CGFloat = 95
    
    var labelHeight: CGFloat {
        didSet {
            if labelHeight > kMindTextLabelMinHeight {
                foldable = true
            } else {
                foldable = false
            }
        }
    }
    
//    init(id: String, name: String, type: MindType, labelHeight: CGFloat, cellHeight: CGFloat = 95, choosed: Bool = false) {
//        self.id   = id
//        self.name = name
//        self.type = type
//        self.labelHeight = labelHeight
//        self.cellHeight = cellHeight
//        self.choosed = choosed
//        
//        if labelHeight > kMindTextLabelMinHeight {
//            foldable = true
//        }
//    }
    
    init(mind: MindObject, isFirst: Bool) {
        self.id = mind.id
        self.name = mind.name
        self.type = MindType(rawValue: mind.type)!
        self.choosed = false
        
        let rect = mind.name.boundingRect(with: CGSize(width: kMindTextLabelWidth, height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: SpiderConfig.Font.Text], context: nil)
        
        self.labelHeight = rect.height
        self.cellHeight = isFirst ? 95 + kMindVerticalSpacing : 95
        
        if labelHeight > kMindTextLabelMinHeight {
            foldable = true
        }
    }
}
