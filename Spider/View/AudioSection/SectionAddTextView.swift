//
//  SectionAddTextView.swift
//  Spider
//
//  Created by ooatuoo on 16/7/11.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class SectionAddTextView: UIView {
    
    var doneHandler: ((String) -> Void)?
    
    fileprivate var charactersLimit = 140
    
    fileprivate var text: String = ""
    
    fileprivate var contaniner: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.color(withHex: 0xf0f0f0)
        return view
    }()
    
    fileprivate var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.returnKeyType = .done
        textView.enablesReturnKeyAutomatically = true
        textView.layer.cornerRadius = 2.0
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.color(withHex: 0xeaeaea).cgColor
        textView.backgroundColor = UIColor.white
        return textView
    }()
    
    fileprivate var charactersRemainingLabel: UILabel = {
        let label = UILabel()
        label.text = "140"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.color(withHex: 0xcccccc)
        label.textAlignment = .center
        return label
    }()
    
    fileprivate var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("完成", for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.titleLabel?.textColor = UIColor.white
        button.backgroundColor = UIColor.color(withHex: 0x363646)
        button.layer.cornerRadius = 2.0
        return button
    }()
    
    fileprivate var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.titleLabel?.textColor = UIColor.white
        button.backgroundColor = UIColor.color(withHex: 0x363646)
        button.layer.cornerRadius = 2.0
        return button
    }()
    
    init(text: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        self.text = text
        
        makeUI()
        addActions()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func makeUI() {
        contaniner.addSubview(textView)
        contaniner.addSubview(doneButton)
        contaniner.addSubview(cancelButton)
        contaniner.addSubview(charactersRemainingLabel)
        addSubview(contaniner)
        
        contaniner.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        charactersRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        contaniner.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: kScreenWidth, height: 120))
            make.bottom.left.equalTo(self)
        }
        
        textView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: kScreenWidth - 20, height: 70))
            make.top.left.equalTo(10)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 20))
            make.left.equalTo(10)
            make.bottom.equalTo(-10)
        }
        
        doneButton.snp.makeConstraints { (make) in
            make.size.centerY.equalTo(cancelButton)
            make.right.equalTo(-10)
        }
        
        charactersRemainingLabel.snp.makeConstraints { (make) in
            make.size.centerY.equalTo(cancelButton)
            make.right.equalTo(doneButton.snp.left)
        }
    }
    
    // MARK: - Actions
    
    func addActions() {
        registerForKeyboardNotification()
        
        if !text.isEmpty {
            textView.text = text
        } else {
            textView.text = ""
            doneButton.backgroundColor = UIColor.color(withHex: 0x363646, alpha: 0.5)
            doneButton.isEnabled = false
        }
        
        textView.delegate = self
        textView.becomeFirstResponder()
        
        cancelButton.addTarget(self, action: #selector(removeFromSuperview), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonClicked), for: .touchUpInside)
    }
    
    func doneButtonClicked() {
        doneHandler?(textView.text)
        removeFromSuperview()
    }
    
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let kbFrame = (info[UIKeyboardFrameEndUserInfoKey]! as AnyObject).CGRectValue
        
        UIView.animate(withDuration: 1.3, animations: {
            self.contaniner.transform = CGAffineTransform(translationX: 0, y: -kbFrame.height)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SectionAddTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let remainCount = charactersLimit - textView.text.characters.count
        if remainCount < 0 || remainCount == charactersLimit {
            doneButton.backgroundColor = UIColor.color(withHex: 0x363646, alpha: 0.5)
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
            doneButton.backgroundColor = UIColor.color(withHex: 0x363646)
        }
        
        charactersRemainingLabel.text = "\(remainCount)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView.text.characters.count <= charactersLimit {
                doneButtonClicked()
            } else {
                // TODO: - disable returnKey manually
                //            textView.inputDelegate?.performSelector(NSSelectorFromString("returnKeyEnabled:"), withObject: false)
            }
            return false
        }
        return true
    }
}
