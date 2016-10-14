////
////  StructView.swift
////  Spider
////
////  Created by Atuooo on 5/13/16.
////  Copyright © 2016 oOatuo. All rights reserved.
////
//
//import UIKit
//
//class StructView: UIView {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    override func drawRect(rect: CGRect) {        
//        let path = UIBezierPath()
//        path.moveToPoint(CGPoint(x: 0, y: frame.size.height))
//        path.addLineToPoint(CGPoint(x: frame.size.width, y: frame.size.height))
//        
//        path.lineWidth = 1.1
//        UIColor.color(withHex: 0xf4f4f4).setStroke()
//        
//        path.stroke()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
