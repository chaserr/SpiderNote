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
                if !foldButton.isDescendant(of: self) {
                    addSubview(foldButton)
                }
            } else {
                foldButton.removeFromSuperview()
            }
        }
    }
    
    fileprivate var folding = false
    
    fileprivate lazy var foldButton: UIButton = {
        let button = UIButton(frame: CGRect(x: (kScreenWidth - kMindFoldButtonSize)/2, y: (kMindSeparatorHeight - kMindFoldButtonSize)/2, width: kMindFoldButtonSize, height: kMindFoldButtonSize))
        button.setBackgroundImage(UIImage(named: "mind_unfold_button"), for: UIControlState())
        button.addTarget(self, action: #selector(fold), for: .touchUpInside)
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    func fold() {
        foldButtonHandler()
        if folding {
            folding = false
            foldButton.transform = CGAffineTransform.identity
        } else {
            folding = true
            foldButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        }
    }
    
    init(foldable: Bool) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        isUserInteractionEnabled = true
        self.foldable = foldable
        
        if foldable {
            addSubview(foldButton)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: kMindSeparatorHeight / 2))
        path.addLine(to: CGPoint(x: kScreenWidth, y: kMindSeparatorHeight / 2))
        
        UIColor.color(withHex: 0xf2f2f2).setStroke()
        path.lineWidth = CGFloat(1.0)
        path.stroke()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
