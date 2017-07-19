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
    
    var doneHandler: ((String) -> Void)?
    var cancelHandler: (() -> Void)?
    
    fileprivate lazy var textView: UITextView = {
        let textView                = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth  = 1
        textView.layer.borderColor  = SpiderConfig.Color.Line.cgColor
        textView.font               = SpiderConfig.Font.Title
        textView.textColor          = SpiderConfig.Color.DarkText
        textView.backgroundColor    = SpiderConfig.Color.Line
        return textView
    }()
    
    fileprivate lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white
        button.setTitle("取消", for: UIControlState())
        button.setTitleColor(UIColor.color(withHex: 0x888888), for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    fileprivate lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white
        button.setTitle("确定", for: UIControlState())
        button.setTitleColor(SpiderConfig.Color.ButtonText, for: UIControlState())
        button.setTitleColor(SpiderConfig.Color.HintText, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.isEnabled = false
        return button
    }()

    init(text: String = "") {
        super.init(frame: CGRect(x: 0, y: 0, width: 270, height: kHeight))
        
        center = CGPoint(x: kScreenWidth / 2, y: kScreenHeight / 2 - kHeight / 2 - 20)
        backgroundColor = UIColor.white
        layer.cornerRadius = 2.0
        layer.masksToBounds = true
        
        textView.text = text
        textView.delegate = self
        
        doneButton.addTarget(self, action: #selector(doneButtonClicked), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
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
    
    func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animate(withDuration: duration, animations: {
            self.frame.origin.y = (keyboardFrame.origin.y - kHeight) / 2
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        doneButton.isEnabled = !textView.text.isEmpty
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 270 / 2, y: kHeight - 40))
        path.addLine(to: CGPoint(x: 270 / 2, y: kHeight))
        
        path.lineWidth = 1.0
        SpiderConfig.Color.Line.setStroke()
        path.stroke()
    }
}
