//
//  PicAddAudioTagView.swift
//  Spider
//
//  Created by Atuooo on 5/31/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

private let recordTimeLimit = 10

class PicAddAudioTagView: UIView {
    var cancelRecorderHandler: (() -> Void)?
    var saveRecorderHandler: ((String, String) -> Void)?
    
    private let audioID = NSUUID().UUIDString
    
    private lazy var recordSettings = {
        return [AVSampleRateKey : NSNumber(float: Float(44100.0)),//声音采样率
            AVFormatIDKey : NSNumber(unsignedInt: kAudioFormatMPEG4AAC),//编码格式
            AVNumberOfChannelsKey : NSNumber(int: 2),//采集音轨
            AVEncoderBitRateKey : 64000,
            AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))]//音频质量
    }()
    
    lazy private var cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: kScreenWidth - 20 - 14, y: 20, width: 14, height: 14))
        button.setBackgroundImage(UIImage(named: "pic_record_cancel"), forState: .Normal)
        
        button.addTarget(self, action: #selector(cancelRecord), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy private var recordButton: UIButton = {
        let button = UIButton()
        button.frame.size = CGSize(width: 94, height: 94)
        button.center = self.bottomView.getCenter()
        button.setImage(UIImage(named: "pic_record_hold"), forState: .Normal)
        button.adjustsImageWhenHighlighted = false
        
        button.addTarget(self, action: #selector(startRecord), forControlEvents: .TouchDown)
        button.addTarget(self, action: #selector(doneRecord), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy  private var timeLabel: UILabel = {
        let label = UILabel()
        label.frame.size = CGSize(width: 60, height: 20)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(15)
        label.textAlignment = .Center
        label.text = "00:\(recordTimeLimit)"
        label.center = CGPoint(x: kScreenWidth / 2, y: 30)
        label.hidden = true
        return label
    }()
    
    lazy private var bottomView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight - kPicRecordViewH, width: kScreenWidth, height: kPicRecordViewH))
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return view
    }()
    
    private var doneView: UIView!
    
    private var recordTimer: NSTimer!
    private var playTimer: NSTimer!
    
    private var recorder: AVAudioRecorder!
    private var player: AVAudioPlayer!
    private var timeOut = false
    
    private var duration = recordTimeLimit
    private var playTime: NSTimeInterval = 0
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        
        let topV: UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kPicThumbH))
            view.backgroundColor = UIColor(white: 0, alpha: 0.1)
            return view
        }()
        
        addSubview(topV)
        addSubview(bottomView)
        
        bottomView.addSubview(cancelButton)
        bottomView.addSubview(recordButton)
        bottomView.addSubview(timeLabel)
    }
    
    func showDoneView() {
        if doneView == nil {
            doneView = UIView(frame: CGRect(x: 0, y: kPicRecordViewH - 44, width: kScreenWidth, height: 44))
            
            let reRecordButton = UIButton(frame: CGRect(x: 0, y: 0, width: kScreenWidth / 2, height: 44))
            reRecordButton.titleLabel?.font = UIFont.systemFontOfSize(16)
            reRecordButton.titleLabel?.textColor = UIColor.whiteColor()
            reRecordButton.titleLabel?.textAlignment = .Center
            reRecordButton.addTarget(self, action: #selector(reRecord), forControlEvents: .TouchUpInside)
            reRecordButton.setTitle("重录", forState: .Normal)
            doneView.addSubview(reRecordButton)
            
            let doneButton = UIButton(frame: CGRect(x: kScreenWidth / 2, y: 0, width: kScreenWidth / 2, height: 44))
            doneButton.titleLabel?.font = UIFont.systemFontOfSize(16)
            doneButton.titleLabel?.textColor = UIColor.whiteColor()
            doneButton.titleLabel?.textAlignment = .Center
            doneButton.addTarget(self, action: #selector(saveRecord), forControlEvents: .TouchUpInside)
            doneButton.setTitle("添加", forState: .Normal)
            doneView.addSubview(doneButton)
            
            let lineH = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 0.5))
            lineH.image = UIImage(named: "pic_recoder_line")
            doneView.addSubview(lineH)
            
            let lineV = UIImageView(frame: CGRect(x: kScreenWidth / 2 , y: 0.5, width: 0.5, height: 44))
            lineV.image = UIImage(named: "pic_recoder_line")
            doneView.addSubview(lineV)
            
            bottomView.addSubview(doneView)
        }
        
        doneView.hidden = false
    }
    
    func saveRecord() {
        if player != nil {
            player.stop()
        }
        saveRecorderHandler?(audioID, "\(recordTimeLimit - duration)")
    }
    
    func cancelRecord() {
        if player != nil {
            player.stop()
        }
        
        cancelRecorderHandler?()
    }
    
    func reRecord() {
        if player.playing {
            player.stop()
        }
        
        APP_UTILITY.removeAudioFile(audioID)
        
        if playTimer != nil {
            playTimer.invalidate()
            playTimer = nil
        }
        
        if doneView != nil {
            doneView.hidden = true
        }
        
        timeLabel.hidden = true
        timeLabel.text = "00:\(recordTimeLimit)"
        duration = recordTimeLimit
        
        recordButton.setImage(UIImage(named: "pic_record_hold"), forState: .Normal)
        recordButton.removeTarget(nil, action: nil, forControlEvents: .AllTouchEvents)
        recordButton.addTarget(self, action: #selector(startRecord), forControlEvents: .TouchDown)
        recordButton.addTarget(self, action: #selector(doneRecord), forControlEvents: .TouchUpInside)
    }
    
    func startRecord() {
        recordButton.setImage(UIImage(named: "pic_recording"), forState: .Normal)
        timeLabel.hidden = false
        
        recordTimer = NSTimer(timeInterval: 1, target: self, selector: #selector(recordTimerAction), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(recordTimer, forMode: NSRunLoopCommonModes)
        
        do {
            let audioURL = APP_UTILITY.getAudioFilePath(audioID)!
            try recorder = AVAudioRecorder(URL: audioURL, settings: recordSettings)
            recorder.prepareToRecord()
            
            try AVAudioSession.sharedInstance().setActive(true)
            recorder.record()
        } catch {
            println(" Init Recorder error: \(error)")
        }

        duration = recordTimeLimit
    }
    
    func doneRecord() {
        recordTimer.invalidate()
        recordTimer = nil
        recorder.stop()
        
        if recordTimeLimit - duration < 1 {
            
            duration = recordTimeLimit
            recordButton.setImage(UIImage(named: "pic_record_hold"), forState: .Normal)
            SpiderAlert.alert(type: .ShortRecord, inView: bottomView)
            
        } else {
            
            do {
                let audioURL = APP_UTILITY.getAudioFilePath(audioID)!
                try player = AVAudioPlayer(contentsOfURL: audioURL, fileTypeHint: AVFileTypeAppleM4A)
                player.delegate = self
            } catch {
                println("play tag error: \(error)")
            }
            
            showDoneView()
            
            recordButton.setImage(UIImage(named: "pic_record_play"), forState: .Normal)
            recordButton.removeTarget(nil, action: nil, forControlEvents: .AllTouchEvents)
            recordButton.addTarget(self, action: #selector(play), forControlEvents: .TouchUpInside)
        }
    }
    
    func play() {
        
        if timeOut {
            timeOut = false
        } else {
            if player.playing {
                
                player.pause()
                playTimer.invalidate()
                playTimer = nil
                
                recordButton.setImage(UIImage(named: "pic_record_play"), forState: .Normal)
                
            } else {
                
                playTimer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(playTimerAction), userInfo: nil, repeats: true)
                NSRunLoop.mainRunLoop().addTimer(playTimer, forMode: NSRunLoopCommonModes)
                
                recordButton.setImage(UIImage(named: "pic_record_pause"), forState: .Normal)
                player.play()
            }
        }
    }
    
    func recordTimerAction() {
        duration -= 1
        timeLabel.text = "00:\(duration)"
        
        if duration == 0 {
            SpiderAlert.alert(type: .RecordTimeOut, inView: bottomView)
            doneRecord()
            timeOut = true
        }
    }
    
    func playTimerAction() {
        timeLabel.text = player.currentTime.toMinSec()
    }
    
    override func removeFromSuperview() {
        if playTimer != nil {
            playTimer.invalidate()
            playTimer = nil
        }
        
        if player != nil {
            player.delegate = nil
        }
        
        super.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PicAddAudioTagView: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.setImage(UIImage(named: "pic_record_play"), forState: .Normal)
    }
}
