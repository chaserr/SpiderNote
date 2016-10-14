//
//  AudioSlider.swift
//  Spider
//
//  Created by ooatuoo on 16/7/13.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

let ado_toolbar_slider_height = CGFloat(14)
let ado_toolbar_slider_width = CGFloat(245)
let ado_toolbar_slider_thumb = CGFloat(28)

class AudioSlider: UISlider {
    var thumbImage: UIImage!
    
    init() {
        super.init(frame: CGRect(x: (kScreenWidth - ado_toolbar_slider_width) / 2, y: 26, width: ado_toolbar_slider_width, height: ado_toolbar_slider_height))
        
        minimumTrackTintColor = UIColor.whiteColor()
        maximumTrackTintColor = UIColor.color(withHex: 0x878787)
        thumbTintColor = UIColor.whiteColor()
        
        let currentImage = currentThumbImage!
        thumbImage = UIImage(CGImage: currentImage.CGImage!, scale: currentImage.size.height / ado_toolbar_slider_height, orientation: .Up)
        
        setThumbImage(thumbImage, forState: .Normal)
        setThumbImage(thumbImage, forState: .Highlighted)
    }
    
    override func thumbRectForBounds(bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        return CGRect(x: CGFloat(value) * bounds.width - ado_toolbar_slider_thumb / 2, y: ado_toolbar_slider_height / 2 - ado_toolbar_slider_thumb / 2, width: ado_toolbar_slider_thumb, height: ado_toolbar_slider_thumb)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
