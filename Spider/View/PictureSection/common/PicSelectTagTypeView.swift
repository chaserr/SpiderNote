//
//  PicSelectTagTypeView.swift
//  Spider
//
//  Created by Atuooo on 5/30/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class PicSelectTagTypeView: UIView {
    var text: UIButton!
    var pic: UIButton!
    var audio: UIButton!
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        
        backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight - kPicAddTagViewH, width: kScreenWidth, height: kPicAddTagViewH))
        view.backgroundColor = UIColor.white
        addSubview(view)
        
        text = UIButton(frame: CGRect(x: kPicTagTypeOx1, y: kPicTagTypeOy, width: kPicTagTypeS, height: kPicTagTypeS))
        text.setBackgroundImage(UIImage(named: "pic_tag_text_button"), for: UIControlState())
        view.addSubview(text)
        
        pic = UIButton(frame: CGRect(x: kPicTagTypeOx2, y: kPicTagTypeOy, width: kPicTagTypeS, height: kPicTagTypeS))
        pic.setBackgroundImage(UIImage(named: "pic_tag_pic_button"), for: UIControlState())
        view.addSubview(pic)
        
        audio = UIButton(frame: CGRect(x: kPicTagTypeOx3, y: kPicTagTypeOy, width: kPicTagTypeS, height: kPicTagTypeS))
        audio.setBackgroundImage(UIImage(named: "pic_tag_audio_button"), for: UIControlState())
        view.addSubview(audio)
        
        let textLabel = PicTagLabel(text: "文字")
        textLabel.center = CGPoint(x: text.center.x, y: text.center.y + 38)
        view.addSubview(textLabel)
        
        let picLabel = PicTagLabel(text: "图片")
        picLabel.center = CGPoint(x: pic.center.x, y: pic.center.y + 38)
        view.addSubview(picLabel)
        
        let audioLabel = PicTagLabel(text: "录音")
        audioLabel.center = CGPoint(x: audio.center.x, y: audio.center.y + 38)
        view.addSubview(audioLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hide))
        addGestureRecognizer(tap)
    }
    
    func hide() {
        isHidden = true
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        // 取消添加图片标签返回时隐藏
        if isHidden == false {
            isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class PicTagLabel: UILabel {
    init(text: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.text = text
        textColor = UIColor.color(withHex: 0x555555)
        textAlignment = .center
        font = UIFont.systemFont(ofSize: 12)
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
