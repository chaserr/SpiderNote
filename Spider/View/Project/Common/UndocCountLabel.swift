//
//  UndocCountLabel.swift
//  Spider
//
//  Created by ooatuoo on 16/8/18.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class UndocCountLabel: UILabel {
    
    var count: Int = 0 {
        
        willSet {
            
            if newValue == 0 {
                hidden = true
                
            } else {
                
                if newValue != count {
                    
                    hidden = false
                    var fontSize = CGFloat(11)
                    
                    switch newValue {
                    case 1 ... 9:
                        fontSize = 11
                    case 10 ... 99:
                        fontSize = 8
                    default:
                        break
                    }
                    
                    font = UIFont.systemFontOfSize(fontSize)
                    
                    UIView.animateWithDuration(0.2, animations: {
                        
                        self.transform = CGAffineTransformMakeScale(1.6, 1.6)
                        self.text = newValue > 99 ? "99+" : "\(newValue)"
                        
                    }, completion: { done in
                            
                        UIView.animateWithDuration(0.2, animations: {
                            self.transform = CGAffineTransformIdentity
                        })
                    })
                }
            }
        }
    }

    init() {
        super.init(frame: CGRect(x: 30, y: 4, width: 14, height: 14))
        
        hidden = true
        layer.cornerRadius = 7
        layer.masksToBounds = true
        font = UIFont.systemFontOfSize(11)
//        adjustsFontSizeToFitWidth = true
        textAlignment = .Center
        textColor = UIColor.whiteColor()
        backgroundColor = UIColor.redColor()
    }
    
//    override func intrinsicContentSize() -> CGSize {
//        print("super text rect")
//        super.intrinsicContentSize()
//        return CGSize(width: 6, height: 6)
//    }
    
//    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
//        
//        return super.textRectForBounds(CGRectInset(bounds, 4, 4), limitedToNumberOfLines: numberOfLines)
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
