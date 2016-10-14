//
//  AudioPlayer.swift
//  Spider
//
//  Created by Atuooo on 5/17/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class AudioPlayer: NSObject {
    private var player: AVAudioPlayer!
    var duration: NSTimeInterval!
    
    init?(contentsOfURL url: NSURL, info: [String : AnyObject]? = nil) {
        super.init()
        
        player = try! AVAudioPlayer(contentsOfURL: url)
        duration = player.duration
        player.prepareToPlay()
        
        let center = MPRemoteCommandCenter.sharedCommandCenter()
        center.pauseCommand.addTargetWithHandler { event -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            return .Success
        }
        
        center.playCommand.addTargetWithHandler { event -> MPRemoteCommandHandlerStatus in
            self.player.play()
            return .Success
        }
        
        if let aInfo = info {
            var centerInfo = [
                MPMediaItemPropertyTitle: aInfo["title"] as! String,
                MPMediaItemPropertyPlaybackDuration: NSNumber(double: self.player.duration)
            ]
            
            if let imageName = aInfo["artwork"] as? String {
                let artwork = MPMediaItemArtwork(image: UIImage(named: imageName)!)
                centerInfo[MPMediaItemPropertyArtwork] = artwork
            }
            
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = centerInfo
        }
    }
    
    func pause() {
        player.pause()
    }
    
    func play() {
        player.play()
    }
}
