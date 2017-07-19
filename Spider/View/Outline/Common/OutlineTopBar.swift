//
//  OutlineTopBar.swift
//  Spider
//
//  Created by ooatuoo on 16/8/31.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

private let openSize = CGSize(width: 12, height: 6)
private let labelMaxWidth = kScreenWidth * 0.4
private let labelButtonW  = labelMaxWidth + openSize.width + 4

class OutlineTopBar: UIView {
    
    var backHandler: (() -> Void)?
    
    var changeHandler: (() -> Void)?
    
    var projectName = "" {
        willSet {
            if projectName != newValue {
                                
                let rect = newValue.boundingRect(with: CGSize(width: CGFloat(Float.greatestFiniteMagnitude), height: 30), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
                
                if ceil(rect.width) > labelMaxWidth {
                    
                    label.frame.size = CGSize(width: labelMaxWidth, height: 40)
                    label.text = newValue
                    iconOpen.center = CGPoint(x: labelMaxWidth + 4 + openSize.width / 2, y: 22)
                    
                } else {
                    
                    label.text = newValue
                    label.sizeToFit()
                    iconOpen.center = CGPoint(x: labelButtonW / 2 + label.frame.width / 2 + 4 + openSize.width / 2, y: 22)
                }
                
                label.center = CGPoint(x: labelButtonW / 2 - openSize.width / 2, y: 22)
            }
            
            iconOpen.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            changing = false
        }
    }
    
    fileprivate var changing = false
    
    fileprivate var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 10, y: 24, w: 40, h: 40))
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 8)
        button.setImage(UIImage(named: "outline_back"), for: UIControlState())
        
        return button
    }()
    
    fileprivate var label: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: labelMaxWidth, height: 40))
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingMiddle
        label.textColor = SpiderConfig.Color.DarkText
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    fileprivate var labelButton: UIButton = {
        return UIButton(frame: CGRect(x: (kScreenWidth - labelButtonW) / 2, y: 20, width: labelButtonW, height: 44))
    }()
    
    fileprivate var iconOpen: UIImageView = {
        let view = UIImageView(frame: CGRect(origin: CGPoint.zero, size: openSize))
        view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        view.image = UIImage(named: "outline_topbar_close")
        return view
    }()
    
    init(jump: Bool, projectID: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 64))
        
        backgroundColor = UIColor.white
        
        if jump {
            
            label.text = "双击可跳转至任意节点"
            label.sizeToFit()
            label.center = CGPoint(x: kScreenWidth / 2, y: 42)
            addSubview(label)
            
        } else {
            
            if let project = REALM.realm.object(ofType: ProjectObject.self, forPrimaryKey: projectID as AnyObject) {
                projectName = project.name
            } else {
                projectName = "未找到项目"
            }
            
            let rect = projectName.boundingRect(with: CGSize(width: CGFloat(Float.greatestFiniteMagnitude), height: 30), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
            
            if ceil(rect.width) > labelMaxWidth {
                label.text = projectName
                iconOpen.center = CGPoint(x: labelMaxWidth + 4 + openSize.width / 2, y: 22)
                
            } else {
                label.text = projectName
                label.sizeToFit()
                iconOpen.center = CGPoint(x: labelButtonW / 2 + label.frame.width / 2 + 4 + openSize.width / 2, y: 22)
            }
            
            label.center = CGPoint(x: labelButtonW / 2 - openSize.width / 2, y: 22)
            labelButton.addSubview(iconOpen)
            labelButton.addSubview(label)
            labelButton.addTarget(self, action: #selector(changeProjectClicked), for: .touchUpInside)
            
            addSubview(labelButton)
        }
        
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        addSubview(backButton)
    }

    func backButtonClicked() {
        backHandler?()
    }
    
    func changeProjectClicked() {
        iconOpen.transform = changing ? CGAffineTransform(rotationAngle: CGFloat(Double.pi)) : CGAffineTransform.identity
        changing = !changing
        
        changeHandler?()
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: 64))
        path.addLine(to: CGPoint(x: kScreenWidth, y: 64))
        
        path.lineWidth = 1
        
        SpiderConfig.Color.Line.setStroke()
        path.stroke()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
