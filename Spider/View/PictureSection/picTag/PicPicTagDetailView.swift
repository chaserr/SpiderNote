//
//  PicPicTagDetailView.swift
//  Spider
//
//  Created by Atuooo on 6/2/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class PicPicTagDetailView: UIView {
    init(image: UIImage) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        backgroundColor = UIColor.black
        
        let imageVH = kScreenWidth / image.size.width * kScreenHeight
        let imageView = UIImageView(frame: CGRect(x: 0, y: (kScreenHeight - imageVH) / 2, width: kScreenWidth, height: imageVH))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeFromSuperview))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
