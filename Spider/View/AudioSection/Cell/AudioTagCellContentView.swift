//
//  AudioTagCellContentView.swift
//  Spider
//
//  Created by ooatuoo on 16/7/8.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

private let themeColor = UIColor.color(withHex: 0xaaaaaa)
private let tag_unfold_width = kScreenWidth - 15 * 4 - 30 - 1
private let textTagSize = CGSize(width: tag_unfold_width, height: CGFloat(FLT_MAX))

class AudioTagCellContentView: UIView {
    
    private var info: AudioTagInfo!
        
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(9)
        label.textColor = themeColor
        label.textAlignment = .Center
        label.numberOfLines = 0
        return label
    }()
    
    private var lineView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "audio_line"))
        return imageView
    }()
    
    private var dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.color(withHex: 0xd7d7d7)
        return view
    }()
    
    private lazy var textTag: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = themeColor
        return label
    }()
    
    private lazy var picTag: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
        
    // MARK: - Life Cycle
    
    init(info: AudioTagInfo) {
        super.init(frame: CGRectZero)
        self.info = info
        
        timeLabel.text = info.time
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func foldTag() {
        switch info.type {
        case .Pic:
            picTag.snp_updateConstraints(closure: { (make) in
                make.width.height.equalTo(30)
            })
        case .Text:
            textTag.numberOfLines = 1
            textTag.textColor = themeColor
        }
    }
    
    func unfoldTag() -> CGFloat {
        
        switch info.type {
            
        case .Pic:
            
            guard let image = info.pic?.image else { return 0 }
            
            let picTagH = tag_unfold_width / image.size.width * image.size.height
            
            picTag.snp_updateConstraints(closure: { (make) in
                make.size.equalTo(CGSize(width: tag_unfold_width, height: picTagH))
            })
            
            return picTagH + 2 * picTag.frame.origin.y
            
        case .Text:
            
            let textTagH = NSString(string: info.content!).boundingRectWithSize(textTagSize, options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: [NSFontAttributeName: textTag.font], context: nil).height
            
            textTag.numberOfLines = 0
            textTag.textColor = UIColor.blackColor()
            return textTagH + 8.5 * 2
        }
    }
    
    // MARK: - Make UI
    
    func makeUI() {
        addSubview(timeLabel)
        addSubview(lineView)
        addSubview(dotView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        dotView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: kAudioTagCellHeight))
            make.left.equalTo(15)
            make.top.equalTo(0)
        }
        
        lineView.snp_makeConstraints { (make) in
            make.width.equalTo(1)
            make.top.bottom.equalTo(self)
            make.left.equalTo(timeLabel.snp_right).offset(14)
        }
        
        dotView.snp_makeConstraints { (make) in
            make.width.height.equalTo(6)
            make.centerX.equalTo(lineView)
            make.top.equalTo((kAudioTagCellHeight - 6)*0.5)
        }
        
        // add tagView
        switch info.type {
            
        case .Pic:
            
            if let image = info.pic?.image {
                picTag.image = image
            } else {
                picTag.spider_showActivityIndicatorWhenLoading = true
                picTag.spider_setImageWith(info.pic!)
            }
                        
            addSubview(picTag)
            picTag.translatesAutoresizingMaskIntoConstraints = false
            
            picTag.snp_makeConstraints(closure: { (make) in
                make.width.height.equalTo(30)
                make.left.equalTo(lineView.snp_right).offset(15)
                make.top.equalTo((kAudioTagCellHeight - 30)*0.5)
            })
            
        case .Text:
            
            textTag.text = info.content
            addSubview(textTag)
            
            textTag.translatesAutoresizingMaskIntoConstraints = false
            
            textTag.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(lineView.snp_right).offset(15)
                make.right.equalTo(-15)
                make.top.equalTo(8.5)
            })
        }
    }
}
