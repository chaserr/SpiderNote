//
//  LocalPushManager.swift
//  Spider
//
//  Created by 童星 on 16/8/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class LocalPushManager: NSObject {

    var loginMsg:Array? = [AnyObject]()
    var loginTime:Array? = [AnyObject]()
    var registerMsg:Array? = [AnyObject]()
    var registerTime:Array? = [AnyObject]()
    
    override init() {
        super.init()
        loginMsg = nil
        loginTime = nil
        registerMsg = nil
        registerTime = nil
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        // 因为这个检测不了Int型的属性，所以还是要手动添加归档
        decodeAutoWithAutoCoder(aDecoder)
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        encodeAutoWithCoder(aCoder)
    }
    
    
}
