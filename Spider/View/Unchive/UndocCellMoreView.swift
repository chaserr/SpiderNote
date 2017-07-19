//
//  UndocCellMoreView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/22.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

enum UndocCellMoreType: Int, CustomStringConvertible {
    case move   = 0x66bb6a
    case delete = 0xf16c6c
    case more   = 0x555555
    
    var description: String {
        switch self {
        case .more:
            return "更多..."
        case .delete:
            return "删除"
        case .move:
            return "移动"
        }
    }
}

class UndocCellMoreView: UIView {
    typealias ButtonHandler = ((UndocCellMoreType) -> Void)?
    fileprivate var buttonHandler: ButtonHandler
    
    init(handler: ButtonHandler) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth / 2, height: kScreenWidth / 2))
        buttonHandler = handler
        backgroundColor = UIColor.color(withHex: 0xffffff, alpha: 0.9)
        
        addSubview(UndocCellMoreButton(type: .move, inView: self))
        addSubview(UndocCellMoreButton(type: .delete, inView: self))
        addSubview(UndocCellMoreButton(type: .more, inView: self))
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    func buttonsClicked(_ sender: UIButton) {
        
        guard let type = UndocCellMoreType(rawValue: sender.tag) else { return }
        buttonHandler?(type)
        
        removeFromSuperview()
    }
    
    func didTap() {
        removeFromSuperview()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        isHidden = !bounds.contains(point)
        return super.hitTest(point, with: event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class UndocCellMoreButton: UIButton {
    
    init(type: UndocCellMoreType, inView view: UIView) {
        super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        
        switch type {
        case .move:
            center = CGPoint(x: kScreenWidth / 4, y: kScreenWidth / 4 - 36)
        case .delete:
            center = CGPoint(x: kScreenWidth / 4 - 45, y: kScreenWidth / 4 + 36)
        case .more:
            center = CGPoint(x: kScreenWidth / 4 + 45, y: kScreenWidth / 4 + 36)
        }
        
        backgroundColor = UIColor.color(withHex: type.rawValue)
        layer.cornerRadius = 30
        layer.masksToBounds = true
        
        setTitle(type.description, for: UIControlState())
        setTitleColor(SpiderConfig.Color.LightText, for: UIControlState())
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        tag = type.rawValue
        
        addTarget(view, action: #selector(UndocCellMoreView.buttonsClicked(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
