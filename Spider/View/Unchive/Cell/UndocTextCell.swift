//
//  UndocTextCell.swift
//  Spider
//
//  Created by ooatuoo on 16/8/19.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class UndocTextCell: UndocBaseCell {
    
//    private var textView: UITextView = {
//        let textV = UITextView()
//        textV.userInteractionEnabled = false
//        textV.font = SpiderConfig.Font.Text
//        textV.textColor = SpiderConfig.Color.DarkText
//        textV.editable = false
//        textV.selectable = false
//        return textV
//    }()
    
    fileprivate var textLabel: UILabel = {
        let label = UILabel()
        label.font = SpiderConfig.Font.Text
        label.textColor = SpiderConfig.Color.DarkText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel.snp_makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsetsMake(20, 15, 30, 15))
        }
    }
    
    override func configureWithInfo(_ info: UndocBoxLayout, editing: Bool = false) {
        super.configureWithInfo(info, editing: editing)
        textLabel.text = info.text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
