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
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return action == #selector(copyText(_:))
    }

    func copyText(sender: AnyObject) -> Void {
        let pasterBoard = UIPasteboard.generalPasteboard()
        pasterBoard.string = self.text
    }
    
    func longPressHander() -> Void {
        self.userInteractionEnabled = true
        self.addLongPressGesture { (UILongPressGestureRecognizer) in
            self.becomeFirstResponder()
            let copyLink = UIMenuItem.init(title: "复制", action: #selector(self.copyText))
            UIMenuController.sharedMenuController().menuItems = [copyLink]
            UIMenuController.sharedMenuController().setTargetRect(self.frame, inView: self.superview!)
            UIMenuController.sharedMenuController().setMenuVisible(true, animated: true)
        }
    }

}
