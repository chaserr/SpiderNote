//
//  OutlineHeaderView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/30.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

class OutlineHeaderView: UIView {

    var putInHandler: (() -> Void)?
    var addHandler: ((String, MindType) -> Void)?
    
    private var state: OutlineState = .MoveMind
    
    private lazy var putInButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 10, y: (kOutlineCellHeight - 35) / 2, width: 85, height: 35))
        button.setImage(UIImage(named: "outline_label"), forState: .Normal)
        button.addTarget(self, action: #selector(putInButtonClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 20 + 85, y: (kOutlineCellHeight - 30) / 2, width: 30, height: 30))
        button.setImage(UIImage(named: "outline_done"), forState: .Normal)
        button.addTarget(self, action: #selector(doneButtonClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 20 + 85, y: (kOutlineCellHeight - 30) / 2, width: 30, height: 30))
        button.setImage(UIImage(named: "outline_more"), forState: .Normal)
        button.addTarget(self, action: #selector(moreButtonClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    init(state: OutlineState) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kOutlineCellHeight))
        self.state = state
        
        if state != .MoveMind {
            moreButton.origin.x = 20
        } else {
            addSubview(putInButton)
        }
        
        addSubview(moreButton)
    }
    
    func putInButtonClicked() {
        if !doneButton.isDescendantOfView(self) {
            UIView.animateWithDuration(0.3, animations: { 
                self.moreButton.frame.origin.x = 20 + 85 + 40
                self.addSubview(self.doneButton)
            })
        }
    }
    
    func doneButtonClicked() {
        guard let vc = APP_NAVIGATOR.topVC?.presentedViewController else { return }

        SpiderAlert.confirmOrCancel(title: "", message: "你确定将所选内容移入该项目下?", inViewController: vc, withConfirmAction: { [weak self] in
            self?.putInHandler?()
        })
    }
    
    func moreButtonClicked() {
        guard let currentVC = APP_NAVIGATOR.topVC?.presentedViewController else { return }
        
        let addView = OutlineNewView(state: state == .MoveMind ? .NewMind : .NewBoth)
        
        addView.doneHandler = { [weak self] (text, type) in
            self?.addHandler?(text, type)
        }
        
        addView.moveTo(currentVC.view)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
