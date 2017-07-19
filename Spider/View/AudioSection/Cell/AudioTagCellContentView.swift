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
    
    fileprivate var info: AudioTagInfo!
        
    fileprivate var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = themeColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate var lineView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "audio_line"))
        return imageView
    }()
    
    fileprivate var dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.color(withHex: 0xd7d7d7)
        return view
    }()
    
    fileprivate lazy var textTag: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = themeColor
        return label
    }()
    
    fileprivate lazy var picTag: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    fileprivate lazy var playButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
        
    // MARK: - Life Cycle
    
    init(info: AudioTagInfo) {
        super.init(frame: CGRect.zero)
        self.info = info
        
        timeLabel.text = info.time
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func foldTag() {
        switch info.type {
        case .pic:
            picTag.snp_updateConstraints(closure: { (make) in
                make.width.height.equalTo(30)
            })
        case .text:
            textTag.numberOfLines = 1
            textTag.textColor = themeColor
        }
    }
    
    func unfoldTag() -> CGFloat {
        
        switch info.type {
            
        case .pic:
            
            guard let image = info.pic?.image else { return 0 }
            
            let picTagH = tag_unfold_width / image.size.width * image.size.height
            
            picTag.snp_updateConstraints(closure: { (make) in
                make.size.equalTo(CGSize(width: tag_unfold_width, height: picTagH))
            })
            
            return picTagH + 2 * picTag.frame.origin.y
            
        case .text:
            
            let textTagH = NSString(string: info.content!).boundingRect(with: textTagSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: textTag.font], context: nil).height
            
            textTag.numberOfLines = 0
            textTag.textColor = UIColor.black
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
            
        case .pic:
            
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
            
        case .text:
            
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
