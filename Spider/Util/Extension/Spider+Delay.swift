//
//  Spider+Delay.swift
//  Spider
//
//  Created by ooatuoo on 16/6/13.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation

public typealias CancelableTask = (cancel: Bool) -> Void

public func delay(time: NSTimeInterval, work: dispatch_block_t) -> CancelableTask? {
    
    var finalTask: CancelableTask?
    
    let cancelableTask: CancelableTask = { cancel in
        if cancel {
            finalTask = nil // key
            
        } else {
            dispatch_async(dispatch_get_main_queue(), work)
        }
    }
    
    finalTask = cancelableTask
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        if let task = finalTask {
            task(cancel: false)
        }
    }
    
    return finalTask
}

public func cancel(cancelableTask: CancelableTask?) {
    cancelableTask?(cancel: true)
}