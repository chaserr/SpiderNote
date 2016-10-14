//
//  UndocHeaderView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/19.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class UndocHeaderView: UICollectionReusableView {
    
    private var beEditing = false
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor.color(withHex: 0x444444)

        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.color(withHex: 0xfafafa)
        
        addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.snp_makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(0, 17, 0, 16))
        }
    }
    
    func configureWith(time: String, beEditing: Bool = false) {
        self.beEditing = beEditing
        timeLabel.text = time.toUndocHeaderTime()
        backgroundColor = beEditing ? UIColor.clearColor() : UIColor.color(withHex: 0xfafafa)
    }
    
    override func drawRect(rect: CGRect) {
        
        if !beEditing {
            let path = UIBezierPath()
            path.moveToPoint(CGPointZero)
            path.addLineToPoint(CGPoint(x: kScreenWidth, y: 0))
            
            path.moveToPoint(CGPoint(x: 0, y: kBoxHeaderHeight))
            path.addLineToPoint(CGPoint(x: kScreenWidth, y: kBoxHeaderHeight))
            
            path.lineWidth = 1
            
            SpiderConfig.Color.Line.setStroke()
            path.stroke()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
