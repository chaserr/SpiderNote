//
//  UndocAudioCell.swift
//  Spider
//
//  Created by ooatuoo on 16/8/19.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class UndocAudioCell: UndocBaseCell {

    private var durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(19)
        label.textAlignment = .Center
        label.textColor = UIColor.color(withHex: 0x686868)
        return label
    }()
    
    private let bgView: UIImageView = {
        return UIImageView(image: UIImage(named: "unchive_audio_icon"))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(bgView)
        contentView.addSubview(durationLabel)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bgView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 79, height: 53))
            make.centerX.equalTo(contentView)
            make.centerY.equalTo(contentView).offset(-16)
        }
        
        durationLabel.snp_makeConstraints { (make) in
            make.right.left.equalTo(contentView)
            make.height.equalTo(40)
            make.top.equalTo(bgView.snp_bottom).offset(2)
        }
    }
    
    override func configureWithInfo(info: UndocBoxLayout, editing: Bool = false) {
        super.configureWithInfo(info, editing: editing)
        durationLabel.text = info.duration
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
