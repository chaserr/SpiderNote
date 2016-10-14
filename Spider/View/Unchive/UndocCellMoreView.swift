//
//  UndocCellMoreView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/22.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

enum UndocCellMoreType: Int, CustomStringConvertible {
    case Move   = 0x66bb6a
    case Delete = 0xf16c6c
    case More   = 0x555555
    
    var description: String {
        switch self {
        case .More:
            return "更多..."
        case .Delete:
            return "删除"
        case .Move:
            return "移动"
        }
    }
}

class UndocCellMoreView: UIView {
    typealias ButtonHandler = (UndocCellMoreType -> Void)?
    private var buttonHandler: ButtonHandler
    
    init(handler: ButtonHandler) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth / 2, height: kScreenWidth / 2))
        buttonHandler = handler
        backgroundColor = UIColor.color(withHex: 0xffffff, alpha: 0.9)
        
        addSubview(UndocCellMoreButton(type: .Move, inView: self))
        addSubview(UndocCellMoreButton(type: .Delete, inView: self))
        addSubview(UndocCellMoreButton(type: .More, inView: self))
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    func buttonsClicked(sender: UIButton) {
        
        guard let type = UndocCellMoreType(rawValue: sender.tag) else { return }
        buttonHandler?(type)
        
        removeFromSuperview()
    }
    
    func didTap() {
        removeFromSuperview()
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        hidden = !bounds.contains(point)
        return super.hitTest(point, withEvent: event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class UndocCellMoreButton: UIButton {
    
    init(type: UndocCellMoreType, inView view: UIView) {
        super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        
        switch type {
        case .Move:
            center = CGPoint(x: kScreenWidth / 4, y: kScreenWidth / 4 - 36)
        case .Delete:
            center = CGPoint(x: kScreenWidth / 4 - 45, y: kScreenWidth / 4 + 36)
        case .More:
            center = CGPoint(x: kScreenWidth / 4 + 45, y: kScreenWidth / 4 + 36)
        }
        
        backgroundColor = UIColor.color(withHex: type.rawValue)
        layer.cornerRadius = 30
        layer.masksToBounds = true
        
        setTitle(type.description, forState: .Normal)
        setTitleColor(SpiderConfig.Color.LightText, forState: .Normal)
        titleLabel?.font = UIFont.systemFontOfSize(14)
        
        tag = type.rawValue
        
        addTarget(view, action: #selector(UndocCellMoreView.buttonsClicked(_:)), forControlEvents: .TouchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
