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
                isHidden = true
                
            } else {
                
                if newValue != count {
                    
                    isHidden = false
                    var fontSize = CGFloat(11)
                    
                    switch newValue {
                    case 1 ... 9:
                        fontSize = 11
                    case 10 ... 99:
                        fontSize = 8
                    default:
                        break
                    }
                    
                    font = UIFont.systemFont(ofSize: fontSize)
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        
                        self.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                        self.text = newValue > 99 ? "99+" : "\(newValue)"
                        
                    }, completion: { done in
                            
                        UIView.animate(withDuration: 0.2, animations: {
                            self.transform = CGAffineTransform.identity
                        })
                    })
                }
            }
        }
    }

    init() {
        super.init(frame: CGRect(x: 30, y: 4, width: 14, height: 14))
        
        isHidden = true
        layer.cornerRadius = 7
        layer.masksToBounds = true
        font = UIFont.systemFont(ofSize: 11)
//        adjustsFontSizeToFitWidth = true
        textAlignment = .center
        textColor = UIColor.white
        backgroundColor = UIColor.red
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
