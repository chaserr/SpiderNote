//
//  MoveMindUpView.swift
//  Spider
//
//  Created by ooatuoo on 16/7/26.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class MoveMindUpView: UIImageView {
    var isHighlight = false {
        didSet {
            image = UIImage(named: isHighlight ? "mind_move_up_h" : "mind_move_up")
        }
    }
    
    private var unDoc = false
    
    private var icon: UIImageView = {
        return UIImageView(image: UIImage(named: "mind_edit_higherup"))
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(13)
        label.textColor = UIColor.color(withHex: 0xaaaaaa)
        label.textAlignment = .Center
        return label
    }()
    
    init(toUndoc: Bool = false) {
        super.init(frame: CGRect(x: 0, y: 0, w: 61, h: 176))
        unDoc = toUndoc
        image = UIImage(named: "mind_move_up")
        
        label.text = toUndoc ? "碎片盒" : "上一级"
        makeUI()
    }
    
    private func makeUI() {
        self.addSubview(label)
        addSubview(icon)
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        icon.snp_makeConstraints { (make) in
            make.size.equalTo(24)
            make.center.equalTo(self)
        }

        label.snp_makeConstraints { (make) in
            make.centerX.equalTo(icon)
            make.top.equalTo(icon.snp_bottom).offset(10)
        }
    }
    
    func moveToView(view: UITableView) {
        if unDoc {
            
            center = CGPoint(x: kScreenWidth, y: view.contentOffset.y + kScreenHeight / 2 - 60)
            view.addSubview(self)
            
            UIView.animateWithDuration(0.3) {
                self.center.x = kScreenWidth - 4 - 30.5
            }
            
        } else {
            
            center = CGPoint(x: -32, y: view.contentOffset.y + kScreenHeight / 2 - 60)
            view.addSubview(self)
            
            UIView.animateWithDuration(0.3) {
                self.center.x = 30.5
            }
        }
    }
    
    override func removeFromSuperview() {
        if unDoc {
            
            UIView.animateWithDuration(0.4, animations: {
                self.center.x = kScreenWidth
            }) { (done) in
                super.removeFromSuperview()
            }
            
        } else {
            
            UIView.animateWithDuration(0.3, animations: {
                self.center.x = -32
            }) { (done) in
                super.removeFromSuperview()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
