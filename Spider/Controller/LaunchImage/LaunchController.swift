//
//  LaunchController.swift
//  Spider
//
//  Created by 童星 on 16/9/6.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

enum AppearStyle: Int {
    case None = 0
    case One
}

enum DisappearStyle: Int {
    case None
    case One
    case Two
    case Left
    case Right
    case Bottom
    case Top
}

class LaunchController: NSObject {

    var iconFrame: CGRect?
    var desLabelFrame: CGRect?
    var desLabel: UILabel?
    
    func loadLaunchImage(imageName: String) -> Void {
        
    }
    
    func loadLaunchImage(imageName: String, iconName: String) -> Void {
        
    }
    
    func loadLaunchImage(imgName: String, iconName: String, appearSty: AppearStyle, bgImageName: String, disappearStyle: DisappearStyle, descriptionStr: String) -> Void {
        
    }
    
    
}
