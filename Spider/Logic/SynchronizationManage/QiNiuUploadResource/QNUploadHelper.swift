//
//  QiniuUploadHelper.swift
//  Spider
//
//  Created by 童星 on 16/8/19.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit
let QNUPLOADHELPER = QNUploadHelper.getInstance()

class QNUploadHelper: NSObject {

    var successBlock: (_ str: String) -> Void = {
    
        (str: String) -> Void in
    }
    
    var failureBlock: () -> Void = {
    
        () -> Void in
    }
    
    static var instance:QNUploadHelper?
    class func getInstance() ->QNUploadHelper {
        if (instance == nil) {
            instance = QNUploadHelper()
        }
        return instance!
    }
    
}
