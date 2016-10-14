//
//  SpiderPlayer.swift
//  Spider
//
//  Created by ooatuoo on 16/8/15.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation

final class SpiderPlayer: NSObject, AVAudioPlayerDelegate {
    static let sharedManager = SpiderPlayer()
    
    dynamic var changed: Bool = true
    
    var player: AVAudioPlayer?

    var lastPlayedTime: NSTimeInterval = 0
    var lastID: String = ""
    var playingID: String = ""
    
    func prepareToPlay(audioInfo: AudioInfo, at startTime: NSTimeInterval = 0) {
        guard let audioURL = APP_UTILITY.getAudioFilePath(audioInfo.id) else { return }
        
        if let player = player {
            lastPlayedTime = player.currentTime
            lastID = playingID
            
            player.stop()
        }
        
        do {
            player = try AVAudioPlayer(contentsOfURL: audioURL)
            player?.delegate = self
            
            playingID = audioInfo.ownerID
            player?.prepareToPlay()
            player?.currentTime = startTime
            
            player?.delegate = self
            
        } catch {
            println("SpiderPlayer init player failed: \n \(error)")
        }
    }
    
    func prepareToPlay(url: NSURL) -> AVAudioPlayer? {
        reset()
        
        do {
            player = try AVAudioPlayer(contentsOfURL: url)
            player?.delegate = self
        } catch {
            println("SpiderPlayer init player failed: \n \(error)")
        }
        
        return player
    }
    
    func play(at time: NSTimeInterval) {
        
        if let player = player {
            player.currentTime = time
            player.play()
        }
    }
    
    func reset() {
        player?.stop()
        player = nil
        lastPlayedTime = 0
        lastID = ""
        playingID = ""
    }
    
    func pause() {
        player?.pause()
        changed = true
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        lastPlayedTime = player.duration
        lastID = playingID
        playingID = ""
        changed = true
    }
    
    override init() {
        super.init()
        
        println(" Init Spider Player ........ ")

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleRouteChange(_:)), name: AVAudioSessionRouteChangeNotification, object: nil)
    }
    
    func handleRouteChange(notification: NSNotification) {
        guard let info = notification.userInfo,
            changeKey = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
            changeReason = AVAudioSessionRouteChangeReason(rawValue: changeKey),
            previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription,
            output = previousRoute.outputs.first
            
            else { return }
        
        if changeReason == .OldDeviceUnavailable && output.portType == AVAudioSessionPortHeadphones {
            println(" Headphone has plugged out...........")
            self.pause()
        }
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        println(" Spider Player Begin Interruption ")
        pause()
    }
    
    deinit {
        println(" deinit Spider Player ........ ")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
