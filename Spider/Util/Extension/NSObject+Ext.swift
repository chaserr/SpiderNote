//
//  NSObject+Ext.swift
//  Spider
//
//  Created by 童星 on 16/7/12.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

public extension NSObject{

    public class var nameOfClass: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public var nameOfClass: String {
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }
    
    // 同上面效果类似
    public var className: String {
        return self.dynamicType.className
    }
    
    public static var className: String {
        return String(self)
    }
}
