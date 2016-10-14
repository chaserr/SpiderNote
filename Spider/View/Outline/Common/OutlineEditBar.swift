//
//  OutlineEditBar.swift
//  Spider
//
//  Created by ooatuoo on 16/8/30.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

public enum OutlineEditBarState: Int {
    case NewBoth    = 0
    case JustPutIn  = 1
    case InNewMind  = 3
    case NewMind    = 4
}

class OutlineEditBar: UIView {
    var addHandler: ((String, MindType) -> Void)?
    var putInHandler: (() -> Void)?
    
    var level = 0
        
    var state = OutlineEditBarState.JustPutIn {
        didSet {
            switch state {
            case .JustPutIn:
                addButton.hidden = false
                putInButton.center.x = kOutlineEditBarW - 25
                putInButton.hidden = false
                
            case .NewMind, .NewBoth:
                
                putInButton.center.x = 25
                addButton.hidden = false
                putInButton.hidden = true
                
            case .InNewMind:
                
                putInButton.center.x = 25
                putInButton.hidden = false
                addButton.hidden = false
            }
        }
    }
    
    private var outlineState: OutlineState!
    
    private lazy var addButton: UIButton = {
        let button = UIButton(frame: CGRect(x: kOutlineEditBarW - 30 - 10, y: (kOutlineCellHeight - 30) / 2, width: 30, height: 30))
        button.setImage(UIImage(named: "outline_more"), forState: .Normal)
        button.addTarget(self, action: #selector(addButtonClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    private lazy var putInButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 10, y: (kOutlineCellHeight - 30) / 2, width: 30, height: 30))
        button.setImage(UIImage(named: "outline_put_in"), forState: .Normal)
        button.addTarget(self, action: #selector(putInButtonClicked), forControlEvents: .TouchUpInside)
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
