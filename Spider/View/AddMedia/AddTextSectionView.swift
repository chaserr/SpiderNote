//
//  AddTextSectionView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/4.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class AddTextSectionView: UIView {
    
    var doneHandler: ((String) -> Void)?
    var isDone = false
    
    fileprivate lazy var textView: UITextView = {
        let textView                = UITextView(frame: CGRect(x: 0, y: kScreenHeight, w: kScreenWidth, h: kScreenHeight))
        textView.font               = SpiderConfig.Font.Text
        textView.textColor          = SpiderConfig.Color.DarkText
        textView.backgroundColor    = UIColor.white
        textView.textContainerInset = UIEdgeInsetsMake(20, 12, 20, 12)
        textView.inputAccessoryView = self.accessoryView
        return textView
    }()
    
    fileprivate lazy var accessoryView: UIToolbar = {
        let bar             = UIToolbar(frame: CGRect(x: 0, y: 0, w: kScreenWidth, h: 44))
        bar.backgroundColor = UIColor.white
        
        let doneItem        = UIBarButtonItem(customView: self.doneButton)
        let cancelItem      = UIBarButtonItem(customView: self.cancelButton)
        let flexibleSpace   = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items           = [cancelItem, flexibleSpace, doneItem]
        return bar
    }()
    
    fileprivate lazy var doneButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, w: 60, h: 40))
        button.setTitle("完成", for: UIControlState())
        button.setTitleColor(SpiderConfig.Color.ButtonText, for: UIControlState())
        button.setTitleColor(SpiderConfig.Color.HintText, for: .disabled)
        button.titleLabel?.font = SpiderConfig.Font.Text
        
        button.addTarget(self, action: #selector(doneButtonClicked), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, w: 60, h: 40))
        button.setTitle("取消", for: UIControlState())
        button.setTitleColor(SpiderConfig.Color.ButtonText, for: UIControlState())
        button.titleLabel?.font = SpiderConfig.Font.Text
        
        button.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        return button
    }()
    
    
    init(text: String = "") {
        super.init(frame: CGRect(x: 0, y: kStatusBarHeight, w: kScreenWidth, h: kScreenHeight - kStatusBarH))
        
        textView.text = text
        textView.delegate = self
        addSubview(textView)
        
        doneButton.isEnabled = !text.isEmpty

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func moveTo(_ view: UIView) {
        view.addSubview(self)
        textView.becomeFirstResponder()
    }
    
    func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animate(withDuration: duration, animations: {
            self.textView.frame = CGRect(x: 0, y: 0, w: kScreenWidth, h: keyboardFrame.origin.y - kStatusBarHeight)
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        if isDone {
            
            UIView.animate(withDuration: duration*1.2, animations: {
                self.textView.frame = CGRect(x: 0, y: kScreenHeight, w: kScreenWidth, h: keyboardFrame.origin.y - kStatusBarHeight)
            }, completion: { done in
                self.removeFromSuperview()
            }) 
            
        } else {
            
            UIView.animate(withDuration: 0.3, animations: { 
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
    
    func textViewDidChange(_ textView: UITextView) {
        doneButton.isEnabled = !textView.text.isEmpty
    }
}
