//
//  PicTextTagShowView.swift
//  Spider
//
//  Created by Atuooo on 6/2/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

private let heights = CGFloat(100)

class PicTextTagDetailView: UITextView {
    
    init(text: String) {
        super.init(frame: CGRect(x: 0, y: kScreenHeight - heights, width: kScreenWidth, height: heights), textContainer: nil)
        
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.text = text
        font = UIFont.systemFont(ofSize: 13)
        textColor = UIColor.white
        
        textContainerInset = UIEdgeInsets(top: 7, left: 10, bottom: 15, right: 10)
        isEditable = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
