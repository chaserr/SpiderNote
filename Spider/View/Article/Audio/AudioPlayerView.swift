//
//  AudioTmpView.swift
//  Spider
//
//  Created by 童星 on 5/17/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit
import AVFoundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


// Global Variables
private let mainColor = UIColor.color(withHex: 0x3e3e50)
private let bgColor   = UIColor.color(withHex: 0xf0f0f0)
private let wordColor = UIColor.color(withHex: 0xa3a3b9)

private let labelR    = CGFloat(25)
private let buttonS   = CGFloat(66)
private let horOffset = CGFloat(15)
private let pHeight   = CGFloat(40)
private let pOffset   = CGFloat(7)
private let progressH = CGFloat(60)
private let imageS    = CGFloat(15)

private let borderWidth   = CGFloat(10)
private let cursorOffsetH = CGFloat(4)

private let timeInterval = 0.03

private var playImage : UIImage = {
    return UIImage(named: "article_audio_play")!.resize(imageS)
}()

private var pauseImage : UIImage = {
    return UIImage(named: "article_audio_pause")!.resize(imageS)
}()

// MARK: - Audio Player View

class AudioPlayerView: UIView, AVAudioPlayerDelegate {
    
    fileprivate var audioInfo: AudioInfo!
    fileprivate var playedTime: TimeInterval = 0
    fileprivate var timer: Timer?
//    private var 
    
    fileprivate var playButton: AudioPlayButton!
    fileprivate var progressView: AudioProgressView!
    fileprivate var timeLabel: AudioTimeLabel!
    fileprivate var player: AVAudioPlayer!
    fileprivate var cursor: UIImageView!
    
    fileprivate var progressW: CGFloat!
    fileprivate var labelC: CGFloat!
    fileprivate var labelEdegR: CGFloat!
    
    fileprivate var lastProgress = CGFloat(0)
    fileprivate var touchToMove = false
    
//    var pan: UIPanGestureRecognizer!
    
    init(frame: CGRect, duration: String? = nil) {
        super.init(frame: frame)
        let centerY = frame.height / 2
        backgroundColor = UIColor.white
        isUserInteractionEnabled = true
        
        // progress view
        
        progressW = frame.width-2*horOffset-buttonS+pOffset
        labelC = progressW - labelR
        labelEdegR = labelC - sqrt(labelR * labelR - pHeight * pHeight / 4)
        
        let progressRect = CGRect(x: horOffset+buttonS-pOffset, y: centerY-progressH/2, width: progressW, height: progressH)
        progressView = AudioProgressView(frame: progressRect)
        addSubview(progressView)
        
        // play button
        playButton = AudioPlayButton(frame: CGRect(x: horOffset, y: centerY - buttonS / 2, width: buttonS, height: buttonS))
        playButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        addSubview(playButton)
        
        // cursor
        cursor = UIImageView(image: UIImage(named: "article_audio_cursor"))
        cursor.frame.size = CGSize(width: 3, height: pHeight + cursorOffsetH)
        cursor.isHidden = true
        addSubview(cursor)
        
        timeLabel = AudioTimeLabel(center: CGPoint(x: progressView.frame.width - labelR, y: progressH / 2))
        progressView.addSubview(timeLabel)
        
        timeLabel.text = duration
//        pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
//        pan.enabled = false
//        addGestureRecognizer(pan)
    }
    
    func prepareToPaly(_ audioInfo: AudioInfo, playedTime: TimeInterval = 0) {
        
        self.audioInfo = audioInfo
        self.playedTime = playedTime
        
        timeLabel.text = audioInfo.duration
        progressView.progress = progressW * CGFloat(playedTime / audioInfo.duration.toTime())
        
        playButton.setImage(playImage, for: UIControlState())
        timer?.invalidate()
        timer = nil
        
        if let player = SpiderPlayer.sharedManager.player {
            
            if SpiderPlayer.sharedManager.playingID == audioInfo.ownerID {
                
                if player.isPlaying { // 为当前播放的音频
                    
                    playButton.setImage(pauseImage, for: UIControlState())
                    timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
                    RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
            
                }
            }
        }
    }
    
    override func removeFromSuperview() {
//        print("audio player view remove from supeview")
    }
    
    func buttonClicked() {
        
        if let player = SpiderPlayer.sharedManager.player {
            
            if player.isPlaying {
                
                if SpiderPlayer.sharedManager.playingID == audioInfo.ownerID {
                    
                    player.pause()
                    timer?.invalidate()

                    playedTime = player.currentTime
                    playButton.setImage(playImage, for: UIControlState())
                    
                } else {
                    
                    SpiderPlayer.sharedManager.prepareToPlay(audioInfo)
                    SpiderPlayer.sharedManager.changed = true
                    SpiderPlayer.sharedManager.play(at: playedTime)
                    
                    startTimer()
                }
                
            } else {
                
                if SpiderPlayer.sharedManager.playingID == audioInfo.ownerID {
                    
                    player.play()
                    playButton.setImage(pauseImage, for: UIControlState())
                    
                } else {
                    
                    SpiderPlayer.sharedManager.prepareToPlay(audioInfo)
                    SpiderPlayer.sharedManager.changed = true
                    SpiderPlayer.sharedManager.play(at: playedTime)
                    
                    playButton.setImage(pauseImage, for: UIControlState())
                }
                
                startTimer()
            }
            
        } else {
            
            SpiderPlayer.sharedManager.prepareToPlay(audioInfo)
            SpiderPlayer.sharedManager.play(at: playedTime)
            
            playButton.setImage(pauseImage, for: UIControlState())
            startTimer()
        }
    }
    
    func timerAction() {
        if let player = SpiderPlayer.sharedManager.player {
            progressView.progress = CGFloat(player.currentTime / audioInfo.duration.toTime()) * progressW
        }
    }
    
    func startTimer() {
        timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    // audio info
    func play() {

    }
    
    func pause() {
        playButton.setImage(playImage, for: UIControlState())
        //        gobalPlayer?.pause()
        player.pause()
//        
//        timer.invalidate()
//        timer = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(playImage, for: UIControlState())
        progressView.progress = progressW
//        timer.invalidate()
//        timer = nil
    }
    
    // MARK: - Gesture Touch
//    func didPan(sender: UIPanGestureRecognizer) {
//        let cLocation = sender.locationInView(self)
//        let pLocation = sender.locationInView(progressView)
//        
//        switch sender.state {
//            
//        case .Began:
//            if progressView.frame.contains(cLocation) {
//                touchToMove = true
//                play()
//            }
//            
//        case .Changed:
//            if cLocation.x >= progressView.getOriginX() && cLocation.x <= progressView.getEndX() && touchToMove {
//                
//                play()
//                cursor.hidden = false
//                if fabs(pLocation.x - lastProgress) >= CGFloat(player.duration * 0.1) {
//                    lastProgress = progressView.progress
//                    progressView.progress = pLocation.x
//                    player.currentTime = NSTimeInterval(progressView.progress / progressW) * player.duration
//                    cursor.frame.size.height = getCursorHeight(pLocation)
//                    cursor.center = CGPoint(x: cLocation.x, y: frame.height / 2)
//                }
//            }
//            
//        default:
//            touchToMove = false
//            cursor.hidden = true
//        }
//    }
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        (superview?.superview?.superview?.superview as! UITableView).scrollEnabled = false
//
//        super.touchesBegan(touches, withEvent: event)
//        let touch = touches.first!
//        
//        let cLocation = touch.locationInView(self)
//        let pLocation = touch.locationInView(progressView)
//        
//        if progressView.frame.contains(cLocation) {
//            
//            play()
//            cursor.hidden = false
//            cursor.frame.size.height = getCursorHeight(pLocation)
//            cursor.center = CGPoint(x: cLocation.x, y: frame.height / 2)
//            lastProgress = progressView.progress
//            progressView.progress = pLocation.x
//            
//            player.currentTime = NSTimeInterval(progressView.progress / progressW) * player.duration
//        }
//    }
//    
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        
//        let touch = touches.first!
//        let cLocation = touch.locationInView(self)
//        let pLocation = touch.locationInView(progressView)
//
//        if cLocation.x >= progressView.getOriginX() && cLocation.x <= progressView.getEndX() {
//            play()
//            cursor.hidden = false
//            
//            if fabs(pLocation.x - lastProgress) >= CGFloat(player.duration * 0.1) {
//                
//                lastProgress = progressView.progress
//                progressView.progress = pLocation.x
//                player.currentTime = NSTimeInterval(progressView.progress / progressW) * player.duration
//                cursor.frame.size.height = getCursorHeight(pLocation)
//                cursor.center = CGPoint(x: cLocation.x, y: frame.height / 2)
//            }
//        }
//    }
//    
//    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
//        (superview?.superview?.superview?.superview as! UITableView).scrollEnabled = true
//    }
//    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        cursor.hidden = true
//        (superview?.superview?.superview?.superview as! UITableView).scrollEnabled = true
//    }
    
    func getCursorHeight(_ location: CGPoint) -> CGFloat {
        if location.x <= labelEdegR {
            return pHeight + cursorOffsetH
        } else {
            let offsetX = fabs(location.x - labelC)
            return sqrt(labelR * labelR - offsetX * offsetX) * 2 + cursorOffsetH
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Audio Progress View
private class AudioProgressView: UIView {
    var progress = CGFloat(0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = bgColor
        setMaskLayer()
    }
    
    func setMaskLayer() {
        let offset = (frame.height - pHeight) / 2
        
        let rW = frame.width - labelR - sqrt(labelR * labelR - pHeight * pHeight / 4)
        let rC = CGPoint(x: frame.width - labelR, y: frame.height / 2)
        
        let p1 = CGPoint(x: 0, y: offset)
        let rS = CGPoint(x: rW, y: offset)
        let p2 = CGPoint(x: 0, y: frame.height - offset)
        
        let angle = CGFloat(M_PI) - asin(pHeight / 2 / labelR)
        
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: rS)
        path.addArc(withCenter: rC, radius: labelR, startAngle: -angle, endAngle: angle, clockwise: true)
        path.addLine(to: p2)
        path.addLine(to: p1)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let rect = CGRect(x: 0, y: 0, width: progress, height: frame.height)
        let path = UIBezierPath(rect: rect)
        mainColor.setFill()
        path.fill()
    }
}

// MARK: - Audio Play Button
private class AudioPlayButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = frame.width / 2
        layer.borderWidth = borderWidth
        layer.borderColor = mainColor.cgColor
        layer.masksToBounds = true
        
        setImage(playImage, for: UIControlState())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Audio Time Label
private class AudioTimeLabel: UILabel {
    init(center: CGPoint) {
        super.init(frame: CGRect(x: 0, y: 0, width: 30, height: 13))
        font = UIFont.systemFont(ofSize: 10)
        textColor = wordColor
        textAlignment = .center
        
        adjustsFontSizeToFitWidth = true
        self.center = center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
