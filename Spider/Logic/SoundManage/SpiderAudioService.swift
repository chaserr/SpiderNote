//
//  SpiderRecorder.swift
//  Spider
//
//  Created by ooatuoo on 16/7/10.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  录音封装

import Foundation

final class SpiderAudioService: NSObject {
    static let sharedManager = SpiderAudioService()
    let queue = dispatch_queue_create("SpiderAudioService", DISPATCH_QUEUE_SERIAL)
    
    var audioFileURL: NSURL?
    
    var audioRecorder: AVAudioRecorder?
    
    var audioPlayer: AVAudioPlayer?
    
    var audioPlayCurrentTime: NSTimeInterval {
        if let audioPlayer = audioPlayer {
            return audioPlayer.currentTime
        } else {
            return 0
        }
    }
    
    var recording: Bool {
        if let audioRecorder = audioRecorder {
            if audioRecorder.recording {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    var currentTime: NSTimeInterval {
        if let audioRecorder = audioRecorder {
            return audioRecorder.currentTime
        } else {
            return 0
        }
    }
    
    func beginRecordWithFileURL(fileURL: NSURL, audioRecorderDelegate: AVAudioRecorderDelegate) {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
        } catch let error {
            println("beginRecordWithFileURL setCategory failed: \(error)")
        }
        
        do {
            proposeToAccess(.Microphone, agreed: {
                
                self.prepareAudioRecorderWithFileURL(fileURL, delegate: audioRecorderDelegate)
                
                if let audioRecorder = self.audioRecorder {
                    
                    if (audioRecorder.recording) {
                        audioRecorder.stop()
                    } else {
                        audioRecorder.record()
                    }
                }
                
                }, rejected: {
//                    if let
//                        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
//                        viewController = appDelegate.window?.rootViewController {
//                        viewController.alertCanNotAccessMicrophone()
//                    }
            })
        }
    }
    
    func beginRecord(withDelegate delegate: AVAudioRecorderDelegate) -> String? {
        guard let url = NSURL(string: APP_UTILITY.voiceFilePath()) else { return nil }
        let id = NSUUID().UUIDString
        
        let audioURL = url.URLByAppendingPathComponent("\(id).\(FileExtension.M4A.rawValue)")
        
        beginRecordWithFileURL(audioURL!, audioRecorderDelegate: delegate)
        
        return id
    }
    
    func pauseRecord() {
        if let audioRecorder = audioRecorder {
            if audioRecorder.recording {
                audioRecorder.pause()
            }
        }
    }
    
    func resumeRecord() {
        if let audioRecorder = audioRecorder {
            if !audioRecorder.recording {
                audioRecorder.record()
            }
        }
    }
    
    func cancelRecord() {
        if let audioRecorder = audioRecorder {
            audioRecorder.stop()
            audioRecorder.deleteRecording()
            try! AVAudioSession.sharedInstance().setActive(false)
        }
    }
    
    func endRecord() {
        if let audioRecorder = audioRecorder {
            audioRecorder.stop()
            try! AVAudioSession.sharedInstance().setActive(false)
        }
    }
    
    func prepareAudioRecorderWithFileURL(fileURL: NSURL, delegate: AVAudioRecorderDelegate) {
        audioFileURL = fileURL
        
        let settings: [String: AnyObject] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 64000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        
        do {
            
            let audioRecorder = try AVAudioRecorder(URL: fileURL, settings: settings)
            audioRecorder.delegate = delegate
            audioRecorder.prepareToRecord() // creates/overwrites the file at soundFileURL
            
            try AVAudioSession.sharedInstance().setActive(true)
            self.audioRecorder = audioRecorder
            
        } catch let error {
            self.audioRecorder = nil
            println("create AVAudioRecorder error: \(error)")
        }
    }
}
