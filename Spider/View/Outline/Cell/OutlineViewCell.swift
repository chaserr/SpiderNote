//
//  OutlineViewCell.swift
//  Spider
//
//  Created by ooatuoo on 16/8/29.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

private let xDiff = CGFloat(20)
private let iconS = CGFloat(24)
private let yCenter = kOutlineCellHeight / 2
private let yOpenLineH = (kOutlineCellHeight - iconS) / 2 - 2
private let yOpenLineY = kOutlineCellHeight - yOpenLineH

class OutlineViewCell: UITableViewCell {
    
    private var icon: UIButton = {
        let button = UIButton()
        button.contentMode = .ScaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.userInteractionEnabled = false
        button.adjustsImageWhenHighlighted = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var xLine: UIImageView = {
        let view = UIImageView(image: UIImage(named: "outline_xline"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var label: UILabel = {
        let label = UILabel()
        label.font = SpiderConfig.Font.Title
        label.textColor = SpiderConfig.Color.DarkText
        label.lineBreakMode = .ByTruncatingMiddle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(mind: MindObject, status: OutlineStatus, choosed: Bool) {
        super.init(style: .Default, reuseIdentifier: nil)
        selectionStyle = .None
        label.text = mind.name

        icon.setBackgroundImage(UIImage(named: mind.type == 0 ? "outline_mind" : "outline_article"), forState: .Normal)
        
        if mind.foldable {
            icon.setImage(UIImage(named: status == .Closed ? "outline_unfold" : "outline_fold"), forState: .Normal)
            
            if status == .Opened {
                let yLine = UIImageView(image: UIImage(named: "outline_yline"))
                yLine.frame = CGRect(x: xDiff * CGFloat(mind.level) + iconS / 2, y: yOpenLineY, width: 0.5, height: yOpenLineH)
                contentView.addSubview(yLine)
            }
        }
        
        label.textColor = choosed ? SpiderConfig.Color.Line : SpiderConfig.Color.DarkText
        contentView.addSubview(icon)
        contentView.addSubview(label)
        
        if mind.level > 1 {
            
            let fminds = mind.linkMinds
            
            for i in 0 ..< fminds.count {
                
                if fminds[i].isLast {
                    
                    if i == 0 {
                        let yLine = UIImageView(image: UIImage(named: "outline_yline"))
                        yLine.frame = CGRect(x: xDiff * CGFloat(fminds[i].level - 1) + iconS / 2, y: 0, width: 0.5, height: kOutlineCellHeight / 2 - 3)
                        contentView.addSubview(yLine)
                    }
                    
                } else {
                    
                    let yLine = UIImageView(image: UIImage(named: "outline_yline"))
                    yLine.frame = CGRect(x: xDiff * CGFloat(fminds[i].level - 1) + iconS / 2, y: 0, width: 0.5, height: kOutlineCellHeight)
                    contentView.addSubview(yLine)
                }
            }
            
            contentView.addSubview(xLine)
            
            xLine.snp_makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 7.5, height: 3))
                make.centerY.equalTo(contentView).offset(-2)
                make.right.equalTo(icon.snp_left)
            }
        }
        
        icon.snp_makeConstraints { (make) in
            make.left.equalTo(xDiff * CGFloat(mind.level))
            make.centerY.equalTo(contentView)
            make.size.equalTo(iconS)
        }
        
        label.snp_makeConstraints { (make) in
            make.left.equalTo(icon.snp_right).offset(8)
            make.right.equalTo(-kOutlineEditBarW)
            make.top.bottom.equalTo(contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
