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
    
    fileprivate var state: OutlineState = .MoveMind
    
    fileprivate lazy var putInButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 10, y: (kOutlineCellHeight - 35) / 2, width: 85, height: 35))
        button.setImage(UIImage(named: "outline_label"), for: UIControlState())
        button.addTarget(self, action: #selector(putInButtonClicked), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var doneButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 20 + 85, y: (kOutlineCellHeight - 30) / 2, width: 30, height: 30))
        button.setImage(UIImage(named: "outline_done"), for: UIControlState())
        button.addTarget(self, action: #selector(doneButtonClicked), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var moreButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 20 + 85, y: (kOutlineCellHeight - 30) / 2, width: 30, height: 30))
        button.setImage(UIImage(named: "outline_more"), for: UIControlState())
        button.addTarget(self, action: #selector(moreButtonClicked), for: .touchUpInside)
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
        if !doneButton.isDescendant(of: self) {
            UIView.animate(withDuration: 0.3, animations: { 
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
        
        let addView = OutlineNewView(state: state == .MoveMind ? .newMind : .newBoth)
        
        addView.doneHandler = { [weak self] (text, type) in
            self?.addHandler?(text, type)
        }
        
        addView.moveTo(currentVC.view)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
