//
//  ProjectViewCell.swift
//  Spider
//
//  Created by ooatuoo on 16/8/17.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class ProjectViewCell: UICollectionViewCell {
    
    var isFirst = true {
        didSet {
            if isFirst {
                
                color = 0x000000
                textLabel.text = "新增项目"
                textLabel.frame = CGRect(x: 0, y: kProjectCellWidth * 0.65, width: kProjectCellWidth, height: 40)
                addSubview(addView)
                
            } else {
                
                addView.removeFromSuperview()
                textLabel.center.y = kProjectCellWidth * 0.45
            }
        }
    }
    
    var color = 0x000000 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private lazy var addView: UIImageView = {
        let imageV = UIImageView(image: UIImage(named: "add_project_button"))
        imageV.frame = CGRect(x: kProjectCellWidth * 0.375, y: kProjectCellWidth * 0.4, width: kProjectCellWidth / 4, height: kProjectCellWidth / 4)
        return imageV
    }()
    
    var textLabel: UILabel = {
        let label           = UILabel(frame: CGRect(x: 10, y: 10, width: kProjectCellWidth * 0.6, height: kProjectCellWidth * 0.6))
        label.center.x      = kProjectCellWidth / 2
        label.font          = UIFont.boldSystemFontOfSize(18)
        label.textColor     = UIColor.color(withHex: 0x666666)
        label.textAlignment = .Center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.whiteColor()
        contentView.addSubview(textLabel)
    }
    
    override func drawRect(rect: CGRect) {
        if !isFirst {
            
            let path1 = UIBezierPath()
            let x = kProjectCellWidth
            path1.moveToPoint(CGPoint(x: 0, y: x * 0.78))
            path1.addLineToPoint(CGPoint(x: 0, y: x * 1.2))
            path1.addLineToPoint(CGPoint(x: x * 0.6, y: x * 1.2))
            path1.closePath()
            
            UIColor.color(withHex: color, alpha: 0.4).setFill()
            path1.fill()
            
            let path2 = UIBezierPath()
            path2.moveToPoint(CGPoint(x: 0, y: x * 1.2))
            path2.addLineToPoint(CGPoint(x: x, y: x * 1.2))
            path2.addLineToPoint(CGPoint(x: x, y: 0.6 * x))
            path2.closePath()
            
            UIColor.color(withHex: color, alpha: 0.7).setFill()
            path2.fill()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
