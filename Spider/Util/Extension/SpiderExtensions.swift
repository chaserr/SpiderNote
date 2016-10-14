//
//  SpiderExtensions.swift
//  Spider
//
//  Created by Atuooo on 7/25/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import Foundation

extension UIView {
    func contains(point: CGPoint) -> Bool {
        return bounds.contains(point)
    }
    
    func contain(point: CGPoint) -> Bool {
        guard let point = superview?.convertPoint(point, toView: self) else {
            return false
        }
        
        return bounds.contains(point)
    }
    
    func getSnapshotImageView() -> UIImageView? {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        layer.renderInContext(context)
        
        let fullImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageView = UIImageView(image: fullImage)
        imageView.center = center
    
        return imageView
    }
    
    func animateMoveTo(point point: CGPoint, withScalor scalor: CGFloat) {
        
        UIView.animateWithDuration(0.1, animations: {
            
            self.frame.size = CGSize(width: self.frame.width * scalor, height: self.frame.height * scalor)
            self.center = point
            
        }) { done in
            
            self.layer.shadowRadius = 2.0
            self.layer.shadowOpacity = 0.25
            self.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
        }
    }
    
    class func move(view: UIView, toPoint point: CGPoint, withScalor scalor: CGFloat, completion: ( Bool -> Void)) {
        UIView.animateWithDuration(0.3, animations: {
            view.layer.shadowOpacity = 0
            view.frame.size = CGSize(width: view.frame.width * scalor, height: view.frame.height * scalor)
            view.center = point
            view.alpha = 0.0
        }) { done in
            view.removeFromSuperview()
            completion(done)
        }
    }
}

extension CGPoint {
    
    func toString() -> String {
        return "\(x):\(y)"
    }
}

extension String {
    func toTime() -> NSTimeInterval {   // "01:30" -> 90
        let range = rangeOfString(":")
        let min   = substringToIndex(range!.startIndex)
        let sec   = substringFromIndex(range!.endIndex)
        
        return NSTimeInterval(min)! * 60 + NSTimeInterval(sec)!
    }
    
    func toCGPoint() -> CGPoint {
        let range = self.rangeOfString(":")!
        let xPer = substringToIndex(range.startIndex)
        let yPer = substringFromIndex(range.endIndex)
        
        return CGPoint(x: xPer.toCGFloat(), y: yPer.toCGFloat())
    }
    
    func toInt() -> Int {
        return Int(self)!
    }
    
    func toCGFloat() -> CGFloat {
        let num = NSNumberFormatter().numberFromString(self)!
        return CGFloat(num.floatValue)
    }
    
    func toYearMonth() -> String {
        let end = endIndex.advancedBy(-1, limit: startIndex)
        let pos = startIndex.advancedBy(7, limit: end)
        return substringToIndex(pos)
    }
    
    func toYear() -> String {
        let end = endIndex.advancedBy(-1, limit: startIndex)
        let pos = startIndex.advancedBy(4, limit: end)
        return substringToIndex(pos)
    }
    
    func toMonth() -> String {
        let ym = toYearMonth()
        let end = ym.endIndex.advancedBy(-2, limit: ym.startIndex)
        return ym.substringFromIndex(end)
    }
    
    func isThisYear() -> Bool {
        let thisYear = NSDate().toYear()
        return thisYear == self.toYear()
    }
    
    func toUndocCellTime() -> String {
        let nsRange = NSMakeRange(5, 5)
        let md = (self as NSString).substringWithRange(nsRange)
        let changed = md.stringByReplacingOccurrencesOfString("-", withString: "/")
        return changed
    }
    
    func toSpiderURL() -> NSURL? {
        
        return nil
    }
    
    func toNSDefaultKey() -> String {
        return "Spider_Outline_Of_ProjectID: " + self
    }
    
    func toUndocHeaderTime() -> String {
        let thisMonth = NSDate().toMonth()
        let thisYear  = NSDate().toYear()
        
        if thisYear != toYear() {
            
            return "去年"
            
        } else {
            
            if toMonth() == thisMonth {
                return "本月"
            } else {
                return "\(toMonth().toInt())月"
            }
        }
    }
}

extension NSTimeInterval {
    func toMinSec() -> String {
        return String(format: "%02d:%02d", Int(self/60), Int(self%60))
    }
    
    func toDecimal() -> String {
        if Int(self/60) > 0 {
            return String(format: "%d.%d\"", Int(self/60), Int(self%60))
        } else {
            return String(format: "%d\"", Int(self))
        }
    }
}

extension Int {
    func toMinSec() -> String {
        return String(format: "%02d:%02d", Int(self/60), Int(self%60))
    }
}

extension Array {
//    mutating func swap(aIndex: Int, _ bIndex: Int) {
//        let a = self[aIndex]
//        removeAtIndex(aIndex)
//        insert(a, atIndex: bIndex)
//    }
}

extension NSDate {
    func toString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.stringFromDate(self)
    }
    
    func toYear() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.stringFromDate(self)
    }
    
    func toMonth() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.stringFromDate(self)
    }
}

extension UIColor {
    public class func color(withHex hex: NSInteger, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: ((CGFloat)((hex & 0xFF0000) >> 16))/255.0,
                       green: ((CGFloat)((hex & 0xFF00) >> 8))/255.0,
                       blue: ((CGFloat)(hex & 0xFF))/255.0, alpha: alpha)
    }
}

// random
func randomInRange(range: Range<Int>) -> CGFloat {
    let count = UInt32(range.endIndex - range.startIndex)
    return  CGFloat(arc4random_uniform(count)) + CGFloat(range.startIndex)
}
