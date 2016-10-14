//
//  BaseObject.swift
//  Spider
//
//  Created by 童星 on 16/6/27.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
class BaseObject: NSObject, NSCoding {

    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        decodeAutoWithAutoCoder(aDecoder)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        encodeAutoWithCoder(aCoder)
        

    }
    
    
    

}
