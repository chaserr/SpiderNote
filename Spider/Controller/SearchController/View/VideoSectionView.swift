//
//  VoiceView.swift
//  Spider
//
//  Created by 童星 on 16/8/8.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import SnapKit
class VideoSectionView: UIView {

    typealias TapVideoAction = (_ type:ClickViewType) -> Void
    var tapVideoAction:TapVideoAction!
    
    var seperatorView: UIView!
    var startTime: UILabel!
    var endTime: UILabel!
    var timeProgress: UIView!
    var videoTagBackView: UIView!
    var videoTagView: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        seperatorView                    = UIView()
        seperatorView.backgroundColor    = RGBCOLORV(0xeaeaea)
        startTime                        = UILabel()
        startTime.font                   = SYSTEMFONT(14)
        startTime.textColor              = RGBCOLORV(0x404040)
        endTime                          = UILabel()
        endTime.font                     = SYSTEMFONT(14)
        endTime.textColor                = RGBCOLORV(0x404040)
        timeProgress                     = UIView()
        timeProgress.backgroundColor     = RGBCOLORV(0xe7e7e7)
        videoTagBackView                 = UIView()
        videoTagBackView.backgroundColor = RGBCOLORV(0xf0f0f0)
        videoTagView                     = UILabel()
        videoTagView.font                = SYSTEMFONT(16)
        videoTagView.textColor           = RGBCOLORV(0x666666)

        addSubview(seperatorView)
        addSubview(startTime)
        addSubview(endTime)
        addSubview(timeProgress)
        addSubview(videoTagBackView)
        videoTagBackView.addSubview(videoTagView)
        addUIConstraints()
        addTapGesture { (UITapGestureRecognizer) in
            self.tapVideoAction(ClickViewType.video)
        }
    }

    func addUIConstraints() -> Void {
        seperatorView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview().offset(0)
            make.height.equalTo(1)
        }
        startTime.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(20)
            make.height.width.greaterThanOrEqualTo(40)
        }
        endTime.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.top.equalTo(20)
            make.height.width.greaterThanOrEqualTo(40)
        }
        timeProgress.snp.makeConstraints { (make) in
            make.left.equalTo(startTime.snp.right).offset(15)
            make.right.equalTo(endTime.snp.left).offset(-15)
            make.height.equalTo(5)
            make.centerY.equalTo(startTime)
        }
        videoTagBackView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(startTime.snp.bottom).offset(5)
            make.width.greaterThanOrEqualTo(videoTagView.snp.width).offset(20)
            make.height.greaterThanOrEqualTo(30)

        }
        videoTagView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.greaterThanOrEqualTo(20)
            make.center.equalToSuperview()
        }
    }

    func tapVideoView(_ type:@escaping TapVideoAction) -> Void {
        tapVideoAction = type
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
