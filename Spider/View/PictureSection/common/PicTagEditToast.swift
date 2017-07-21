//
//  PicTagEditToast.swift
//  Spider
//
//  Created by 童星 on 6/2/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class PicTagEditToast: UIImageView {
    
    var editHandler: (() -> Void)?
    var deleteHandler: (() -> Void)?
        
    init(center: CGPoint, canEdit: Bool) {
        
        if canEdit {
            super.init(frame: CGRect(x: 0, y: 0, width: kPicTagEditTW, height: kpicTagEditTH))
            image = UIImage(named: "pic_tag_edit_toast")
            
            let editButton = UIButton(frame: CGRect(x: 0, y: 0, width: kPicTagEditTW / 2, height: 30))
            editButton.setTitle("编辑", for: UIControlState())
            editButton.titleLabel?.textColor = UIColor.white
            editButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            editButton.addTarget(self, action: #selector(editClicked), for: .touchUpInside)
            addSubview(editButton)
            
            let deleteButton = UIButton(frame: CGRect(x: kPicTagEditTW / 2, y: 0, width: kPicTagEditTW / 2, height: 30))
            deleteButton.setTitle("删除", for: UIControlState())
            deleteButton.titleLabel?.textColor = UIColor.white
            deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            deleteButton.addTarget(self, action: #selector(deleteClicked), for: .touchUpInside)
            addSubview(deleteButton)
            
            self.center = center
            
        } else {
            super.init(frame: CGRect(x: 0, y: 0, width: kPicTagDeleteTW, height: kPicTagDeleteTH))
            image = UIImage(named: "pic_tag_delete_toast")
            
            let deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: kPicTagEditTW / 2, height: 30))
            deleteButton.setTitle("删除", for: UIControlState())
            deleteButton.titleLabel?.textColor = UIColor.white
            deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            deleteButton.addTarget(self, action: #selector(deleteClicked), for: .touchUpInside)
            addSubview(deleteButton)
            
            self.center = center
        }
        
        isUserInteractionEnabled = true
    }
    
    func editClicked() {
        editHandler?()
        
        removeFromSuperview()
    }
    
    func deleteClicked() {
        deleteHandler?()
        
        removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
