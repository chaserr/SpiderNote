//
//  AddTextSectinoView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/4.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

var doneHandler: ((String) -> Void)?

class AddUndocTextView: UIView, UITextViewDelegate {
    
    fileprivate var backToRect: CGRect!
    fileprivate var isNew = false
    fileprivate var isDone = false
    fileprivate var object: SectionObject?
    
    fileprivate lazy var titleView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 80))
        view.backgroundColor = SpiderConfig.Color.BackgroundDark
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: 120, height: 40))
        label.text = "未归档"
        label.textColor = SpiderConfig.Color.LightText
        label.font = SpiderConfig.Font.Text
        label.center = CGPoint(x: 75, y: 48)
        view.addSubview(label)
        return view
    }()
    
    fileprivate lazy var textView: UITextView = {
        let textView                = UITextView(frame: CGRect(x: 0, y: 80, width: kScreenWidth, height: kScreenHeight))
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
    
    init(object: SectionObject? = nil, backToRect: CGRect = kUnchiveBoxItemRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        layer.masksToBounds = true
        
        self.object = object
        self.backToRect = backToRect

        if let object = object {
            
            textView.text = object.text!
            
        } else {
            textView.text = ""
            doneButton.isEnabled = false
        }
        
        textView.delegate = self
        addSubview(titleView)
        addSubview(textView)
        
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        
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
        
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue
        let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animate(withDuration: duration, animations: {
            
            self.frame = CGRect(x: 0, y: 0, w: kScreenWidth, h: keyboardFrame.origin.y)
            self.textView.frame = CGRect(x: 0, y: 80, width: kScreenWidth, height: keyboardFrame.origin.y - 80)

        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        guard let _ = notification.userInfo else { return }
        
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        
            
        if isDone {

            UIView.animate(withDuration: 0.4, animations: {
                
                self.frame.origin = CGPoint(x: 0, y: kScreenHeight)
                self.alpha = 0
                
            }, completion: { done in
                    
                self.removeFromSuperview()
                
                if let projectVC = AppNavigator.instance?.topVC as? ProjectCollectionViewController {
                    projectVC.undocCountLabel.count = SpiderRealm.getUndocItemCount()
                }
            })
            
        } else {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.alpha = 0
                
            }, completion: { done in
                
                self.removeFromSuperview()
            })
        }
            
    }
    
    func doneButtonClicked() {
        SpiderRealm.updateTextSection(object, with: textView.text, undoc: 1)
        
        isDone = true
        textView.resignFirstResponder()
    }
    
    func cancelButtonClicked() {
        isDone = false
        textView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        doneButton.isEnabled = !textView.text.isEmpty
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
