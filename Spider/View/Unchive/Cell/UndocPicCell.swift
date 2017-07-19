//
//  UndocPicCell.swift
//  Spider
//
//  Created by ooatuoo on 16/8/19.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class UndocPicCell: UndocBaseCell {

    fileprivate var imageView: UIImageView = {
        return UIImageView()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.snp_makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    override func configureWithInfo(_ info: UndocBoxLayout, editing: Bool = false) {
        super.configureWithInfo(info, editing: editing)
        
        if let image = info.picInfo?.image {
            
            imageView.image = image
            
        } else {
            
            imageView.spider_showActivityIndicatorWhenLoading = true
            imageView.spider_setImageWith(info.picInfo!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
