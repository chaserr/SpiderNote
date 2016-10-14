//
//  AddTextSectinoView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/4.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

var doneHandler: (String -> Void)?

class AddUndocTextView: UIView, UITextViewDelegate {
    
    private var backToRect: CGRect!
    private var isNew = false
    private var isDone = false
    private var object: SectionObject?
    
    private lazy var titleView: UIView = {
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
    
    private lazy var textView: UITextView = {
        let textView                = UITextView(frame: CGRect(x: 0, y: 80, width: kScreenWidth, height: kScreenHeight))
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
    
    init(object: SectionObject? = nil, backToRect: CGRect = kUnchiveBoxItemRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        layer.masksToBounds = true
        
        self.object = object
        self.backToRect = backToRect

        if let object = object {
            
            textView.text = object.text!
            
        } else {
            textView.text = ""
            doneButton.enabled = false
        }
        
        textView.delegate = self
        addSubview(titleView)
        addSubview(textView)
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
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
            
            self.frame = CGRect(x: 0, y: 0, w: kScreenWidth, h: keyboardFrame.origin.y)
            self.textView.frame = CGRect(x: 0, y: 80, width: kScreenWidth, height: keyboardFrame.origin.y - 80)

        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let _ = notification.userInfo else { return }
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        
            
        if isDone {

            UIView.animateWithDuration(0.4, animations: {
                
                self.frame.origin = CGPoint(x: 0, y: kScreenHeight)
                self.alpha = 0
                
            }, completion: { done in
                    
                self.removeFromSuperview()
                
                if let projectVC = AppNavigator.instance?.topVC as? ProjectCollectionViewController {
                    projectVC.undocCountLabel.count = SpiderRealm.getUndocItemCount()
                }
            })
            
        } else {
            
            UIView.animateWithDuration(0.3, animations: {
                
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
    
    func textViewDidChange(textView: UITextView) {
        doneButton.enabled = !textView.text.isEmpty
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
