//
//  LaunchController.swift
//  Spider
//
//  Created by 童星 on 16/9/6.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

enum AppearStyle: Int {
    case none = 0
    case one
}

enum DisappearStyle: Int {
    case none
    case one
    case two
    case left
    case right
    case bottom
    case top
}

class LaunchController: NSObject {

    var iconFrame: CGRect?
    var desLabelFrame: CGRect?
    var desLabel: UILabel?
    
    func loadLaunchImage(_ imageName: String) -> Void {
        
    }
    
    func loadLaunchImage(_ imageName: String, iconName: String) -> Void {
        
    }
    
    func loadLaunchImage(_ imgName: String, iconName: String, appearSty: AppearStyle, bgImageName: String, disappearStyle: DisappearStyle, descriptionStr: String) -> Void {
        
    }
    
    
}
