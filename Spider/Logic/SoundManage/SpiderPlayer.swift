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

    var lastPlayedTime: TimeInterval = 0
    var lastID: String = ""
    var playingID: String = ""
    
    func prepareToPlay(_ audioInfo: AudioInfo, at startTime: TimeInterval = 0) {
        guard let audioURL = APP_UTILITY.getAudioFilePath(audioInfo.id) else { return }
        
        if let player = player {
            lastPlayedTime = player.currentTime
            lastID = playingID
            
            player.stop()
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: audioURL)
            player?.delegate = self
            
            playingID = audioInfo.ownerID
            player?.prepareToPlay()
            player?.currentTime = startTime
            
            player?.delegate = self
            
        } catch {
            AODlog("SpiderPlayer init player failed: \n \(error)")
        }
    }
    
    func prepareToPlay(_ url: URL) -> AVAudioPlayer? {
        reset()
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
        } catch {
            AODlog("SpiderPlayer init player failed: \n \(error)")
        }
        
        return player
    }
    
    func play(at time: TimeInterval) {
        
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        lastPlayedTime = player.duration
        lastID = playingID
        playingID = ""
        changed = true
    }
    
    override init() {
        super.init()
        
        AODlog(" Init Spider Player ........ ")

        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    func handleRouteChange(_ notification: Notification) {
        guard let info = notification.userInfo,
            let changeKey = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let changeReason = AVAudioSessionRouteChangeReason(rawValue: changeKey),
            let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription,
            let output = previousRoute.outputs.first
            
            else { return }
        
        if changeReason == .oldDeviceUnavailable && output.portType == AVAudioSessionPortHeadphones {
            AODlog(" Headphone has plugged out...........")
            self.pause()
        }
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        AODlog(" Spider Player Begin Interruption ")
        pause()
    }
    
    deinit {
        AODlog(" deinit Spider Player ........ ")
        NotificationCenter.default.removeObserver(self)
    }
}
