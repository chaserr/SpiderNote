//
//  EditProjectAlertView.swift
//  Spider
//
//  Created by ooatuoo on 16/7/6.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

private let textColor = UIColor.color(withHex: 0x555555)
private let themeColor = UIColor.white

class EditProjectAlertView: UIView {
    
    var deleteHanlder: (() -> Void)!
    var editHandler: ((String) -> Void)!
    
    var projectName: String!
    
    fileprivate var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = textColor
        label.textAlignment = .center
        label.backgroundColor = themeColor
        return label
    }()
    
    fileprivate var editButton: UIButton = {
        let button = UIButton()
        button.setTitle("编辑名称", for: UIControlState())
        button.setTitleColor(textColor, for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.backgroundColor = themeColor
        return button
    }()
    
    fileprivate var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("删除项目", for: UIControlState())
        button.setTitleColor(textColor, for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.backgroundColor = themeColor
        return button
    }()
    
    fileprivate var shareButton: UIButton = {
        let button = UIButton()
        button.setTitle("分享项目", for: UIControlState())
        button.setTitleColor(textColor, for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.backgroundColor = themeColor
        return button
    }()
    
    fileprivate var alertContainer: UIView = {
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
        
        editButton.addTarget(self, action: #selector(eidtButtonClicked), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonClicked), for: .touchUpInside)
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
