//
//  ArticleAudioCell.swift
//  Spider
//
//  Created by ooatuoo on 16/7/7.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

private let commonCenterY = kArticleAudioCellVS - kArticlePlusHeight / 2 + kArticleAudioHeight / 2

class ArticleAudioCell: ArticleBaseCell {
    
    fileprivate var beEditing = false
    
    fileprivate var audioPlayerView: AudioPlayerView!
    
    fileprivate var tagCountView: SectionTagCountView = {
        return SectionTagCountView()
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let rect = CGRect(x: 0, y: kArticleAudioCellVS - kArticlePlusHeight / 2, width: kScreenWidth, height: kArticleAudioHeight)
        audioPlayerView = AudioPlayerView(frame: rect)
        contentView.addSubview(audioPlayerView)
        
        contentView.addSubview(tagCountView)
        tagCountView.translatesAutoresizingMaskIntoConstraints = false
        
        tagCountView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 20, height: 23))
            make.top.equalTo(0)
            make.right.equalTo(contentView).offset(-8)
        }
    }
    
    func congfigureWithSection(_ section: SectionObject, layout: SectionLayout, editing: Bool) {
        super.configureSection(layout, editing: editing)
        
        let audioInfo = AudioInfo(section: section)
        tagCountView.tagCount = section.tagCount
        audioPlayerView.prepareToPaly(audioInfo, playedTime: layout.playedTime)
        
        if beEditing != editing {
            beEditing = editing
            
            audioPlayerView.center.y = editing ? frame.height / 2 + 2 : commonCenterY
            tagCountView.isHidden = editing
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
