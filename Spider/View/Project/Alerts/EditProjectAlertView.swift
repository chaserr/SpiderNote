//
//  EditProjectAlertView.swift
//  Spider
//
//  Created by ooatuoo on 16/7/6.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

private let textColor = UIColor.color(withHex: 0x555555)
private let themeColor = UIColor.whiteColor()

class EditProjectAlertView: UIView {
    
    var deleteHanlder: (() -> Void)!
    var editHandler: (String -> Void)!
    
    var projectName: String!
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(17)
        label.textColor = textColor
        label.textAlignment = .Center
        label.backgroundColor = themeColor
        return label
    }()
    
    private var editButton: UIButton = {
        let button = UIButton()
        button.setTitle("编辑名称", forState: .Normal)
        button.setTitleColor(textColor, forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        button.backgroundColor = themeColor
        return button
    }()
    
    private var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("删除项目", forState: .Normal)
        button.setTitleColor(textColor, forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        button.backgroundColor = themeColor
        return button
    }()
    
    private var shareButton: UIButton = {
        let button = UIButton()
        button.setTitle("分享项目", forState: .Normal)
        button.setTitleColor(textColor, forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        button.backgroundColor = themeColor
        return button
    }()
    
    private var alertContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2.0
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.color(withHex: 0xf0f0f0)
        return view
    }()
    
    // MARK: - Init
    
    init(name: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        projectName = name
        titleLabel.text = name
        
        makeUI()
        addActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Button Actions
    func addActions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        
        editButton.addTarget(self, action: #selector(eidtButtonClicked), forControlEvents: .TouchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonClicked), forControlEvents: .TouchUpInside)
    }
    
    func eidtButtonClicked() {
        alertContainer.removeFromSuperview()
        addEditAlert()
    }
    
    func deleteButtonClicked() {
        deleteHanlder()
        removeFromSuperview()
    }
    
    func addEditAlert() {
        let editAlert = EditProjectNameAlertView(text: projectName)
        editAlert.doneHandler = { [unowned self] text in
            self.editHandler(text)
            self.removeFromSuperview()
        }
        
        editAlert.cancelHandler = { [unowned self] in
            self.removeFromSuperview()
        }
        
        addSubview(editAlert)
        
        editAlert.translatesAutoresizingMaskIntoConstraints = false
        editAlert.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 270, height: 106))
            make.top.equalTo(150)
            make.centerX.equalTo(self)
        }
    }
    
    func didTap() {
        removeFromSuperview()
    }
    
    // MARK: - Make UI
    
    func makeUI() {
        addSubview(alertContainer)
        alertContainer.addSubview(titleLabel)
        alertContainer.addSubview(editButton)
        alertContainer.addSubview(deleteButton)
        
        alertContainer.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        alertContainer.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 270, height: 150))
            make.top.equalTo(150)
            make.centerX.equalTo(self)
        }
        
        titleLabel.snp_makeConstraints { (make) in
            make.height.equalTo(60)
            make.top.left.right.equalTo(alertContainer)
        }
        
        editButton.snp_makeConstraints { (make) in
            make.height.equalTo(44)
            make.width.centerX.equalTo(alertContainer)
            make.top.equalTo(titleLabel.snp_bottom).offset(1)
        }
        
        deleteButton.snp_makeConstraints { (make) in
            make.size.centerX.equalTo(editButton)
            make.top.equalTo(editButton.snp_bottom).offset(1)
        }
    }
}
