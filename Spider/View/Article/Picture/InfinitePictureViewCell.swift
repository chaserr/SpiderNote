//
//  InfinitePictureViewCell.swift
//  InfinitePictureView
//
//  Created by Atuooo on 4/27/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class InfinitePictureViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: bounds)
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.masksToBounds = true
        addSubview(imageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    func configureCellWith(info: PicInfo) {
        
        if let image = info.image {
            imageView.image = image
            
        } else {
            imageView.spider_showActivityIndicatorWhenLoading = true
            imageView.spider_setImageWith(info)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
