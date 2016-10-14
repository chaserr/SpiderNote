//
//  PicTextTagView.swift
//  Spider
//
//  Created by Atuooo on 6/2/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class PicTextTagView: PicTagView {
    
    private var inSize: CGSize!
    
    var text: String! {
        didSet {
            (contentView as! UILabel).text = text
            (contentView as! UILabel).sizeToFit()
            
            let labelW = (contentView.frame.width > kPicTextMaxW ? kPicTextMaxW : contentView.frame.width)
            bgView.frame.size = CGSize(width: labelW + 20, height: kPicTextTagH)
            
            contentView.frame = CGRect(x: 14+15, y: contentView.frame.origin.y, width: labelW, height: contentView.frame.height)
            
            frame.size = CGSize(width: 15 + bgView.frame.width, height: kPicTextTagH)
            
            if direction == .Right {
                if frame.maxX >= inSize.width {
                    rotate()
                    frame.origin = CGPoint(x: frame.origin.x - frame.size.width, y: frame.origin.y)
                }
            }
        }
    }
    
    private var bgView: UIImageView!
    
    init(location: CGPoint, text: String, direction: TagDirection, inSize: CGSize) {
        super.init(frame: CGRect(x: location.x - 5, y: location.y - kPicTextTagH / 2, width: 0, height: kPicTextTagH))
        self.type = .Text
        self.inSize = inSize
        
        let dot: UIImageView = {
            let imageV = UIImageView(frame: CGRect(x: 0, y: kPicAudioBGH / 2 - kPicTagDotS / 2, width: kPicTagDotS, height: kPicTagDotS))
            imageV.image = UIImage(named: "pic_tag_dot")
            return imageV
        }()
        
        contentView = {
            let label = UILabel()
            label.text = text
            label.font = UIFont.systemFontOfSize(12)
            label.textColor = UIColor.whiteColor()
            label.sizeToFit()
            return label
        }()
        
        let labelW = (contentView.frame.width > kPicTextMaxW ? kPicTextMaxW : contentView.frame.width)
        bgView = {
            let imageV = UIImageView(frame: CGRect(x: 15, y: 0, width: labelW + 20, height: kPicTextTagH))
            imageV.image = UIImage(named: "pic_text_tag_bg")
            imageV.contentMode = .ScaleToFill
            return imageV
        }()

        contentView.frame = CGRect(x: 14 + 15, y: (kPicTextTagH - contentView.frame.height) / 2, width: labelW, height: contentView.frame.height)
        
        self.text = text
        addSubview(dot)
        addSubview(bgView)
        addSubview(contentView)
        
        frame.size = CGSize(width: 15 + bgView.frame.width, height: kPicTextTagH)
        
        switch direction {
        case .Right:
            break
        case .Left:
            
            transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            
            frame.origin = CGPoint(x: location.x - frame.size.width + 5, y: frame.origin.y)

        case .None:
            
            self.direction = .Right
            
            if (location.x + frame.size.width) >= inSize.width {
                rotate()
                frame.origin = CGPoint(x: location.x - frame.size.width + 5, y: frame.origin.y)
            }
        }
        // 若超出边界则翻转

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
