//
//  Spider+Delay.swift
//  Spider
//
//  Created by ooatuoo on 16/6/13.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation

public typealias CancelableTask = (_ cancel: Bool) -> Void

public func delay(_ time: TimeInterval, work: ()->()) -> CancelableTask? {
    
    var finalTask: CancelableTask?
    
    let cancelableTask: CancelableTask = { cancel in
        if cancel {
            finalTask = nil // key
            
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
    finalTask = cancelableTask
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
        if let task = finalTask {
            task(cancel: false)
        }
    }
    
    return finalTask
}

public func cancel(_ cancelableTask: CancelableTask?) {
    cancelableTask?(cancel: true)
}
