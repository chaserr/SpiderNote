//
//  AudioTitleView.swift
//  Spider
//
//  Created by 童星 on 5/24/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class AudioTitleView: UIView {
    
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
    fileprivate var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 15, y: kStatusBarHeight - 3, width: kScreenWidth - 30, height: kAudioTitleHeight - kStatusBarHeight))
        label.font = SpiderConfig.Font.Title
        label.textColor = SpiderConfig.Color.DarkText
        return label
    }()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kAudioTitleHeight))
        
        backgroundColor = UIColor.white
        
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: frame.height - 1))
        path.addLine(to: CGPoint(x: frame.width, y: frame.height - 1))

        path.lineWidth = 1.0
        SpiderConfig.Color.Line.setStroke()
        path.stroke()
    }
}
