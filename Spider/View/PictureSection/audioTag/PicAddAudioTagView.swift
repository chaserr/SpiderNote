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
    
    fileprivate let audioID = UUID().uuidString
    
    fileprivate lazy var recordSettings = {
        return [AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),//声音采样率
            AVFormatIDKey : NSNumber(value: kAudioFormatMPEG4AAC as UInt32),//编码格式
            AVNumberOfChannelsKey : NSNumber(value: 2 as Int32),//采集音轨
            AVEncoderBitRateKey : 64000,
            AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32)]//音频质量
    }()
    
    lazy fileprivate var cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: kScreenWidth - 20 - 14, y: 20, width: 14, height: 14))
        button.setBackgroundImage(UIImage(named: "pic_record_cancel"), for: UIControlState())
        
        button.addTarget(self, action: #selector(cancelRecord), for: .touchUpInside)
        return button
    }()
    
    lazy fileprivate var recordButton: UIButton = {
        let button = UIButton()
        button.frame.size = CGSize(width: 94, height: 94)
        button.center = self.bottomView.getCenter()
        button.setImage(UIImage(named: "pic_record_hold"), for: UIControlState())
        button.adjustsImageWhenHighlighted = false
        
        button.addTarget(self, action: #selector(startRecord), for: .touchDown)
        button.addTarget(self, action: #selector(doneRecord), for: .touchUpInside)
        return button
    }()
    
    lazy  fileprivate var timeLabel: UILabel = {
        let label = UILabel()
        label.frame.size = CGSize(width: 60, height: 20)
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.text = "00:\(recordTimeLimit)"
        label.center = CGPoint(x: kScreenWidth / 2, y: 30)
        label.isHidden = true
        return label
    }()
    
    lazy fileprivate var bottomView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight - kPicRecordViewH, width: kScreenWidth, height: kPicRecordViewH))
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return view
    }()
    
    fileprivate var doneView: UIView!
    
    fileprivate var recordTimer: Timer!
    fileprivate var playTimer: Timer!
    
    fileprivate var recorder: AVAudioRecorder!
    fileprivate var player: AVAudioPlayer!
    fileprivate var timeOut = false
    
    fileprivate var duration = recordTimeLimit
    fileprivate var playTime: TimeInterval = 0
    
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
            reRecordButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            reRecordButton.titleLabel?.textColor = UIColor.white
            reRecordButton.titleLabel?.textAlignment = .center
            reRecordButton.addTarget(self, action: #selector(reRecord), for: .touchUpInside)
            reRecordButton.setTitle("重录", for: UIControlState())
            doneView.addSubview(reRecordButton)
            
            let doneButton = UIButton(frame: CGRect(x: kScreenWidth / 2, y: 0, width: kScreenWidth / 2, height: 44))
            doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            doneButton.titleLabel?.textColor = UIColor.white
            doneButton.titleLabel?.textAlignment = .center
            doneButton.addTarget(self, action: #selector(saveRecord), for: .touchUpInside)
            doneButton.setTitle("添加", for: UIControlState())
            doneView.addSubview(doneButton)
            
            let lineH = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 0.5))
            lineH.image = UIImage(named: "pic_recoder_line")
            doneView.addSubview(lineH)
            
            let lineV = UIImageView(frame: CGRect(x: kScreenWidth / 2 , y: 0.5, width: 0.5, height: 44))
            lineV.image = UIImage(named: "pic_recoder_line")
            doneView.addSubview(lineV)
            
            bottomView.addSubview(doneView)
        }
        
        doneView.isHidden = false
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
        if player.isPlaying {
            player.stop()
        }
        
        APP_UTILITY.removeAudioFile(audioID)
        
        if playTimer != nil {
            playTimer.invalidate()
            playTimer = nil
        }
        
        if doneView != nil {
            doneView.isHidden = true
        }
        
        timeLabel.isHidden = true
        timeLabel.text = "00:\(recordTimeLimit)"
        duration = recordTimeLimit
        
        recordButton.setImage(UIImage(named: "pic_record_hold"), for: UIControlState())
        recordButton.removeTarget(nil, action: nil, for: .allTouchEvents)
        recordButton.addTarget(self, action: #selector(startRecord), for: .touchDown)
        recordButton.addTarget(self, action: #selector(doneRecord), for: .touchUpInside)
    }
    
    func startRecord() {
        recordButton.setImage(UIImage(named: "pic_recording"), for: UIControlState())
        timeLabel.isHidden = false
        
        recordTimer = Timer(timeInterval: 1, target: self, selector: #selector(recordTimerAction), userInfo: nil, repeats: true)
        RunLoop.main.add(recordTimer, forMode: RunLoopMode.commonModes)
        
        do {
            let audioURL = APP_UTILITY.getAudioFilePath(audioID)!
            try recorder = AVAudioRecorder(url: audioURL, settings: recordSettings)
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
            recordButton.setImage(UIImage(named: "pic_record_hold"), for: UIControlState())
            SpiderAlert.alert(type: .ShortRecord, inView: bottomView)
            
        } else {
            
            do {
                let audioURL = APP_UTILITY.getAudioFilePath(audioID)!
                try player = AVAudioPlayer(contentsOf: audioURL, fileTypeHint: AVFileTypeAppleM4A)
                player.delegate = self
            } catch {
                println("play tag error: \(error)")
            }
            
            showDoneView()
            
            recordButton.setImage(UIImage(named: "pic_record_play"), for: UIControlState())
            recordButton.removeTarget(nil, action: nil, for: .allTouchEvents)
            recordButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        }
    }
    
    func play() {
        
        if timeOut {
            timeOut = false
        } else {
            if player.isPlaying {
                
                player.pause()
                playTimer.invalidate()
                playTimer = nil
                
                recordButton.setImage(UIImage(named: "pic_record_play"), for: UIControlState())
                
            } else {
                
                playTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(playTimerAction), userInfo: nil, repeats: true)
                RunLoop.main.add(playTimer, forMode: RunLoopMode.commonModes)
                
                recordButton.setImage(UIImage(named: "pic_record_pause"), for: UIControlState())
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
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.setImage(UIImage(named: "pic_record_play"), for: UIControlState())
    }
}
