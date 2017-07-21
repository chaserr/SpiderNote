//
//  ATUtility.swift
//  Spider
//
//  Created by 童星 on 5/25/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import Foundation

class ATScreenSize {
    static let sharedInstance = ATScreenSize()
    
    let size: CGSize = {
        var ss = UIScreen.main.bounds.size
        if ss.height < ss.width {
            let tmp = ss.width
            ss.width = ss.height
            ss.height = tmp
        }
        return ss
    }()
    
    fileprivate init() {}
}





