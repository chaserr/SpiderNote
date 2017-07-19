//
//  SpiderExtensions.swift
//  Spider
//
//  Created by Atuooo on 7/25/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import Foundation

extension UIView {
    func contains(_ point: CGPoint) -> Bool {
        return bounds.contains(point)
    }
    
    func contain(_ point: CGPoint) -> Bool {
        guard let point = superview?.convert(point, to: self) else {
            return false
        }
        
        return bounds.contains(point)
    }
    
    func getSnapshotImageView() -> UIImageView? {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        layer.render(in: context)
        
        let fullImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageView = UIImageView(image: fullImage)
        imageView.center = center
    
        return imageView
    }
    
    func animateMoveTo(point: CGPoint, withScalor scalor: CGFloat) {
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.frame.size = CGSize(width: self.frame.width * scalor, height: self.frame.height * scalor)
            self.center = point
            
        }, completion: { done in
            
            self.layer.shadowRadius = 2.0
            self.layer.shadowOpacity = 0.25
            self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        }) 
    }
    
    class func move(_ view: UIView, toPoint point: CGPoint, withScalor scalor: CGFloat, completion: @escaping ( (Bool) -> Void)) {
        UIView.animate(withDuration: 0.3, animations: {
            view.layer.shadowOpacity = 0
            view.frame.size = CGSize(width: view.frame.width * scalor, height: view.frame.height * scalor)
            view.center = point
            view.alpha = 0.0
        }, completion: { done in
            view.removeFromSuperview()
            completion(done)
        }) 
    }
}

extension CGPoint {
    
    func toString() -> String {
        return "\(x):\(y)"
    }
}

extension String {
    func toTime() -> TimeInterval {   // "01:30" -> 90
        let range = self.range(of: ":")
        let min   = substring(to: range!.lowerBound)
        let sec   = substring(from: range!.upperBound)
        
        return TimeInterval(min)! * 60 + TimeInterval(sec)!
    }
    
    func toCGPoint() -> CGPoint {
        let range = self.range(of: ":")!
        let xPer = substring(to: range.lowerBound)
        let yPer = substring(from: range.upperBound)
        
        return CGPoint(x: xPer.toCGFloat(), y: yPer.toCGFloat())
    }
    
    func toInt() -> Int {
        return Int(self)!
    }
    
    func toCGFloat() -> CGFloat {
        let num = NumberFormatter().number(from: self)!
        return CGFloat(num.floatValue)
    }
    
    func toYearMonth() -> String {
        let end = characters.index(endIndex, offsetBy: -1, limitedBy: startIndex)
        let pos = characters.index(startIndex, offsetBy: 7, limitedBy: end)
        return substring(to: pos)
    }
    
    func toYear() -> String {
        let end = characters.index(endIndex, offsetBy: -1, limitedBy: startIndex)
        let pos = characters.index(startIndex, offsetBy: 4, limitedBy: end)
        return substring(to: pos)
    }
    
    func toMonth() -> String {
        let ym = toYearMonth()
        let end = ym.characters.index(ym.endIndex, offsetBy: -2, limitedBy: ym.startIndex)
        return ym.substring(from: end)
    }
    
    func isThisYear() -> Bool {
        let thisYear = Date().toYear()
        return thisYear == self.toYear()
    }
    
    func toUndocCellTime() -> String {
        let nsRange = NSMakeRange(5, 5)
        let md = (self as NSString).substring(with: nsRange)
        let changed = md.replacingOccurrences(of: "-", with: "/")
        return changed
    }
    
    func toSpiderURL() -> URL? {
        
        return nil
    }
    
    func toNSDefaultKey() -> String {
        return "Spider_Outline_Of_ProjectID: " + self
    }
    
    func toUndocHeaderTime() -> String {
        let thisMonth = Date().toMonth()
        let thisYear  = Date().toYear()
        
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

extension TimeInterval {
    func toMinSec() -> String {
        return String(format: "%02d:%02d", Int(self/60), Int(self.truncatingRemainder(dividingBy: 60)))
    }
    
    func toDecimal() -> String {
        if Int(self/60) > 0 {
            return String(format: "%d.%d\"", Int(self/60), Int(self.truncatingRemainder(dividingBy: 60)))
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

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    func toYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
    
    func toMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self)
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
func randomInRange(_ range: CountableClosedRange<Int>) -> CGFloat {
    let count = UInt32(range.upperBound - range.lowerBound)
    return  CGFloat(arc4random_uniform(count)) + CGFloat(range.lowerBound)
}
