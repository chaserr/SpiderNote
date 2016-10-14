//
//  AddTextSectionView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/4.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class AddTextSectionView: UIView {
    
    var doneHandler: (String -> Void)?
    var isDone = false
    
    private lazy var textView: UITextView = {
        let textView                = UITextView(frame: CGRect(x: 0, y: kScreenHeight, w: kScreenWidth, h: kScreenHeight))
        textView.font               = SpiderConfig.Font.Text
        textView.textColor          = SpiderConfig.Color.DarkText
        textView.backgroundColor    = UIColor.whiteColor()
        textView.textContainerInset = UIEdgeInsetsMake(20, 12, 20, 12)
        textView.inputAccessoryView = self.accessoryView
        return textView
    }()
    
    private lazy var accessoryView: UIToolbar = {
        let bar             = UIToolbar(frame: CGRect(x: 0, y: 0, w: kScreenWidth, h: 44))
        bar.backgroundColor = UIColor.whiteColor()
        
        let doneItem        = UIBarButtonItem(customView: self.doneButton)
        let cancelItem      = UIBarButtonItem(customView: self.cancelButton)
        let flexibleSpace   = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        bar.items           = [cancelItem, flexibleSpace, doneItem]
        return bar
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, w: 60, h: 40))
        button.setTitle("完成", forState: .Normal)
        button.setTitleColor(SpiderConfig.Color.ButtonText, forState: .Normal)
        button.setTitleColor(SpiderConfig.Color.HintText, forState: .Disabled)
        button.titleLabel?.font = SpiderConfig.Font.Text
        
        button.addTarget(self, action: #selector(doneButtonClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, w: 60, h: 40))
        button.setTitle("取消", forState: .Normal)
        button.setTitleColor(SpiderConfig.Color.ButtonText, forState: .Normal)
        button.titleLabel?.font = SpiderConfig.Font.Text
        
        button.addTarget(self, action: #selector(cancelButtonClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    
    init(text: String = "") {
        super.init(frame: CGRect(x: 0, y: kStatusBarHeight, w: kScreenWidth, h: kScreenHeight - kStatusBarH))
        
        textView.text = text
        textView.delegate = self
        addSubview(textView)
        
        doneButton.enabled = !text.isEmpty

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func moveTo(view: UIView) {
        view.addSubview(self)
        textView.becomeFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration: NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animateWithDuration(duration, animations: {
            self.textView.frame = CGRect(x: 0, y: 0, w: kScreenWidth, h: keyboardFrame.origin.y - kStatusBarHeight)
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration: NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        if isDone {
            
            UIView.animateWithDuration(duration*1.2, animations: {
                self.textView.frame = CGRect(x: 0, y: kScreenHeight, w: kScreenWidth, h: keyboardFrame.origin.y - kStatusBarHeight)
            }) { done in
                self.removeFromSuperview()
            }
            
        } else {
            
            UIView.animateWithDuration(0.3, animations: { 
                self.alpha = 0.0
            }, completion: { done in
                self.removeFromSuperview()
            })
        }

    }
    
    func doneButtonClicked() {
        isDone = true
        textView.resignFirstResponder()
        doneHandler?(textView.text)
    }
    
    func cancelButtonClicked() {
        isDone = false
        textView.resignFirstResponder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddTextSectionView: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        doneButton.enabled = !textView.text.isEmpty
    }
}
