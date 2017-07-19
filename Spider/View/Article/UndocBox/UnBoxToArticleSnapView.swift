//
//  UnBoxToArticleSnapView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/25.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

class UnBoxToArticleSnapView: UIView {
    
    init?(info: UndocBoxLayout) {
        
        switch info.type {
            
        case .pic:

            guard let picInfo = info.picInfo else {
                AODlog(" UnBoxToArticleSnapView Init Failed: can't get pic info ")
                return nil
            }
            
            super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth * 0.8, height: 200))
            
            let imageView = UIImageView(frame: bounds)
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            
            if let image = picInfo.image {
                
                imageView.image = image
                
            } else {
                
                imageView.image = UIImage(named: kTmpImageName)
                imageView.spider_showActivityIndicatorWhenLoading = true
                imageView.spider_setImageWith(picInfo)
            }
            
            addSubview(imageView)
            
        case .text:
            
            guard let text = info.text else {
                AODlog(" UnBoxToArticleSnapView Init Failed: can't get text info ")
                return nil
            }
            
            let rect = text.boundingRect(with: CGSize(width: kScreenWidth * 0.8 - 30, height: CGFloat(FLT_MAX)), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSFontAttributeName: SpiderConfig.Font.Text], context: nil)
            
            super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth * 0.8, height: ceil(rect.height) + 20))

            let label = UILabel(frame: CGRect(x: 15, y: 10, width: kScreenWidth * 0.8 - 30, height: ceil(rect.height)))
            label.text = text
            label.font = SpiderConfig.Font.Text
            label.textColor = SpiderConfig.Color.DarkText
            label.numberOfLines = 0
            
            addSubview(label)
            
        case .audio:
            
            guard let duration = info.duration else {
                AODlog(" UnBoxToArticleSnapView Init Failed: can't get audio info ")
                return nil
            }
            
            super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth * 0.8, height: kArticleAudioHeight + 20))
            let playerView = AudioPlayerView(frame: CGRect(x: 0, y: 10, width: kScreenWidth * 0.8, height: kArticleAudioHeight), duration: duration)
            addSubview(playerView)
        }
        
        backgroundColor = UIColor.white
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.25
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
