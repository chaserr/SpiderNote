//
//  PicSectionView.swift
//  Spider
//
//  Created by 童星 on 16/8/8.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class PicSectionView: UIView {

    typealias TapPicAction = (type:ClickViewType) -> Void
    var tapPicAction:TapPicAction!
    
    var seperatorView: UIView!
    var imageView: UIImageView!
    var tagBackview: UIImageView!
    var imageTagView: UILabel!


    override init(frame: CGRect) {
        super.init(frame: frame)

        seperatorView                 = UIView()
        seperatorView.backgroundColor = RGBCOLORV(0xeaeaea)
        imageView                     = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        tagBackview                   = UIImageView()
        tagBackview.backgroundColor   = RGBCOLORVA(0x000000, alphaValue: 0.5)
        imageTagView                  = UILabel()
        imageTagView.font             = SYSTEMFONT(16)
        imageTagView.textColor        = RGBCOLORV(0xffffff)
        imageTagView.numberOfLines    = 0

        addSubview(seperatorView)
        addSubview(imageView)
        imageView.addSubview(tagBackview)
        tagBackview.addSubview(imageTagView)
        addUIConstraints()
        addTapGesture { (UITapGestureRecognizer) in
            self.tapPicAction(type:ClickViewType.Pic)
        }

    }

    func addUIConstraints() -> Void {
        seperatorView.snp_makeConstraints { (make) in
            make.left.top.right.equalToSuperview().offset(0)
            make.height.equalTo(1)
        }
        imageView.snp_makeConstraints { (make) in
            make.left.equalTo(15)
            make.center.equalToSuperview()
            make.top.equalTo(seperatorView.snp_bottom).offset(10)
        }
        tagBackview.snp_makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        imageTagView.snp_makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(8)
            make.center.equalToSuperview()
        }
    }

    func tapPicView(type:TapPicAction) -> Void {
        tapPicAction = type
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
