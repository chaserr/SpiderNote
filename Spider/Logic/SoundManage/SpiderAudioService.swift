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
    let queue = DispatchQueue(label: "SpiderAudioService", attributes: [])
    
    var audioFileURL: URL?
    
    var audioRecorder: AVAudioRecorder?
    
    var audioPlayer: AVAudioPlayer?
    
    var audioPlayCurrentTime: TimeInterval {
        if let audioPlayer = audioPlayer {
            return audioPlayer.currentTime
        } else {
            return 0
        }
    }
    
    var recording: Bool {
        if let audioRecorder = audioRecorder {
            if audioRecorder.isRecording {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    var currentTime: TimeInterval {
        if let audioRecorder = audioRecorder {
            return audioRecorder.currentTime
        } else {
            return 0
        }
    }
    
    func beginRecordWithFileURL(_ fileURL: URL, audioRecorderDelegate: AVAudioRecorderDelegate) {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
        } catch let error {
            AODlog("beginRecordWithFileURL setCategory failed: \(error)")
        }
        
        do {
            proposeToAccess(.microphone, agreed: {
                
                self.prepareAudioRecorderWithFileURL(fileURL, delegate: audioRecorderDelegate)
                
                if let audioRecorder = self.audioRecorder {
                    
                    if (audioRecorder.isRecording) {
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
        guard let url = URL(string: APP_UTILITY.voiceFilePath()) else { return nil }
        let id = UUID().uuidString
        
        let audioURL = url.appendingPathComponent("\(id).\(FileExtension.M4A.rawValue)")
        beginRecordWithFileURL(audioURL, audioRecorderDelegate: delegate)
        
        return id
    }
    
    func pauseRecord() {
        if let audioRecorder = audioRecorder {
            if audioRecorder.isRecording {
                audioRecorder.pause()
            }
        }
    }
    
    func resumeRecord() {
        if let audioRecorder = audioRecorder {
            if !audioRecorder.isRecording {
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
    
    func prepareAudioRecorderWithFileURL(_ fileURL: URL, delegate: AVAudioRecorderDelegate) {
        audioFileURL = fileURL
        
        let settings: [String: AnyObject] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC) as AnyObject,
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue as AnyObject,
            AVEncoderBitRateKey : 64000 as AnyObject,
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVSampleRateKey : 44100.0 as AnyObject
        ]
        
        do {
            
            let audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder.delegate = delegate
            audioRecorder.prepareToRecord() // creates/overwrites the file at soundFileURL
            
            try AVAudioSession.sharedInstance().setActive(true)
            self.audioRecorder = audioRecorder
            
        } catch let error {
            self.audioRecorder = nil
            AODlog("create AVAudioRecorder error: \(error)")
        }
    }
}
