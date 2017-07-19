//
//  DrewHorizontalLineView.swift
//  Spider
//
//  Created by 童星 on 16/7/18.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

@IBDesignable
//TODO : Drawing HorizontalLine
final class DrewHorizontalLineView: UIView {

    
    @IBInspectable
    var lineColor: UIColor = UIColor.ViewBorderColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var lineWidth: CGFloat = 1.0 / UIScreen.main.scale {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var leftMargin: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var rightMargin: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var atBottom: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: Draw
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        lineColor.setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        
        context!.setLineWidth(lineWidth)
        
        let y: CGFloat
        let fullHeight = rect.height
        
        if atBottom {
            y = fullHeight - lineWidth * 0.5
        } else {
            y = lineWidth * 0.5
        }
        
        context!.move(to: CGPoint(x: leftMargin, y: y))
        context!.addLine(to: CGPoint(x: rect.width - rightMargin, y: y))
        
        context!.strokePath()
    }
}
