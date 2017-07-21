//
//  AddMediaView.swift
//  Spider
//
//  Created by 童星 on 5/10/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class AddMediaView: UIVisualEffectView {
    
    var removeHandler: (() -> Void)?
    
    var addPicHandler:   (() -> Void)?
    var addAudioHandler: (() -> Void)?
    var addTextHandler:  ((String) -> Void)?
    
    fileprivate enum MediaType: Int {
        case text  = 11
        case pic   = 22
        case audio = 33
    }
    
    fileprivate var unDoc: Bool = false
    
    init(unDoc: Bool) {
        let blurEffect = UIBlurEffect(style: .extraLight)
        super.init(effect: blurEffect)
        
        self.unDoc = unDoc
        self.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        addSubviews()
    }
    
    func didTap() {
        if let handler = removeHandler {
            handler()
        } else {
            removeFromSuperview()
        }
    }
    
    func addTo(_ view: UIView) {
        alpha = 0
        view.addSubview(self)
        UIView.animate(withDuration: 0.3, animations: { 
            self.alpha = 1
        }) 
    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }, completion: { done in
            super.removeFromSuperview()
        }) 
    }
    
    func addMediaClicked(_ sender: UIButton) {
        
        guard let type = MediaType(rawValue: sender.tag),
                  let currentVC = AppNavigator.instance?.topVC else {
                    
            return
        }
        
        switch type {
            
        case .text:

            if unDoc {
                
                AddUndocTextView().moveTo(APP_NAVIGATOR.mainNav!.view)
                
            } else {
                
                let addTextSectionView = AddTextSectionView()
                
                addTextSectionView.doneHandler = { text in
                    SpiderRealm.updateTextSection(with: text)
                }
                
                addTextSectionView.moveTo(currentVC.view)
            }

        case .pic:
            
            let picker = TZImagePickerController(maxCount: 4, animated: false, completion: { [weak self] photos in
                let vc = PicDetailViewController(photos: photos)
                
                if self!.unDoc {
                    currentVC.present(vc, animated: true, completion: nil)
                } else {
                    APP_NAVIGATOR.mainNav?.pushViewController(vc, animated: true)
                }
            })
            
            currentVC.present(picker, animated: true, completion: nil)

        case .audio:
            
            currentVC.present(AudioSectionViewController(), animated: true, completion: nil)
        }
        
        didTap()
    }
    
    func addSubviews() {
        let buttonS = CGFloat(60)
        let logoS = CGFloat(120)
        
        let logo = UIImageView(frame: CGRect(x: 0, y: 0, width: logoS, height: logoS))
        logo.image = UIImage(named: "logo")
        logo.center = CGPoint(x: center.x, y: center.y - logoS - 60)
        logo.layer.cornerRadius = logoS / 2
        self.contentView.addSubview(logo)
        
        let addPicButton = MediaButton(index: 2, imageName: "media_pic_button", superView: self)
        self.contentView.addSubview(addPicButton)
        
        let addTextButton = MediaButton(index: 1, imageName: "media_text_button", superView: self)
        self.contentView.addSubview(addTextButton)
        
        let addAudioButton = MediaButton(index: 3, imageName: "media_audio_button", superView: self)
        self.contentView.addSubview(addAudioButton)
        
        // set labels
        let labelH = CGFloat(8)
        
        let logoLabel = MediaLabel(frame: CGRect(x: 0, y: 0, width: logoS * 2, height: 40), text: "蜘蛛笔记")
        logoLabel.center = CGPoint(x: logo.center.x, y: logo.center.y + logoS / 2 + 35)
        if #available(iOS 8.2, *) {
            logoLabel.font = UIFont.systemFont(ofSize: 20, weight: 30)
        } else {
            // Fallback on earlier versions
        }
        logoLabel.textColor = UIColor.white
        self.contentView.addSubview(logoLabel)
        
        let textLabel = MediaLabel(frame: CGRect(x: 0, y: 0, width: buttonS, height: labelH), text: "文字")
        textLabel.center = CGPoint(x: addTextButton.center.x, y: addTextButton.center.y + buttonS / 2 + 22)
        self.contentView.addSubview(textLabel)
        
        let cameraLabel = MediaLabel(frame: CGRect(x: 0, y: 0, width: buttonS, height: labelH), text: "图片")
        cameraLabel.center = CGPoint(x: addPicButton.center.x, y: addPicButton.center.y + buttonS / 2 + 22)
        self.contentView.addSubview(cameraLabel)
        
        let audioLabel = MediaLabel(frame: CGRect(x: 0, y: 0, width: buttonS, height: labelH), text: "录音")
        audioLabel.center = CGPoint(x: addAudioButton.center.x, y: addAudioButton.center.y + buttonS / 2 + 22)
        self.contentView.addSubview(audioLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class MediaLabel: UILabel {
    init(frame: CGRect, text: String) {
        super.init(frame: frame)
        self.textAlignment = .center
        self.text = text
        textColor = UIColor.gray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class MediaButton: UIButton {
    init(index: Int, imageName: String, superView: UIView) {
        super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        let centerX = superView.center.x + CGFloat(index - 2) * 120
        center = CGPoint(x: centerX, y: superView.center.y)
        setImage(UIImage(named: imageName), for: UIControlState())
        tag = index * 11
        
        addTarget(superView, action: #selector(AddMediaView.addMediaClicked(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
