//
//  NotifyManager.swift
//  Spider
//
//  Created by 童星 on 16/9/6.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit
let loopTime: NSTimeInterval = 60    //客户端在后台轮询时间，单位秒,
let bgLoopTime: NSTimeInterval = 60   //客户端在前台轮询时间，单位秒

class NotifyManager: NSObject {

    var timer: NSTimer?
    
    
    
    
    static var instance:NotifyManager?
    class func getInstance() ->NotifyManager {
        if (instance == nil) {
            instance = NotifyManager()
        }
        return instance!
    }
    
    
    func start() -> Void {
        
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(bgLoopTime, target: self, selector: #selector(timerFire), userInfo: nil, repeats: true)
        }
    }
    
    func stop() -> Void {
        
        timer?.invalidate()
        timer = nil
    }
    
    func timerFire(timer: NSTimer) -> Void {
        
        
    }
    
}
