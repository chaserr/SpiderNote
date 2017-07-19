//
//  PicAudioTagView.swift
//  Spider
//
//  Created by Atuooo on 6/1/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit
import AVFoundation

class PicAudioTagView: PicTagView, AVAudioPlayerDelegate {
    fileprivate var player: AVAudioPlayer? = nil
    fileprivate var audioInfo: AudioInfo!
    
    fileprivate var icon: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 12, y: (kPicAudioBGH - kPicAudioiConH) / 2, width: kPicAudioiConW, height: kPicAudioiConH))
        view.animationImages = [
            UIImage(named: "pic_audio_tag_icon1")!,
            UIImage(named: "pic_audio_tag_icon2")!,
            UIImage(named: "pic_audio_tag_icon3")!
        ]
        view.animationDuration = 1.3
        view.image = UIImage(named: "pic_audio_tag_icon3")
        return view
    }()
    
    init(location: CGPoint, audioInfo: AudioInfo, direction: TagDirection, inSize: CGSize) {
        super.init(frame: CGRect(x: location.x - 5, y: location.y - kPicAudioBGH / 2, width: kPicAudioBGW + 15, height: kPicAudioBGH))
        self.type      = .audio
        self.audioInfo = audioInfo
        self.direction = direction
        
        let dot: UIImageView = {
            let view = UIImageView(frame: CGRect(x: 0, y: kPicAudioBGH / 2 - kPicTagDotS / 2, width: kPicTagDotS, height: kPicTagDotS))
            view.image = UIImage(named: "pic_tag_dot")
            return view
        }()
        
        let bg: UIImageView = {
            let view = UIImageView(frame: CGRect(x: 15, y: 0, width: kPicAudioBGW, height: kPicAudioBGH))
            view.image = UIImage(named: "pic_audio_tag_bg")
            view.addSubview(icon)
            return view
        }()
        
        contentView = {
            let label = UILabel(frame: CGRect(x: 15+12+kPicAudioiConW+4, y: 0, width: kPicAudioLabelW, height: kPicAudioBGH))
            label.text = "\(audioInfo.duration)\""
            label.textAlignment = .center
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 11)
            return label
        }()
        
        addSubview(dot)
        addSubview(bg)
        addSubview(contentView)
        isUserInteractionEnabled = true
        
        switch direction {
        case .right:
            break
            
        case .left:
            transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            contentView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            frame.origin = CGPoint(x: location.x - kPicAudioBGW - 15 + 5, y: location.y - kPicAudioBGH / 2)
        case .none:
            self.direction = .right
            
            if (location.x + kPicAudioBGW + 15) > inSize.width {
                rotate()
                frame.origin = CGPoint(x: location.x - kPicAudioBGW - 15 + 5, y: location.y - kPicAudioBGH / 2)
            }
        }
    }
    
    func play() {
        
        if let player = player {
            
            if player.isPlaying {
                
                player.pause()
                icon.stopAnimating()
                icon.image = UIImage(named: "pic_audio_tag_icon3")
                
            } else {
                
                player.play()
                icon.startAnimating()
            }
            
        } else {
            
            guard let audioURL = APP_UTILITY.getAudioFilePath(audioInfo.id) else { return }
            
            do {
                try player = AVAudioPlayer(contentsOf: audioURL, fileTypeHint: AVFileTypeAppleM4A)
                player?.delegate = self
                player?.prepareToPlay()
                
                player?.play()
                icon.startAnimating()
                
            } catch {
                AODlog("error: Pic Audio Tag can't play: \(error)")
            }
        }
    }
    
    func stop() {
        
        player?.stop()
        icon.stopAnimating()
        icon.image = UIImage(named: "pic_audio_tag_icon3")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
