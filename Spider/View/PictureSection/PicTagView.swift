//
//  PicTagView.swift
//  Spider
//
//  Created by Atuooo on 6/1/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

@objc protocol PicTagDelegate {
    func didPan(id: String, sender: UIPanGestureRecognizer)
    func didTap(id: String)
    func didLongPress(id: String, sender: UILongPressGestureRecognizer)
}

class PicTagView: UIView {

    var id = ""
    var type = PicTagType.Text
    var contentView: UIView!    // 用于翻转标签
    var direction = TagDirection.Right
    
    var perXY: CGPoint {
        
        if direction == .Right {
            return revertToPer(CGPoint(x: frame.origin.x + 5, y: frame.midY))
        } else {
            return revertToPer(CGPoint(x: frame.maxX - 5, y: frame.midY))
        }
    }
    
    private func revertToPer(point: CGPoint) -> CGPoint {
        
        guard let superView = superview else { return CGPointZero }
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
    
    func didPan(sender: UIPanGestureRecognizer) {
        delegate.didPan(id, sender: sender)
    }
    
    func didLongPress(sender: UILongPressGestureRecognizer) {
        delegate.didLongPress(id, sender: sender)
    }
    
    func rotate() {
        switch direction {
            
        case .Right:
            direction = .Left
            
            transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            
        case .Left:
            direction = .Right
            
            transform = CGAffineTransformIdentity
            contentView.transform = CGAffineTransformIdentity
            
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
