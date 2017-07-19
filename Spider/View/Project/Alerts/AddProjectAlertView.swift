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
    fileprivate var isDone = false
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "新建项目"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.color(withHex: 0x555555)
        label.textAlignment = .center
        
        return label
    }()
    
    fileprivate lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = "请输入项目名"
        field.font = UIFont.systemFont(ofSize: 14)
        field.layer.cornerRadius = 2.0
        
        field.tintColor = themeColor
        field.textColor = UIColor.color(withHex: 0x333333)
        field.backgroundColor = UIColor.color(withHex: 0xf0f0f0)
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
        field.leftViewMode = .always
        return field
    }()
    
    fileprivate lazy var alertContainter: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3.0
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.color(withHex: 0xf0f0f0)
        return view
    }()
    
    fileprivate lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.setTitle("取消", for: UIControlState())
        button.setTitleColor(UIColor.color(withHex: 0x888888), for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    fileprivate lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.setTitle("确定", for: UIControlState())
        button.setTitleColor(themeColor, for: UIControlState())
        button.setTitleColor(SpiderConfig.Color.HintText, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    // MARK: - Init
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        alpha = 0.5
        makeUI()
        addActions()
        doneButton.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue
        
        alertContainter.frame.origin.y = (keyboardFrame.origin.y - 150) / 2

        UIView.animate(withDuration: 0.7, animations: {
            self.alpha = 1
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        
        let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        if isDone {
            
            UIView.animate(withDuration: duration*1.2, animations: {
                self.alpha = 0
            }, completion: { done in
                self.removeFromSuperview()
            }) 
            
        } else {
            
            UIView.animate(withDuration: duration, animations: { 
                self.alpha = 0
            }, completion: { done in
                self.removeFromSuperview()
            })
        }
    }
    
    // MARK: - Button Actions
    
    func addActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonClicked), for: .touchUpInside)
        
        textField.becomeFirstResponder()
    }
    
    func cancelButtonClicked() {
        isDone = false
        textField.resignFirstResponder()
    }
    
    func doneButtonClicked() {
        if let text = textField.text?.replacingOccurrences(of: " ", with: ""), text.isEmpty {
            
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
        topContainter.backgroundColor = UIColor.white
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        doneButton.isEnabled = true
        return true
    }
}
