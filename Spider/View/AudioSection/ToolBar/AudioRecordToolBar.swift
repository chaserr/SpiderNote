//
//  AudioRecordToolBar.swift
//  Spider
//
//  Created by ooatuoo on 16/7/8.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import AVFoundation

private var myContext = 0
private let textColor = UIColor.color(withHex: 0xdddddd)
private let disabledColor = UIColor.color(withHex: 0xdddddd, alpha: 0.5)
private let textFont = UIFont.systemFont(ofSize: 13)

public enum AudioToolBarType {
    case record
    case play
}

class AudioRecordToolBar: UIView {
    
    var quitHandler: (() -> Void)?
    var doneHandler: ((String) -> Void)?
    var markPicHandler: ((String) -> Void)?
    var markTextHandler: ((String) -> Void)?
    var reRecordHandler: (() -> Void)?
    
    fileprivate var type: AudioToolBarType! = .record
    
    fileprivate var hasRecorded = false
    
    fileprivate var isCurrent = false
    fileprivate var beInterrupted = false
    
    var audioID: String?
    
    fileprivate var player: AVAudioPlayer!
    fileprivate var recorder: AVAudioRecorder!
    fileprivate var totalTime: TimeInterval!
    fileprivate var playedTime: TimeInterval?
    
    fileprivate var displayLink: CADisplayLink?
    
    fileprivate var viewController: UIViewController!
    
    fileprivate var recordButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "audio_record"), for: UIControlState())
        return button
    }()
    
    fileprivate var markButton: UIButton = {
        let button = UIButton()
        button.setTitle("标记", for: UIControlState())
        button.setTitleColor(textColor, for: UIControlState())
        button.setTitleColor(disabledColor, for: .disabled)
        button.titleLabel?.font = textFont
        button.isEnabled = false
        return button
    }()
    
    fileprivate var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("完成", for: UIControlState())
        button.setTitleColor(textColor, for: UIControlState())
        button.setTitleColor(disabledColor, for: .disabled)
        button.titleLabel?.font = textFont
        return button
    }()
    
    fileprivate var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = textColor
        label.textAlignment = .center
        label.font = textFont
        return label
    }()
    
    fileprivate var quitButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "audio_quit"), for: UIControlState())
        return button
    }()
    
    fileprivate lazy var markContainter: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "audio_mark")
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    fileprivate lazy var markTextButton: UIButton = {
        let button = UIButton()
        button.setTitle("文字", for: UIControlState())
        button.setTitleColor(UIColor.color(withHex: 0xd5d5d5), for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return button
    }()
    
    fileprivate lazy var markPicButton: UIButton = {
        let button = UIButton()
        button.setTitle("图片", for: UIControlState())
        button.setTitleColor(UIColor.color(withHex: 0xd5d5d5), for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return button
    }()
    
    fileprivate var playButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "audio_play"), for: UIControlState())
        return button
    }()
    
    fileprivate lazy var playSlider: AudioSlider = {
        return AudioSlider()
    }()
    
    fileprivate lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = textColor
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    fileprivate lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = textColor
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    fileprivate lazy var recordSettings = {
        return [AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),//声音采样率
            AVFormatIDKey : NSNumber(value: kAudioFormatMPEG4AAC as UInt32),//编码格式
            AVNumberOfChannelsKey : NSNumber(value: 2 as Int32),//采集音轨
            AVEncoderBitRateKey : 64000,
            AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32)]//音频质量
    }()
    
    init(audioURL: URL? = nil, inController controller: UIViewController, playedTime: TimeInterval? = nil) {
        super.init(frame: CGRect(x: 0, y: kScreenHeight-kAudioToolBarHeight, width: kScreenWidth, height: kAudioToolBarHeight))
        backgroundColor = UIColor.color(withHex: 0x4b4b4b)
        
        viewController = controller
        
        if let url = audioURL {
            
            type = .play
            doneButton.setTitle("返回", for: UIControlState())
            markButton.isEnabled = true
            
            
            if let player = SpiderPlayer.sharedManager.prepareToPlay(url) {
                self.player = player
                totalTime = player.duration
                totalTimeLabel.text = totalTime.toMinSec()

                makeUI()
                addActions()
            }

        } else {
            
            if let startTime = playedTime {
                isCurrent = true
                
                guard let player = SpiderPlayer.sharedManager.player else { return }
                
                type = .play
                
                self.player = player
                totalTime = player.duration
                
                doneButton.setTitle("返回", for: UIControlState())
                totalTimeLabel.text = totalTime.toMinSec()
                currentTimeLabel.text = startTime.toMinSec()
                playSlider.value = Float(player.currentTime / totalTime)
                markButton.isEnabled = true

                makeUI()
                addActions()
                
                if player.isPlaying {
                    playButton.setBackgroundImage(UIImage(named: "audio_pause"), for: UIControlState())
                    displayLink?.isPaused = false
                }
                
            } else {
                
                // record
                makeUI()
                addActions()
            }
        }
        
        if type == .play {
            SpiderPlayer.sharedManager.addObserver(self, forKeyPath: "changed", options: .old, context: &myContext)
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        displayLink?.invalidate()
        
        if type == .play {
            SpiderPlayer.sharedManager.removeObserver(self, forKeyPath: "changed")
        }
        
        if player != nil {
            player.stop()
        }
        
        if isCurrent {
            SpiderPlayer.sharedManager.changed = true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            if let key = keyPath, key == "changed" {
                DispatchQueue.main.async(execute: {
                    self.playButton.setBackgroundImage(UIImage(named: "audio_play"), for: UIControlState())
                    self.displayLink?.isPaused = true
                })
            }
        }
    }
    
    // MARK: -  Actions
    
    func addActions() {
        
        if type == .record {
            
            doneButton.isEnabled = false
            quitButton.addTarget(self, action: #selector(quitButtonClicked), for: .touchUpInside)
            recordButton.addTarget(self, action: #selector(recordButtonClicked), for: .touchUpInside)
            
        } else {
            
            playButton.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
            playSlider.addTarget(self, action: #selector(playSliderMoved), for: .valueChanged)
            player.delegate = self
        }
        
        doneButton.addTarget(self, action: #selector(doneButtonCliked), for: .touchUpInside)
        markButton.addTarget(self, action: #selector(markButtonClicked), for: .touchUpInside)
        markTextButton.addTarget(self, action: #selector(markTextButtonClicked), for: .touchUpInside)
        markPicButton.addTarget(self, action: #selector(markPicButtonClicked), for: .touchUpInside)
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateTimeLabel))
        displayLink?.frameInterval = 6 // 10次每秒
        displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        displayLink?.isPaused = true
    }
    
    func quitButtonClicked() {
                
        if hasRecorded {
            SpiderAlert.confirmOrCancel(title: "", message: "你确定要放弃录音么?", confirmTitle: "放弃", cancelTitle: "取消", inViewController: viewController, withConfirmAction: {
                
                do {
                    self.recorder.stop()
                    self.recorder.deleteRecording()
                    try AVAudioSession.sharedInstance().setActive(false)
                } catch {}
                
                self.displayLink?.invalidate()
                self.quitHandler?()
                
            }, cancelAction: { 

            })
            
        } else {
           
            quitHandler?()
        }
    }
    
    func saveRecord() {
        
        type = .play
        
        if let spiderPlayer = SpiderPlayer.sharedManager.prepareToPlay(recorder.url) {
            player = spiderPlayer
            player.delegate = self
            
            SpiderPlayer.sharedManager.addObserver(self, forKeyPath: "changed", options: .old, context: &myContext)
            
            totalTime = player.duration
            totalTimeLabel.text = totalTime.toMinSec()
            
            doneHandler?(totalTime.toMinSec())
            changeUIToPlayType()
            playSlider.addTarget(self, action: #selector(playSliderMoved), for: .valueChanged)
            playButton.addTarget(self, action: #selector(playButtonClicked), for: .touchUpInside)
            
            displayLink?.isPaused = false
            
        } else {
            println("audio record tool bar error")
        }
    }
    
    func doneButtonCliked() {
        if type == .record {
            
            if timeLabel.text!.toTime() >= 2 {
                recorder.stop()
                saveRecord()
                
            } else {
                
                SpiderAlert.alert(type: .ShortRecord, inView: self)
            }
            
        } else {
            
            if !isCurrent {
                player.stop()
            }
            
            displayLink?.invalidate()
            quitHandler?()
        }
    }
    
    func markButtonClicked() {
        markContainter.isHidden = !markContainter.isHidden
    }
    
    func markPicButtonClicked() {
        
        markContainter.isHidden = true
        
        if type == .record {
            markPicHandler?(timeLabel.text!)
        } else {
            markPicHandler?(player.currentTime.toMinSec())
        }
    }
    
    func markTextButtonClicked() {
        
        markContainter.isHidden = true
        
        if type == .record {
            markTextHandler?(timeLabel.text!)
        } else {
            markTextHandler?(player.currentTime.toMinSec())
        }
    }
    
    func initRecorder(_ id: String) {
        guard let url = APP_UTILITY.getAudioFilePath(id) else { return }
        
        if recorder != nil {
            recorder.deleteRecording()
        }
        
        do {
            try recorder = AVAudioRecorder(url: url, settings: recordSettings)
            recorder.delegate = self
            try AVAudioSession.sharedInstance().setActive(true)
            
            if recorder.prepareToRecord() {
                recorder.record()
                
                recordButton.setBackgroundImage(UIImage(named: "audio_pause"), for: UIControlState())
                
                hasRecorded = true
                
                markButton.isEnabled = true
                doneButton.isEnabled = false
                
                displayLink?.isPaused = false
            }
        } catch {
            println("Audio Section Recorder Init Failed......")
        }
    }
    
    func recordButtonClicked() {
        
        if !hasRecorded {
            audioID = UUID().uuidString
            initRecorder(audioID!)
            
        } else {
            
            if beInterrupted {
                beInterrupted = false
                
                SpiderAlert.confirmOrCancel(title: "录音被中断了", message: "是否保存之前的录音，或者重新录制？", confirmTitle: "保存", cancelTitle: "重录", inViewController: viewController, withConfirmAction: {
                    self.saveRecord()
                    
                }, cancelAction: {
                    self.reRecordHandler?()
                    self.initRecorder(self.audioID!)
                })
                
            } else {
                recorder.isRecording ? pauseRecord() : startRecord()
            }
        }
    }
    
    fileprivate func pauseRecord() {
        recorder.pause()
        recordButton.setBackgroundImage(UIImage(named: "audio_record"), for: UIControlState())
        doneButton.isEnabled = true
        displayLink?.isPaused = true
    }
    
    fileprivate func startRecord() {
        recorder.record()
        recordButton.setBackgroundImage(UIImage(named: "audio_pause"), for: UIControlState())
        doneButton.isEnabled = false
        displayLink?.isPaused = false
    }
    
    func playButtonClicked() {
        
        if player.isPlaying {
            
            playButton.setBackgroundImage(UIImage(named: "audio_play"), for: UIControlState())
            player.pause()
            displayLink?.isPaused = true
            
        } else {
            
            playButton.setBackgroundImage(UIImage(named: "audio_pause"), for: UIControlState())
            player.play()
            displayLink?.isPaused = false
        }
    }
    
    func playSliderMoved(_ sender: UISlider) {
        player.currentTime = TimeInterval(Float(totalTime) * (sender.value))
        currentTimeLabel.text = player.currentTime.toMinSec()
    }
    
    func updateTimeLabel() {
        if type == .record {
            timeLabel.text = recorder.currentTime.toMinSec()
        } else {
            currentTimeLabel.text = player.currentTime.toMinSec()
            playSlider.value = Float(player.currentTime / totalTime)
        }
    }
    
    func playAt(_ time: TimeInterval) {
        if !player.isPlaying {
            player.play()
        }
        player.currentTime = time

        displayLink?.isPaused = false
        playButton.setBackgroundImage(UIImage(named: "audio_pause"), for: UIControlState())
    }
    
    
    // MARK: -  Make UI
    
    func makeUI() {
        addSubview(markButton)
        addSubview(doneButton)
        markContainter.addSubview(markTextButton)
        markContainter.addSubview(markPicButton)
        addSubview(markContainter)
        
        markButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        markContainter.translatesAutoresizingMaskIntoConstraints = false
        markTextButton.translatesAutoresizingMaskIntoConstraints = false
        markPicButton.translatesAutoresizingMaskIntoConstraints = false
        
        if type == .record {
            addSubview(timeLabel)
            addSubview(recordButton)
            addSubview(quitButton)
            
            recordButton.translatesAutoresizingMaskIntoConstraints = false
            quitButton.translatesAutoresizingMaskIntoConstraints = false
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            
            recordButton.snp_makeConstraints { (make) in
                make.width.height.equalTo(40)
                make.top.equalTo(20)
                make.centerX.equalTo(self)
            }
            
            quitButton.snp_makeConstraints { (make) in
                make.width.height.equalTo(12)
                make.left.equalTo(15)
                make.bottom.equalTo(-18)
            }
            
            markButton.snp_makeConstraints { (make) in
                make.width.height.equalTo(40)
                make.left.equalTo(86)
                make.centerY.equalTo(quitButton)
            }
            
            timeLabel.snp_makeConstraints { (make) in
                make.centerX.equalTo(self)
                make.centerY.equalTo(quitButton)
            }
            
            doneButton.snp_makeConstraints { (make) in
                make.size.equalTo(markButton)
                make.right.equalTo(-86)
                make.centerY.equalTo(quitButton)
            }
            
        } else {
            
            addSubview(playSlider)
            addSubview(currentTimeLabel)
            addSubview(totalTimeLabel)
            addSubview(playButton)
            bringSubview(toFront: markContainter)
            
            currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
            totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
            playButton.translatesAutoresizingMaskIntoConstraints = false
            
            currentTimeLabel.snp_makeConstraints({ (make) in
                make.left.equalTo(15)
                make.centerY.equalTo(playSlider)
            })
            
            totalTimeLabel.snp_makeConstraints({ (make) in
                make.right.equalTo(-15)
                make.centerY.equalTo(playSlider)
            })
            
            playButton.snp_makeConstraints({ (make) in
                make.width.height.equalTo(40)
                make.top.equalTo(playSlider.snp_bottom).offset(14)
                make.centerX.equalTo(self)
            })
            
            markButton.snp_makeConstraints({ (make) in
                make.width.height.equalTo(40)
                make.left.equalTo(86)
                make.centerY.equalTo(playButton)
            })
            
            doneButton.snp_makeConstraints({ (make) in
                make.width.height.equalTo(40)
                make.right.equalTo(-86)
                make.centerY.equalTo(playButton)
            })
        }
        
        markContainter.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 80, height: 34))
            make.centerX.equalTo(markButton)
            make.bottom.equalTo(markButton.snp_top).offset(8)
        }
        
        markTextButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 38, height: 27))
            make.left.equalTo(1)
            make.top.equalTo(0)
        }
        
        markPicButton.snp_makeConstraints { (make) in
            make.size.equalTo(markTextButton)
            make.top.equalTo(0)
            make.right.equalTo(1)
        }
    }
    
    func changeUIToPlayType() {
        quitButton.removeFromSuperview()
        recordButton.removeFromSuperview()
        timeLabel.removeFromSuperview()
        
        addSubview(playSlider)
        addSubview(currentTimeLabel)
        addSubview(totalTimeLabel)
        addSubview(playButton)
        bringSubview(toFront: markContainter)
        
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        doneButton.setTitle("返回", for: UIControlState())
        
        currentTimeLabel.snp_makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(playSlider)
        }
        
        totalTimeLabel.snp_makeConstraints { (make) in
            make.right.equalTo(-15)
            make.centerY.equalTo(playSlider)
        }
        
        playButton.snp_makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.top.equalTo(playSlider.snp_bottom).offset(14)
            make.centerX.equalTo(self)
        }
        
        markButton.snp_remakeConstraints { (make) in
            make.width.height.equalTo(40)
            make.left.equalTo(86)
            make.centerY.equalTo(playButton)
        }
        
        doneButton.snp_remakeConstraints { (make) in
            make.width.height.equalTo(40)
            make.right.equalTo(-86)
            make.centerY.equalTo(playButton)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AudioRecordToolBar: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setBackgroundImage(UIImage(named: "audio_play"), for: UIControlState())
    }
}

extension AudioRecordToolBar: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {

    }
    
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        println(" Recoder begin interruption")
        
        beInterrupted = true
        recorder.stop()
        recordButton.setBackgroundImage(UIImage(named: "audio_record"), for: UIControlState())
        doneButton.isEnabled = true
        displayLink?.isPaused = true
    }
    
    func audioRecorderEndInterruption(_ recorder: AVAudioRecorder, withOptions flags: Int) {

    }
}
