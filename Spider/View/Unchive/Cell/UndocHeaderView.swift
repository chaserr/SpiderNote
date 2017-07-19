//
//  UndocHeaderView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/19.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class UndocHeaderView: UICollectionReusableView {
    
    fileprivate var beEditing = false
    
    fileprivate var timeLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 14)
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
    
    func configureWith(_ time: String, beEditing: Bool = false) {
        self.beEditing = beEditing
        timeLabel.text = time.toUndocHeaderTime()
        backgroundColor = beEditing ? UIColor.clear : UIColor.color(withHex: 0xfafafa)
    }
    
    override func draw(_ rect: CGRect) {
        
        if !beEditing {
            let path = UIBezierPath()
            path.move(to: CGPoint.zero)
            path.addLine(to: CGPoint(x: kScreenWidth, y: 0))
            
            path.move(to: CGPoint(x: 0, y: kBoxHeaderHeight))
            path.addLine(to: CGPoint(x: kScreenWidth, y: kBoxHeaderHeight))
            
            path.lineWidth = 1
            
            SpiderConfig.Color.Line.setStroke()
            path.stroke()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
