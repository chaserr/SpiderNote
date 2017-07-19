//
//  SpiderLog.swift
//  Spider
//
//  Created by ooatuoo on 16/6/12.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import Foundation

func AODlog<T>(_ message:T , fileName:String = #file ,methodName:String = #function, lineNumber:Int = #line) -> Void {
    #if DEBUG
        
        print("\((fileName as NSString).lastPathComponent)_\(methodName)[\(lineNumber)]:\(message)")
        
    #endif
    
}
