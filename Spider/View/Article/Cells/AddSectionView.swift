//
//  AddSectionView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/4.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class AddSectionView: UIView {
    
    var addSectionHandler: (() -> Void)?
    
    private lazy var addMediaView: AddMediaView = {
        return AddMediaView(unDoc: false)
    }()
    
    private var addButton: UIButton = {
        let button = UIButton()
        let diff = (kArticlePlusHeight - 12) / 2
        button.imageEdgeInsets = UIEdgeInsetsMake(diff, diff, diff, diff)
        button.setImage(UIImage(named: "article_add_button"), forState: .Normal)
        return button
    }()
    
    init() {
        super.init(frame: CGRectZero)
        backgroundColor = UIColor.whiteColor()
        
        addButton.addTarget(self, action: #selector(addButtonClicked), forControlEvents: .TouchUpInside)
        
        addSubview(addButton)
        addButton.snp_makeConstraints { (make) in
            make.size.equalTo(kArticlePlusHeight)
            make.center.equalTo(self)
        }
    }
    
    func addButtonClicked() {
        addSectionHandler?()
        
        guard let currentVC = AppNavigator.instance?.topVC else { return }
        addMediaView.addTo(currentVC.view)
    }
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath()
        let lineY = kArticlePlusHeight / 2
        path.moveToPoint(CGPoint(x: 0, y: lineY))
        path.addLineToPoint(CGPoint(x: (kScreenWidth - 30) / 2, y: lineY))
        
        path.moveToPoint(CGPoint(x: (kScreenWidth - 30) / 2 + 30, y: lineY))
        path.addLineToPoint(CGPoint(x: kScreenWidth, y: lineY))
        
        path.lineWidth = 1
        SpiderConfig.Color.Line.setStroke()
        path.stroke()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
