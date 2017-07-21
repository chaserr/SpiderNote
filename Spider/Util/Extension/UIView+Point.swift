//
//  CGRectHelper.swift
//  Spider
//
//  Created by 童星 on 5/18/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import Foundation

extension UIView {
    func getOriginX() -> CGFloat {
        return frame.origin.x
    }
    
    func getEndX() -> CGFloat {
        return frame.origin.x + frame.width
    }
    
    func getCenter() -> CGPoint {
        return CGPoint(x: frame.width / 2, y: frame.height / 2)
    }
}

extension UIView {
    func addHeight(_ height: CGFloat) {
        frame.size = CGSize(width: frame.width, height: frame.height + height)
    }
    
    func addOffset(_ offset: CGPoint) {
        center = CGPoint(x: center.x + offset.x, y: center.y + offset.y)
    }
    
    func leftMove(_ distance: CGFloat) {
        frame = CGRect(x: frame.origin.x - distance, y: frame.origin.y, width: frame.width, height: frame.height)
    }
    
    func moveInRect(_ rect: CGRect, with point: CGPoint) {
        var finalPoint = point

        if point.x <= rect.origin.x {
            finalPoint = CGPoint(x: rect.origin.x, y: point.y)
        } else if (point.x + frame.width) >= rect.width {
            finalPoint = CGPoint(x: rect.width - frame.width, y: point.y)
        }
            
        if point.y <= rect.origin.y {
            finalPoint = CGPoint(x: finalPoint.x, y: rect.origin.y)
        } else if (point.y + frame.height) >= rect.height {
            finalPoint = CGPoint(x: finalPoint.x, y: rect.height - frame.height)
        }
        
        frame.origin = finalPoint
    }
    
    func shfit(_ offset: CGFloat) {
        center = CGPoint(x: center.x + offset, y: center.y)
    }
}

extension CGPoint {
    func addOffset(_ offset: CGPoint) -> CGPoint {
        return CGPoint(x: x + offset.x, y: y + offset.y)
    }
}
