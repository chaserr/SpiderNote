//
//  PicTagView.swift
//  Spider
//
//  Created by 童星 on 6/1/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

@objc protocol PicTagDelegate {
    func didPan(_ id: String, sender: UIPanGestureRecognizer)
    func didTap(_ id: String)
    func didLongPress(_ id: String, sender: UILongPressGestureRecognizer)
}

class PicTagView: UIView {

    var id = ""
    var type = PicTagType.text
    var contentView: UIView!    // 用于翻转标签
    var direction = TagDirection.right
    
    var perXY: CGPoint {
        
        if direction == .right {
            return revertToPer(CGPoint(x: frame.origin.x + 5, y: frame.midY))
        } else {
            return revertToPer(CGPoint(x: frame.maxX - 5, y: frame.midY))
        }
    }
    
    fileprivate func revertToPer(_ point: CGPoint) -> CGPoint {
        
        guard let superView = superview else { return CGPoint.zero }
        return CGPoint(x: point.x / superView.frame.width, y: point.y / superView.frame.height)
    }
    
    weak var delegate: PicTagDelegate!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.masksToBounds = false
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        addGestureRecognizer(longPress)
    }
    
    func didTap() {
        delegate.didTap(id)
    }
    
    func didPan(_ sender: UIPanGestureRecognizer) {
        delegate.didPan(id, sender: sender)
    }
    
    func didLongPress(_ sender: UILongPressGestureRecognizer) {
        delegate.didLongPress(id, sender: sender)
    }
    
    func rotate() {
        switch direction {
            
        case .right:
            direction = .left
            
            transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            contentView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            
        case .left:
            direction = .right
            
            transform = CGAffineTransform.identity
            contentView.transform = CGAffineTransform.identity
            
        default:
            break
        }
        
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
