//
//  OutlineEditBar.swift
//  Spider
//
//  Created by ooatuoo on 16/8/30.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

public enum OutlineEditBarState: Int {
    case newBoth    = 0
    case justPutIn  = 1
    case inNewMind  = 3
    case newMind    = 4
}

class OutlineEditBar: UIView {
    var addHandler: ((String, MindType) -> Void)?
    var putInHandler: (() -> Void)?
    
    var level = 0
        
    var state = OutlineEditBarState.justPutIn {
        didSet {
            switch state {
            case .justPutIn:
                addButton.isHidden = false
                putInButton.center.x = kOutlineEditBarW - 25
                putInButton.isHidden = false
                
            case .newMind, .newBoth:
                
                putInButton.center.x = 25
                addButton.isHidden = false
                putInButton.isHidden = true
                
            case .inNewMind:
                
                putInButton.center.x = 25
                putInButton.isHidden = false
                addButton.isHidden = false
            }
        }
    }
    
    fileprivate var outlineState: OutlineState!
    
    fileprivate lazy var addButton: UIButton = {
        let button = UIButton(frame: CGRect(x: kOutlineEditBarW - 30 - 10, y: (kOutlineCellHeight - 30) / 2, width: 30, height: 30))
        button.setImage(UIImage(named: "outline_more"), for: UIControlState())
        button.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var putInButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 10, y: (kOutlineCellHeight - 30) / 2, width: 30, height: 30))
        button.setImage(UIImage(named: "outline_put_in"), for: UIControlState())
        button.addTarget(self, action: #selector(putInButtonClicked), for: .touchUpInside)
        return button
    }()

    init(state: OutlineState) {
        super.init(frame: CGRect(x: kScreenWidth - kOutlineEditBarW, y: 0, width: kOutlineEditBarW, height: kOutlineCellHeight))
        
        outlineState = state
        addSubview(addButton)
        addSubview(putInButton)
    }
    
    func putInButtonClicked() {
        guard let currentVC = APP_NAVIGATOR.topVC?.presentedViewController else { return }
        
        if level <= 4 {
            SpiderAlert.confirmOrCancel(title: "", message: "你确定将所选内容移入该\(outlineState.rawValue)?", inViewController: currentVC, withConfirmAction: { [weak self] in
                
                self?.putInHandler?()
            })
        } else {
            SpiderAlert.tellYou(message: "此层级下不能再添加 节点/长文 了哦！", inViewController: currentVC)
        }
    }
    
    func addButtonClicked() {
        guard let currentVC = APP_NAVIGATOR.topVC?.presentedViewController else { return }
        
        if level <= 4 {
            let addView = OutlineNewView(state: state)
            
            addView.doneHandler = { [weak self] (text, type) in
                self?.addHandler?(text, type)
            }
            
            addView.moveTo(currentVC.view)
            
        } else {
            
            SpiderAlert.tellYou(message: "此层级下不能再添加 节点/长文 了哦！", inViewController: currentVC)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
