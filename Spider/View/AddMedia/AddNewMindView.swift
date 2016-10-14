//
//  AddNewMindView.swift
//  Spider
//
//  Created by Atuooo on 07/09/2016.
//  Copyright © 2016 auais. All rights reserved.
//

import UIKit

private let kHeight = CGFloat(180)

class AddNewMindView: UIView, UITextViewDelegate {
    
    var doneHandler: (String -> Void)?
    var cancelHandler: (() -> Void)?
    
    private lazy var textView: UITextView = {
        let textView                = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth  = 1
        textView.layer.borderColor  = SpiderConfig.Color.Line.CGColor
        textView.font               = SpiderConfig.Font.Title
        textView.textColor          = SpiderConfig.Color.DarkText
        textView.backgroundColor    = SpiderConfig.Color.Line
        return textView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.whiteColor()
        button.setTitle("取消", forState: .Normal)
        button.setTitleColor(UIColor.color(withHex: 0x888888), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.whiteColor()
        button.setTitle("确定", forState: .Normal)
        button.setTitleColor(SpiderConfig.Color.ButtonText, forState: .Normal)
        button.setTitleColor(SpiderConfig.Color.HintText, forState: .Disabled)
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        button.enabled = false
        return button
    }()

    init(text: String = "") {
        super.init(frame: CGRect(x: 0, y: 0, width: 270, height: kHeight))
        
        center = CGPoint(x: kScreenWidth / 2, y: kScreenHeight / 2 - kHeight / 2 - 20)
        backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = 2.0
        layer.masksToBounds = true
        
        textView.text = text
        textView.delegate = self
        
        doneButton.addTarget(self, action: #selector(doneButtonClicked), forControlEvents: .TouchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), forControlEvents: .TouchUpInside)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        
        addSubview(textView)
        addSubview(cancelButton)
        addSubview(doneButton)
        
        textView.snp_makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(6, 6, 40, 6))
        }
        
        cancelButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 270 / 2 - 1, height: 40))
            make.left.bottom.equalTo(self)
        }
        
        doneButton.snp_makeConstraints { (make) in
            make.size.equalTo(cancelButton)
            make.right.bottom.equalTo(self)
        }
        
        textView.becomeFirstResponder()
    }
    
    func doneButtonClicked() {
        doneHandler?(textView.text)
        textView.resignFirstResponder()
    }
    
    func cancelButtonClicked() {
        cancelHandler?()
        textView.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration: NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animateWithDuration(duration, animations: {
            self.frame.origin.y = (keyboardFrame.origin.y - kHeight) / 2
        })
    }
    
    func textViewDidChange(textView: UITextView) {
        doneButton.enabled = !textView.text.isEmpty
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(rect: CGRect) {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 270 / 2, y: kHeight - 40))
        path.addLineToPoint(CGPoint(x: 270 / 2, y: kHeight))
        
        path.lineWidth = 1.0
        SpiderConfig.Color.Line.setStroke()
        path.stroke()
    }
}
