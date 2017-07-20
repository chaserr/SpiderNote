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
    fileprivate var player: AVAudioPlayer!
    var duration: TimeInterval!
    
    init?(contentsOfURL url: URL, info: [String : AnyObject]? = nil) {
        super.init()
        
        player = try! AVAudioPlayer(contentsOf: url)
        duration = player.duration
        player.prepareToPlay()
        
        let center = MPRemoteCommandCenter.shared()
        center.pauseCommand.addTarget (handler: { event -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            return .success
        })
        
        center.playCommand.addTarget (handler: { event -> MPRemoteCommandHandlerStatus in
            self.player.play()
            return .success
        })
        
        if let aInfo = info {
            var centerInfo = [
                MPMediaItemPropertyTitle: aInfo["title"] as! String,
                MPMediaItemPropertyPlaybackDuration: NSNumber(value: self.player.duration as Double)
            ] as [String : Any]
            
            if let imageName = aInfo["artwork"] as? String {
                let artwork = MPMediaItemArtwork(image: UIImage(named: imageName)!)
                centerInfo[MPMediaItemPropertyArtwork] = artwork
            }
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = centerInfo
        }
    }
    
    func pause() {
        player.pause()
    }
    
    func play() {
        player.play()
    }
}
