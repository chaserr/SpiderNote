//
//  ArticleBottomBar.swift
//  Spider
//
//  Created by ooatuoo on 16/8/1.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class ArticleBottomBar: UIView {
    var backHandler: (() -> Void)?
    var unchiveHandler: (() -> Void)?
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.setImage(UIImage(named: "article_editor_back"), forState: .Normal)
        
        button.addTarget(self, action: #selector(backButtonClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    private lazy var unchiveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 7.5, bottom: 10, right: 7.5)
        button.setImage(UIImage(named: "article_editor_unchive"), forState: .Normal)
        
        button.addTarget(self, action: #selector(unchiveButtonClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    init() {
        super.init(frame: CGRect(x: 0, y: kScreenHeight - 44, w: kScreenWidth, h: 44))
        backgroundColor = UIColor.whiteColor()
        
        makeUI()
    }
    
    private func makeUI() {
        addSubview(backButton)
        addSubview(unchiveButton)
        
        backButton.snp_makeConstraints { (make) in
            make.size.equalTo(40)
            make.left.equalTo(6)
            make.centerY.equalTo(self)
        }
        
        unchiveButton.snp_makeConstraints { (make) in
            make.size.equalTo(40)
            make.right.equalTo(-11)
            make.centerY.equalTo(self)
        }
    }
    
    func backButtonClicked() {
        backHandler?()
    }
    
    func unchiveButtonClicked() {
        unchiveHandler?()
    }
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 1))
        path.addLineToPoint(CGPoint(x: frame.width, y: 1))
        path.lineWidth = 1.0
        SpiderConfig.Color.Line.setStroke()
        path.stroke()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
