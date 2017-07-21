//
//  PicTopToolBarCell.swift
//  Spider
//
//  Created by 童星 on 6/2/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class PicTopToolBarCell: UICollectionViewCell {
    var imageView: UIImageView!
    var couldDelete = false
    
    fileprivate var deleteIcon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        imageView = UIImageView(frame: bounds)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        addSubview(imageView)
    }
    
    func select() {
        imageView.layer.cornerRadius = 3
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor.color(withHex: 0x00c786).cgColor
        imageView.layer.masksToBounds = true
    }
    
    func deselct() {
        imageView.layer.cornerRadius = 0
        imageView.layer.borderWidth = 0
        imageView.layer.masksToBounds = true
    }
    
    func toDelete() {
        deleteIcon = UIImageView(frame: CGRect(x: 18, y: 18, width: 15, height: 15))
        deleteIcon.image = UIImage(named: "pic_delete_pic")
        addSubview(deleteIcon)
    }
    
    func cancelDelete() {
        deleteIcon.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
