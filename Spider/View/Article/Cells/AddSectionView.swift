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
    
    fileprivate lazy var addMediaView: AddMediaView = {
        return AddMediaView(unDoc: false)
    }()
    
    fileprivate var addButton: UIButton = {
        let button = UIButton()
        let diff = (kArticlePlusHeight - 12) / 2
        button.imageEdgeInsets = UIEdgeInsetsMake(diff, diff, diff, diff)
        button.setImage(UIImage(named: "article_add_button"), for: UIControlState())
        return button
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        
        addButton.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
        
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
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        let lineY = kArticlePlusHeight / 2
        path.move(to: CGPoint(x: 0, y: lineY))
        path.addLine(to: CGPoint(x: (kScreenWidth - 30) / 2, y: lineY))
        
        path.move(to: CGPoint(x: (kScreenWidth - 30) / 2 + 30, y: lineY))
        path.addLine(to: CGPoint(x: kScreenWidth, y: lineY))
        
        path.lineWidth = 1
        SpiderConfig.Color.Line.setStroke()
        path.stroke()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
