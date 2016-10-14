//
//  VoiceRecord.swift
//  Spider
//
//  Created by 童星 on 16/7/7.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  录音管理类

import UIKit

class VoiceRecord: NSObject, AVAudioRecorderDelegate {

    var recorder:AVAudioRecorder?   //录音器
    var recorderSettingsDic:[NSObject : AnyObject]?   //录音器设置参数数组
    var volumeTimer:NSTimer!//定时器线程， 刷新音量
    var currentTimeInterval: NSTimeInterval = 0   //当前录音时间
    var recorderPath:String { //录音存储路径
        let path = APP_UTILITY.voiceFilePath()
        let fileName = DateUtil.getCurrentDateStringWithFormat(kDUYYYYMMddhhmmss)
        let pathExtension = "m4a"
        let recorderPath = "\(path)/\(fileName).\(pathExtension)"
        return recorderPath;
    }
    var minRecordTime: Float = 0       //最小录音时长，默认0
    var maxRecordTime: Float {      //最大录音时间，以后让用户设置
        return 60.0
    }
    var recordDuration: String? //录音时长
    
    //MARK: 闭包block方法
    
    //音量信号幅度回调
    typealias PowerForChannel = (lowPassResults: Double) -> Void
    var powerForChannel: PowerForChannel?
    
    
    /**
     便利构造器
     
     - parameter minRecordTime:   最小录制事件
     - parameter powerForChannel: 音量变化回调
     
     - returns:
     */
    convenience init(minRecordTime: Float, powerForChannel: PowerForChannel?) {
        self.init()
        self.minRecordTime = minRecordTime
        self.powerForChannel = powerForChannel
    }
    
    /**
     初始化录音器
     */
    private func setRecorder() {
        
        //初始化录音器
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        //初始化一个NSError对象，失败的时候可以获取失败原因
        
        do {
            //设置录音类型
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print(error)
        }
        
        do {
            //设置支持后台
            try session.setActive(true)
        } catch let error as NSError {
            print(error)
        }
        
        do {
            
            //初始化录音器
            self.recorder = try AVAudioRecorder(URL: NSURL(string: self.recorderPath)!, settings: [
                AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatMPEG4AAC),
                AVSampleRateKey: NSNumber(long: 44100),
                AVNumberOfChannelsKey: NSNumber(long: 1),
                //                AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue
                AVLinearPCMBitDepthKey:NSNumber(long: 16)
                ])
        } catch _ as NSError {
            self.recorder = nil
        }
        
        self.recorder?.delegate = self
        self.recorder?.meteringEnabled = true;
        self.recorder?.recordForDuration(NSTimeInterval(self.maxRecordTime))
        self.recorder?.prepareToRecord()
    }
    
    /**
     开始录音
     */
    func startRecord(completion:() -> Void) {
        self.setRecorder()
        self.recorder!.record()
        self.currentTimeInterval = 0.0
        //启动定时器 定时更新录音音量
        volumeTimer = NSTimer.scheduledTimerWithTimeInterval(0.0, target: self, selector: #selector(VoiceRecord.levelTimer), userInfo: nil, repeats: true)
        
        //完成后回调
        completion()
    }
    
    /**
     停止定时器
     */
    private func stopTimer() {
        if(self.volumeTimer != nil) {
            self.volumeTimer.invalidate()
            self.volumeTimer = nil
        }
        
    }
    
    /**
     暂停录音
     */
    private func stopRecord() {
        self.recorder?.stop()
        self.stopTimer()
    }
    
    /**
     暂停录音
     
     - parameter completion(是否录音成功):
     */
    func stopRecord(completion:(isRecordSuccess: Bool, voiceData: NSData?,voicePath: String, voiceDuration: Float) -> Void) {
        var isRecordSuccess: Bool
        self.stopRecord()
        let currentTime = Float(self.currentTimeInterval)
        let data: NSData?   //录音文件数据
        if currentTime > minRecordTime {    //大于最小时长才录制成功
            isRecordSuccess = true
            data = NSData(contentsOfURL: NSURL(fileURLWithPath: self.recorderPath))
        } else {
            isRecordSuccess = false
            //删除记录
            self.recorder?.deleteRecording()
            data = nil
        }
        self.stopTimer()
        self.currentTimeInterval = 0
        //给上层提示成功或失败消息
        completion(isRecordSuccess: isRecordSuccess, voiceData:data, voicePath: self.recorderPath, voiceDuration: currentTime)
    }
    
    /**
     取消录音
     
     - parameter completion:
     */
    func cancelRecord(completion:() -> Void) {
        self.stopRecord()
        //删除记录
        self.recorder?.deleteRecording()
        self.currentTimeInterval = 0
        completion()
    }
    
    
    /**
     定时器方法--检测录音音量
     */
    func levelTimer() {
        self.recorder!.updateMeters()//刷新音量数据
        self.currentTimeInterval = self.recorder!.currentTime;
        let averageV:Float = self.recorder!.averagePowerForChannel(0)//获取音量的平均值
        let lowPassResults:Double = pow(Double(10), Double(0.015 * averageV))
        
        //回调音量参数给上层
        self.powerForChannel?(lowPassResults: lowPassResults)
        
        //超过最大录制时间就停止录音
        if (Float(self.currentTimeInterval) > self.maxRecordTime) {
            self.stopRecord()
        }
    }
}
