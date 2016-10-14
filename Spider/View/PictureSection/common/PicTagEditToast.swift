//
//  PicTagEditToast.swift
//  Spider
//
//  Created by Atuooo on 6/2/16.
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
            editButton.setTitle("编辑", forState: .Normal)
            editButton.titleLabel?.textColor = UIColor.whiteColor()
            editButton.titleLabel?.font = UIFont.systemFontOfSize(13)
            editButton.addTarget(self, action: #selector(editClicked), forControlEvents: .TouchUpInside)
            addSubview(editButton)
            
            let deleteButton = UIButton(frame: CGRect(x: kPicTagEditTW / 2, y: 0, width: kPicTagEditTW / 2, height: 30))
            deleteButton.setTitle("删除", forState: .Normal)
            deleteButton.titleLabel?.textColor = UIColor.whiteColor()
            deleteButton.titleLabel?.font = UIFont.systemFontOfSize(13)
            deleteButton.addTarget(self, action: #selector(deleteClicked), forControlEvents: .TouchUpInside)
            addSubview(deleteButton)
            
            self.center = center
            
        } else {
            super.init(frame: CGRect(x: 0, y: 0, width: kPicTagDeleteTW, height: kPicTagDeleteTH))
            image = UIImage(named: "pic_tag_delete_toast")
            
            let deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: kPicTagEditTW / 2, height: 30))
            deleteButton.setTitle("删除", forState: .Normal)
            deleteButton.titleLabel?.textColor = UIColor.whiteColor()
            deleteButton.titleLabel?.font = UIFont.systemFontOfSize(13)
            deleteButton.addTarget(self, action: #selector(deleteClicked), forControlEvents: .TouchUpInside)
            addSubview(deleteButton)
            
            self.center = center
        }
        
        userInteractionEnabled = true
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
