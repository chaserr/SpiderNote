//
//  MindSeparatorView.swift
//  Spider
//
//  Created by ooatuoo on 16/7/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class MindSeparatorView: UIView {
    
    var foldButtonHandler: (() -> Void)!
    var foldable = false {
        willSet {
            if newValue {
                if !foldButton.isDescendantOfView(self) {
                    addSubview(foldButton)
                }
            } else {
                foldButton.removeFromSuperview()
            }
        }
    }
    
    private var folding = false
    
    private lazy var foldButton: UIButton = {
        let button = UIButton(frame: CGRect(x: (kScreenWidth - kMindFoldButtonSize)/2, y: (kMindSeparatorHeight - kMindFoldButtonSize)/2, width: kMindFoldButtonSize, height: kMindFoldButtonSize))
        button.setBackgroundImage(UIImage(named: "mind_unfold_button"), forState: .Normal)
        button.addTarget(self, action: #selector(fold), forControlEvents: .TouchUpInside)
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    func fold() {
        foldButtonHandler()
        if folding {
            folding = false
            foldButton.transform = CGAffineTransformIdentity
        } else {
            folding = true
            foldButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        }
    }
    
    init(foldable: Bool) {
        super.init(frame: CGRectZero)
        backgroundColor = UIColor.whiteColor()
        userInteractionEnabled = true
        self.foldable = foldable
        
        if foldable {
            addSubview(foldButton)
        }
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: kMindSeparatorHeight / 2))
        path.addLineToPoint(CGPoint(x: kScreenWidth, y: kMindSeparatorHeight / 2))
        
        UIColor.color(withHex: 0xf2f2f2).setStroke()
        path.lineWidth = CGFloat(1.0)
        path.stroke()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
