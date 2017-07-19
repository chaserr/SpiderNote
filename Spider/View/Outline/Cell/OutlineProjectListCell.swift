//
//  OutlineProjectListCell.swift
//  Spider
//
//  Created by ooatuoo on 16/9/1.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

class OutlineProjectListCell: UITableViewCell {

    init(text: String, hightlight: Bool) {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        backgroundColor = UIColor.white
        
        textLabel?.text = text
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        textLabel?.textColor = hightlight ? UIColor.color(withHex: 0x43a047) : SpiderConfig.Color.DarkText
        
        imageView?.image =  UIImage(named: "outline_topbar_icon")?.withRenderingMode(.alwaysTemplate)
        imageView?.tintColor = hightlight ? UIColor.color(withHex: 0x43a047) : SpiderConfig.Color.DarkText
        
        if hightlight {
            let icon = UIImageView(image: UIImage(named: "outline_topbar_gou"))
            icon.frame = CGRect(x: kScreenWidth - 18 - 12, y: (50 - 12) / 2, width: 18, height: 12)
            contentView.addSubview(icon)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView?.frame = CGRect(x: 15, y: 15, width: 20, height: 20)
        textLabel?.frame = CGRect(x: 52, y: 0, width: kScreenWidth - 52, height: frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
