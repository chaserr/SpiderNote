//
//  EditMindTopBar.swift
//  Spider
//
//  Created by ooatuoo on 16/7/25.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class EditMindTopBar: UIView {
    
    var doneHandler: (() -> Void)?
    var chooseAllHandler: (() -> Void)?
    
    private var choosedAll = false

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Center
        label.textColor = UIColor.color(withHex: 0x222222)
        label.font = UIFont.systemFontOfSize(18)
        return label
    }()
    
    private lazy var chooseAllButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("全选", forState: .Normal)
        button.setTitleColor(UIColor.color(withHex: 0x5FB85F), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("完成", forState: .Normal)
        button.setTitleColor(UIColor.color(withHex: 0x5FB85F), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        return button
    }()
    
    init(title: String) {
        super.init(frame: CGRect(x: 0, y: 0, w: kScreenWidth, h: 64))
        backgroundColor = UIColor.whiteColor()
        
        titleLabel.text = title
        makeUI()
        addActions()
    }
    
    func addActions() {
        doneButton.addTarget(self, action: #selector(doneButtonClicked), forControlEvents: .TouchUpInside)
        chooseAllButton.addTarget(self, action: #selector(chooseAllButtonClicked), forControlEvents: .TouchUpInside)
    }
    
    func doneButtonClicked() {
        doneHandler?()
        
        removeFromSuperview()

//        UIView.animateWithDuration(0.4, animations: {
//            self.frame.origin = CGPoint(x: 0, y: -64)
//        }) { completed in
//            self.removeFromSuperview()
//        }
    }
    
    func chooseAllButtonClicked() {
        choosedAll = !choosedAll
        chooseAllButton.setTitle(choosedAll ? "取消" : "全选", forState: .Normal)
        chooseAllHandler?()
    }
    
    func addToView(view: UIView) {
        frame.origin = CGPoint(x: 0, y: -64)
        view.addSubview(self)
        
        frame.origin = CGPoint(x: 0, y: 0)
    }
    
    func makeUI() {
        addSubview(titleLabel)
        addSubview(doneButton)
        addSubview(chooseAllButton)
        
        chooseAllButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 44, height: 22))
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(15)
        }
        
        doneButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 44, height: 22))
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(-15)
        }
        
        titleLabel.snp_makeConstraints { (make) in
            make.top.equalTo(20)
            make.bottom.equalTo(self)
            make.left.equalTo(chooseAllButton.snp_right).offset(20)
            make.right.equalTo(doneButton.snp_left).offset(-20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
