//
//  AddProjectAlertView.swift
//  Spider
//
//  Created by ooatuoo on 16/7/6.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import SnapKit

private let themeColor = UIColor.color(withHex: 0x18BD83)

final class AddProjectAlertView: UIView {
    var addProjectHandler: ((String) -> Void)!
    private var isDone = false
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "新建项目"
        label.font = UIFont.systemFontOfSize(17)
        label.textColor = UIColor.color(withHex: 0x555555)
        label.textAlignment = .Center
        
        return label
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = "请输入项目名"
        field.font = UIFont.systemFontOfSize(14)
        field.layer.cornerRadius = 2.0
        
        field.tintColor = themeColor
        field.textColor = UIColor.color(withHex: 0x333333)
        field.backgroundColor = UIColor.color(withHex: 0xf0f0f0)
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
        field.leftViewMode = .Always
        return field
    }()
    
    private lazy var alertContainter: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3.0
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.color(withHex: 0xf0f0f0)
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.whiteColor()
        button.setTitle("取消", forState: .Normal)
        button.setTitleColor(UIColor.color(withHex: 0x888888), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.whiteColor()
        button.setTitle("确定", forState: .Normal)
        button.setTitleColor(themeColor, forState: .Normal)
        button.setTitleColor(SpiderConfig.Color.HintText, forState: .Disabled)
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        return button
    }()
    
    // MARK: - Init
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        alpha = 0.5
        makeUI()
        addActions()
        doneButton.enabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func keyboardWillShow(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        alertContainter.frame.origin.y = (keyboardFrame.origin.y - 150) / 2

        UIView.animateWithDuration(0.7, animations: {
            self.alpha = 1
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        
        let duration: NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        if isDone {
            
            UIView.animateWithDuration(duration*1.2, animations: {
                self.alpha = 0
            }) { done in
                self.removeFromSuperview()
            }
            
        } else {
            
            UIView.animateWithDuration(duration, animations: { 
                self.alpha = 0
            }, completion: { done in
                self.removeFromSuperview()
            })
        }
    }
    
    // MARK: - Button Actions
    
    func addActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), forControlEvents: .TouchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonClicked), forControlEvents: .TouchUpInside)
        
        textField.becomeFirstResponder()
    }
    
    func cancelButtonClicked() {
        isDone = false
        textField.resignFirstResponder()
    }
    
    func doneButtonClicked() {
        if let text = textField.text?.stringByReplacingOccurrencesOfString(" ", withString: "") where text.isEmpty {
            
            guard let currentVC = AppNavigator.instance?.topVC else { return }
            SpiderAlert.tellYou(message: "项目名不能为空！", inViewController: currentVC)
            
        } else {
            isDone = true
            addProjectHandler(textField.text!)
            textField.resignFirstResponder()
        }
    }
    
    // MARK: -  Make UI
    
    func makeUI() {
        let topContainter = UIView()
        topContainter.backgroundColor = UIColor.whiteColor()
        topContainter.addSubview(titleLabel)
        topContainter.addSubview(textField)
        textField.delegate = self
        
        alertContainter.frame = CGRect(x: (kScreenWidth - 270) / 2, y: 200, w: 270, h: 150)
        addSubview(alertContainter)
        alertContainter.addSubview(topContainter)
        alertContainter.addSubview(cancelButton)
        alertContainter.addSubview(doneButton)
        
        topContainter.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        topContainter.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 270, height: 106))
            make.top.centerX.equalTo(alertContainter)
        }
        
        titleLabel.snp_makeConstraints { (make) in
            make.height.equalTo(60)
            make.top.centerX.equalTo(topContainter)
        }
        
        textField.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 200, height: 30))
            make.top.equalTo(titleLabel.snp_bottom)
            make.centerX.equalTo(titleLabel)
        }
        
        cancelButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 134.5, height: 43))
            make.bottom.left.equalTo(alertContainter)
        }
        
        doneButton.snp_makeConstraints { (make) in
            make.size.equalTo(cancelButton)
            make.bottom.right.equalTo(alertContainter)
        }
    }
}

extension AddProjectAlertView: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        doneButton.enabled = true
        return true
    }
}
