//
//  AudioTagInfoCell.swift
//  Spider
//
//  Created by Atuooo on 5/25/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

private let cellID = "AudioSectionCellID"

class AudioTagInfoCell: UITableViewCell {
    var tagInfoView: AudioTagCellContentView! //AudioTagInfoView!
    
    fileprivate var tagInfo: AudioTagInfo!
    
    init(info: AudioTagInfo) {
        super.init(style: .default, reuseIdentifier: cellID)
        selectionStyle = .none
        tagInfo = info
        tagInfoView = AudioTagCellContentView(info: info) // AudioTagInfoView(info: info, height: height)
        contentView.addSubview(tagInfoView)
        
        tagInfoView.translatesAutoresizingMaskIntoConstraints = false
        tagInfoView.snp_makeConstraints { (make) in
            make.left.top.bottom.right.equalTo(self)
        }
        
        if info.selected {
            unfoldTag()
        }
    }
    
    func foldTag() {
        tagInfoView.foldTag()
    }
    
    func unfoldTag() -> CGFloat {
        return tagInfoView.unfoldTag()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
