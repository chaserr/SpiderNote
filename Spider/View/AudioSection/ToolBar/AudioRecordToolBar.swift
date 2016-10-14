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
private let textFont = UIFont.systemFontOfSize(13)

public enum AudioToolBarType {
    case Record
    case Play
}

class AudioRecordToolBar: UIView {
    
    var quitHandler: (() -> Void)?
    var doneHandler: (String -> Void)?
    var markPicHandler: (String -> Void)?
    var markTextHandler: (String -> Void)?
    var reRecordHandler: (() -> Void)?
    
    private var type: AudioToolBarType! = .Record
    
    private var hasRecorded = false
    
    private var isCurrent = false
    private var beInterrupted = false
    
    var audioID: String?
    
    private var player: AVAudioPlayer!
    private var recorder: AVAudioRecorder!
    private var totalTime: NSTimeInterval!
    private var playedTime: NSTimeInterval?
    
    private var displayLink: CADisplayLink?
    
    private var viewController: UIViewController!
    
    private var recordButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "audio_record"), forState: .Normal)
        return button
    }()
    
    private var markButton: UIButton = {
        let button = UIButton()
        button.setTitle("标记", forState: .Normal)
        button.setTitleColor(textColor, forState: .Normal)
        button.setTitleColor(disabledColor, forState: .Disabled)
        button.titleLabel?.font = textFont
        button.enabled = false
        return button
    }()
    
    private var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("完成", forState: .Normal)
        button.setTitleColor(textColor, forState: .Normal)
        button.setTitleColor(disabledColor, forState: .Disabled)
        button.titleLabel?.font = textFont
        return button
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = textColor
        label.textAlignment = .Center
        label.font = textFont
        return label
    }()
    
    private var quitButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "audio_quit"), forState: .Normal)
        return button
    }()
    
    private lazy var markContainter: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "audio_mark")
        imageView.hidden = true
        imageView.userInteractionEnabled = true
        return imageView
    }()
    
    private lazy var markTextButton: UIButton = {
        let button = UIButton()
        button.setTitle("文字", forState: .Normal)
        button.setTitleColor(UIColor.color(withHex: 0xd5d5d5), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(13)
        return button
    }()
    
    private lazy var markPicButton: UIButton = {
        let button = UIButton()
        button.setTitle("图片", forState: .Normal)
        button.setTitleColor(UIColor.color(withHex: 0xd5d5d5), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(13)
        return button
    }()
    
    private var playButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "audio_play"), forState: .Normal)
        return button
    }()
    
    private lazy var playSlider: AudioSlider = {
        return AudioSlider()
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = textColor
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(10)
        return label
    }()
    
    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = textColor
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(10)
        return label
    }()
    
    private lazy var recordSettings = {
        return [AVSampleRateKey : NSNumber(float: Float(44100.0)),//声音采样率
            AVFormatIDKey : NSNumber(unsignedInt: kAudioFormatMPEG4AAC),//编码格式
            AVNumberOfChannelsKey : NSNumber(int: 2),//采集音轨
            AVEncoderBitRateKey : 64000,
            AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))]//音频质量
    }()
    
    init(audioURL: NSURL? = nil, inController controller: UIViewController, playedTime: NSTimeInterval? = nil) {
        super.init(frame: CGRect(x: 0, y: kScreenHeight-kAudioToolBarHeight, width: kScreenWidth, height: kAudioToolBarHeight))
        backgroundColor = UIColor.color(withHex: 0x4b4b4b)
        
        viewController = controller
        
        if let url = audioURL {
            
            type = .Play
            doneButton.setTitle("返回", forState: .Normal)
            markButton.enabled = true
            
            
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
                
                type = .Play
                
                self.player = player
                totalTime = player.duration
                
                doneButton.setTitle("返回", forState: .Normal)
                totalTimeLabel.text = totalTime.toMinSec()
                currentTimeLabel.text = startTime.toMinSec()
                playSlider.value = Float(player.currentTime / totalTime)
                markButton.enabled = true

                makeUI()
                addActions()
                
                if player.playing {
                    playButton.setBackgroundImage(UIImage(named: "audio_pause"), forState: .Normal)
                    displayLink?.paused = false
                }
                
            } else {
                
                // record
                makeUI()
                addActions()
            }
        }
        
        if type == .Play {
            SpiderPlayer.sharedManager.addObserver(self, forKeyPath: "changed", options: .Old, context: &myContext)
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        displayLink?.invalidate()
        
        if type == .Play {
            SpiderPlayer.sharedManager.removeObserver(self, forKeyPath: "changed")
        }
        
        if player != nil {
            player.stop()
        }
        
        if isCurrent {
            SpiderPlayer.sharedManager.changed = true
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            if let key = keyPath where key == "changed" {
                dispatch_async(dispatch_get_main_queue(), {
                    self.playButton.setBackgroundImage(UIImage(named: "audio_play"), forState: .Normal)
                    self.displayLink?.paused = true
                })
            }
        }
    }
    
    // MARK: -  Actions
    
    func addActions() {
        
        if type == .Record {
            
            doneButton.enabled = false
            quitButton.addTarget(self, action: #selector(quitButtonClicked), forControlEvents: .TouchUpInside)
            recordButton.addTarget(self, action: #selector(recordButtonClicked), forControlEvents: .TouchUpInside)
            
        } else {
            
            playButton.addTarget(self, action: #selector(playButtonClicked), forControlEvents: .TouchUpInside)
            playSlider.addTarget(self, action: #selector(playSliderMoved), forControlEvents: .ValueChanged)
            player.delegate = self
        }
        
        doneButton.addTarget(self, action: #selector(doneButtonCliked), forControlEvents: .TouchUpInside)
        markButton.addTarget(self, action: #selector(markButtonClicked), forControlEvents: .TouchUpInside)
        markTextButton.addTarget(self, action: #selector(markTextButtonClicked), forControlEvents: .TouchUpInside)
        markPicButton.addTarget(self, action: #selector(markPicButtonClicked), forControlEvents: .TouchUpInside)
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateTimeLabel))
        displayLink?.frameInterval = 6 // 10次每秒
        displayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        displayLink?.paused = true
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
        
        type = .Play
        
        if let spiderPlayer = SpiderPlayer.sharedManager.prepareToPlay(recorder.url) {
            player = spiderPlayer
            player.delegate = self
            
            SpiderPlayer.sharedManager.addObserver(self, forKeyPath: "changed", options: .Old, context: &myContext)
            
            totalTime = player.duration
            totalTimeLabel.text = totalTime.toMinSec()
            
            doneHandler?(totalTime.toMinSec())
            changeUIToPlayType()
            playSlider.addTarget(self, action: #selector(playSliderMoved), forControlEvents: .ValueChanged)
            playButton.addTarget(self, action: #selector(playButtonClicked), forControlEvents: .TouchUpInside)
            
            displayLink?.paused = false
            
        } else {
            println("audio record tool bar error")
        }
    }
    
    func doneButtonCliked() {
        if type == .Record {
            
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
        markContainter.hidden = !markContainter.hidden
    }
    
    func markPicButtonClicked() {
        
        markContainter.hidden = true
        
        if type == .Record {
            markPicHandler?(timeLabel.text!)
        } else {
            markPicHandler?(player.currentTime.toMinSec())
        }
    }
    
    func markTextButtonClicked() {
        
        markContainter.hidden = true
        
        if type == .Record {
            markTextHandler?(timeLabel.text!)
        } else {
            markTextHandler?(player.currentTime.toMinSec())
        }
    }
    
    func initRecorder(id: String) {
        guard let url = APP_UTILITY.getAudioFilePath(id) else { return }
        
        if recorder != nil {
            recorder.deleteRecording()
        }
        
        do {
            try recorder = AVAudioRecorder(URL: url, settings: recordSettings)
            recorder.delegate = self
            try AVAudioSession.sharedInstance().setActive(true)
            
            if recorder.prepareToRecord() {
                recorder.record()
                
                recordButton.setBackgroundImage(UIImage(named: "audio_pause"), forState: .Normal)
                
                hasRecorded = true
                
                markButton.enabled = true
                doneButton.enabled = false
                
                displayLink?.paused = false
            }
        } catch {
            println("Audio Section Recorder Init Failed......")
        }
    }
    
    func recordButtonClicked() {
        
        if !hasRecorded {
            audioID = NSUUID().UUIDString
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
                recorder.recording ? pauseRecord() : startRecord()
            }
        }
    }
    
    private func pauseRecord() {
        recorder.pause()
        recordButton.setBackgroundImage(UIImage(named: "audio_record"), forState: .Normal)
        doneButton.enabled = true
        displayLink?.paused = true
    }
    
    private func startRecord() {
        recorder.record()
        recordButton.setBackgroundImage(UIImage(named: "audio_pause"), forState: .Normal)
        doneButton.enabled = false
        displayLink?.paused = false
    }
    
    func playButtonClicked() {
        
        if player.playing {
            
            playButton.setBackgroundImage(UIImage(named: "audio_play"), forState: .Normal)
            player.pause()
            displayLink?.paused = true
            
        } else {
            
            playButton.setBackgroundImage(UIImage(named: "audio_pause"), forState: .Normal)
            player.play()
            displayLink?.paused = false
        }
    }
    
    func playSliderMoved(sender: UISlider) {
        player.currentTime = NSTimeInterval(Float(totalTime) * (sender.value))
        currentTimeLabel.text = player.currentTime.toMinSec()
    }
    
    func updateTimeLabel() {
        if type == .Record {
            timeLabel.text = recorder.currentTime.toMinSec()
        } else {
            currentTimeLabel.text = player.currentTime.toMinSec()
            playSlider.value = Float(player.currentTime / totalTime)
        }
    }
    
    func playAt(time: NSTimeInterval) {
        if !player.playing {
            player.play()
        }
        player.currentTime = time

        displayLink?.paused = false
        playButton.setBackgroundImage(UIImage(named: "audio_pause"), forState: .Normal)
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
        
        if type == .Record {
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
            bringSubviewToFront(markContainter)
            
            currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
            totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
            playButton.translatesAutoresizingMaskIntoConstraints = false
            
            currentTimeLabel.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(15)
                make.centerY.equalTo(playSlider)
            })
            
            totalTimeLabel.snp_makeConstraints(closure: { (make) in
                make.right.equalTo(-15)
                make.centerY.equalTo(playSlider)
            })
            
            playButton.snp_makeConstraints(closure: { (make) in
                make.width.height.equalTo(40)
                make.top.equalTo(playSlider.snp_bottom).offset(14)
                make.centerX.equalTo(self)
            })
            
            markButton.snp_makeConstraints(closure: { (make) in
                make.width.height.equalTo(40)
                make.left.equalTo(86)
                make.centerY.equalTo(playButton)
            })
            
            doneButton.snp_makeConstraints(closure: { (make) in
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
        bringSubviewToFront(markContainter)
        
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        doneButton.setTitle("返回", forState: .Normal)
        
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
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setBackgroundImage(UIImage(named: "audio_play"), forState: .Normal)
    }
}

extension AudioRecordToolBar: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {

    }
    
    func audioRecorderBeginInterruption(recorder: AVAudioRecorder) {
        println(" Recoder begin interruption")
        
        beInterrupted = true
        recorder.stop()
        recordButton.setBackgroundImage(UIImage(named: "audio_record"), forState: .Normal)
        doneButton.enabled = true
        displayLink?.paused = true
    }
    
    func audioRecorderEndInterruption(recorder: AVAudioRecorder, withOptions flags: Int) {

    }
}
