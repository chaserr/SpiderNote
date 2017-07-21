//
//  PicPicTagView.swift
//  Spider
//
//  Created by 童星 on 5/31/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit
import Kingfisher

class PicPicTagView: PicTagView {
    fileprivate var imageV: UIImageView!
    
    init(location: CGPoint, picInfo: PicInfo, direction: TagDirection, inSize: CGSize) {
        super.init(frame: CGRect(x: location.x - 5, y: location.y - kPicPicTagH / 2, width: kPicPicTagW, height: kPicPicTagH))
        self.type = .pic
        self.direction = direction
        
        isUserInteractionEnabled = true
        
        let dot: UIImageView = {
            let imageV = UIImageView(frame: CGRect(x: 0, y: kPicPicTagH / 2 - kPicTagDotS / 2, width: kPicTagDotS, height: kPicTagDotS))
            imageV.image = UIImage(named: "pic_tag_dot")
            return imageV
        }()
        
        let imageBG: UIImageView = {
            let imageV = UIImageView(frame: CGRect(x: 15, y: 0, width: kPicPicBGW, height: kPicPicTagH))
            imageV.image = UIImage(named: "pic_pic_tag_bg")
            return imageV
        }()
        
        contentView = {
            
            let imageV = UIImageView(frame: CGRect(x: 35, y: 2.5, width: 40, height: 40))
            imageV.contentMode = .scaleAspectFill
            imageV.layer.masksToBounds = true
            
            if let image = picInfo.image {
                
                imageV.image = image
                
            }  else {
                
                imageV.spider_showActivityIndicatorWhenLoading = true
                imageV.spider_setImageWith(picInfo)
            }
            
            return imageV
        }()
        
        addSubview(dot)
        addSubview(imageBG)
        addSubview(contentView)
        
        switch direction {
        case .right:
            break
            
        case .left:
            
            transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            contentView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            frame.origin = CGPoint(x: location.x - kPicPicTagW + 5, y: location.y - kPicPicTagH / 2)
            
        case .none:
            
            self.direction = .right
            if (location.x + kPicPicTagW) >= inSize.width {
                rotate()
                frame.origin = CGPoint(x: location.x - kPicPicTagW + 5, y: location.y - kPicPicTagH / 2)
            }
        }
    }
    
    override func didLongPress(_ sender: UILongPressGestureRecognizer) {
        super.didLongPress(sender)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
