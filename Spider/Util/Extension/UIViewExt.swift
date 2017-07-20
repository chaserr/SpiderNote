//
//  UIViewExt.swift
//  SwiftTester
//
//  Created by ZhijieLi on 15/5/28.
//  Copyright (c) 2015年 ZhijieLi. All rights reserved.
//

/// 先只做单击事件的监听
// NSValue


import UIKit

var blockActionDict: [String : (() -> ())] = [:]

extension UIView {
    fileprivate func whenTouch(NumberOfTouche touchNumbers: Int,NumberOfTaps tapNumbers: Int) -> Void {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTouchesRequired = touchNumbers
        tapGesture.numberOfTapsRequired = tapNumbers
        tapGesture .addTarget(self, action: #selector(UIView.tapActions))
        self.addGestureRecognizer(tapGesture)
    }
    
    func whenTapped(_ action :@escaping (() -> Void)) {
        // 手势-一次点击
        _addBlock(NewAction: action)
        whenTouch(NumberOfTouche: 1, NumberOfTaps: 1)
    }

    
    func tapActions() {
        // 执行action
        _excuteCurrentBlock()
    }


    fileprivate func _addBlock(NewAction newAction:@escaping ()->()) {
        let key = String(describing: NSValue(nonretainedObject: self))
        blockActionDict[key] = newAction
    }

    fileprivate func _excuteCurrentBlock(){
        let key = String(describing: NSValue(nonretainedObject: self))
        let block = blockActionDict[key]
        block!()
    }

}

extension UIView{
    @discardableResult
    func addSubLayerWithFrame(_ frame:CGRect, color:CGColor) -> CALayer {
        let layer:CALayer = CALayer()
        layer.frame = frame
        layer.backgroundColor = color
        self.layer.addSublayer(layer)
        return layer
    }
    
    func addBottomFillLineWithColor(_ color:CGColor) -> CALayer {
        return addSubLayerWithFrame(CGRect(x: 0, y: self.h - 0.5, width: self.w, height: 0.5), color: color)

    
    }
}
