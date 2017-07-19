//
//  CopyLabel.swift
//  Spider
//
//  Created by 童星 on 16/8/26.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

class CopyLabel: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()
        longPressHander()
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copyText(_:))
    }

    func copyText(_ sender: AnyObject) -> Void {
        let pasterBoard = UIPasteboard.general
        pasterBoard.string = self.text
    }
    
    func longPressHander() -> Void {
        self.isUserInteractionEnabled = true
        self.addLongPressGesture { (UILongPressGestureRecognizer) in
            self.becomeFirstResponder()
            let copyLink = UIMenuItem.init(title: "复制", action: #selector(self.copyText))
            UIMenuController.shared.menuItems = [copyLink]
            UIMenuController.shared.setTargetRect(self.frame, in: self.superview!)
            UIMenuController.shared.setMenuVisible(true, animated: true)
        }
    }

}
