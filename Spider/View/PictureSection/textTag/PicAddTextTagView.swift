//
//  PicAddTextView.swift
//  Spider
//
//  Created by 童星 on 6/1/16.
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
        view.textColor = UIColor.black
        view.font = UIFont.systemFont(ofSize: 14)
        view.returnKeyType = .done
        view.delegate = self
        view.enablesReturnKeyAutomatically = true
        return view
    }()
    
    lazy fileprivate var doneButton: UIButton = {
        let button = UIButton(frame: CGRect(x: kScreenWidth - 10 - 40, y: kTagTextViewH - 9 - 20, width: 40, height: 20))
        
        button.setTitle("完成", for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.textAlignment = .center
        
        button.backgroundColor = enableColor
        button.layer.cornerRadius = 2.0
        button.addTarget(self, action: #selector(self.doneClicked), for: .touchUpInside)
        return button
    }()
    
    lazy fileprivate var cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 10, y: kTagTextViewH - 9 - 20, width: 40, height: 20))
        
        button.setTitle("取消", for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.textAlignment = .center
        
        button.backgroundColor = enableColor
        button.layer.cornerRadius = 2.0
        button.addTarget(self, action: #selector(self.cancelClicked), for: .touchUpInside)
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
            doneButton.isEnabled = false
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
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView.text.isEmpty {
            doneButton.isEnabled = false
            doneButton.backgroundColor = disableColor
        } else {
            doneButton.isEnabled = true
            doneButton.backgroundColor = enableColor
        }
        
        if text == "\n" {
            doneHandler(textView.text)
            return false
        }
        
        return true
    }
}
