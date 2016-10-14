//
//  PicAddTextView.swift
//  Spider
//
//  Created by Atuooo on 6/1/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

private let enableColor = UIColor.color(withHex: 0x3e3e4f)
private let disableColor = UIColor.color(withHex: 0x9797a0)

class PicAddTextTagView: UIView {
    
    var doneHandler: ((String) -> Void)!
    var cancelHandler: (() -> Void)!
    
    lazy var textView: UITextView = {
        let view = UITextView(frame: CGRect(x: 10, y: 10, width: kScreenWidth - 20, height: 70))
        view.textColor = UIColor.blackColor()
        view.font = UIFont.systemFontOfSize(14)
        view.returnKeyType = .Done
        view.delegate = self
        view.enablesReturnKeyAutomatically = true
        return view
    }()
    
    lazy private var doneButton: UIButton = {
        let button = UIButton(frame: CGRect(x: kScreenWidth - 10 - 40, y: kTagTextViewH - 9 - 20, width: 40, height: 20))
        
        button.setTitle("完成", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(10)
        button.titleLabel?.textColor = UIColor.whiteColor()
        button.titleLabel?.textAlignment = .Center
        
        button.backgroundColor = enableColor
        button.layer.cornerRadius = 2.0
        button.addTarget(self, action: #selector(self.doneClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy private var cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 10, y: kTagTextViewH - 9 - 20, width: 40, height: 20))
        
        button.setTitle("取消", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(10)
        button.titleLabel?.textColor = UIColor.whiteColor()
        button.titleLabel?.textAlignment = .Center
        
        button.backgroundColor = enableColor
        button.layer.cornerRadius = 2.0
        button.addTarget(self, action: #selector(self.cancelClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    init(text: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        let bgView = UIView(frame: CGRect(x: 0, y: kScreenHeight - kTagTextViewH, width: kScreenWidth, height: kTagTextViewH))
        bgView.backgroundColor = UIColor.color(withHex: 0xf0f0f0)
        addSubview(bgView)
        
        textView.text = text
        bgView.addSubview(textView)
        
        if text.isEmpty {
            doneButton.enabled = false
            doneButton.backgroundColor = disableColor
        }
        bgView.addSubview(doneButton)
        
        bgView.addSubview(cancelButton)
    }
    
    func doneClicked() {
        doneHandler(textView.text)
    }
    
    func cancelClicked() {
        cancelHandler()
    }
    
    func didTap() {
//        (superview as! PicDetailView).exitAddTextTag()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PicAddTextTagView: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if textView.text.isEmpty {
            doneButton.enabled = false
            doneButton.backgroundColor = disableColor
        } else {
            doneButton.enabled = true
            doneButton.backgroundColor = enableColor
        }
        
        if text == "\n" {
            doneHandler(textView.text)
            return false
        }
        
        return true
    }
}