//
//  AudioTagTableView.swift
//  Spider
//
//  Created by ooatuoo on 16/7/8.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

private let cellID = "AudioSectionCellID"

class AudioTagTableView: UITableView {
    init() {
        super.init(frame: CGRect(x: 0, y: kAudioTitleHeight, width: kScreenWidth, height: kAudioTagInfoViewHeight), style: .Plain)
        
        sectionIndexColor = UIColor.whiteColor()
        registerClass(AudioTagInfoCell.self, forCellReuseIdentifier: cellID)
        backgroundColor = UIColor.whiteColor()
        separatorStyle = .None
        bounces = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
