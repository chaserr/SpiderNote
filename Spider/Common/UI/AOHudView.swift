//
//  AOHudView.swift
//  Spider
//
//  Created by 童星 on 16/7/26.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  tipsView

import UIKit
import MBProgressHUD

let AOHUDVIEW = AOHudView.getInstance()
let HUD_DEFAULT_HIDE_TIME = 2.0

class AOHudView: NSObject {

    
    var showingCaption:String!
    var hud:MBProgressHUD!
    var parebtView:UIView!
    var title:String!
    
    
    
    
    static var instance:AOHudView?
    class func getInstance() ->AOHudView {
        if (instance == nil) {
            
            instance = AOHudView()
        }
        return instance!
    }
    /** auto dismiss tips */
    func showTipsWithAutoHide(_ tips:String, autoHideTime:TimeInterval) -> Void {
        showHudOnView(((UIApplication.shared.delegate?.window)!)! as UIView, caption: tips, image: nil, bActive: false, autoHideTime: autoHideTime)
    }
    
    /** message box:  default 1 second auto dismiss*/
    func showTips(_ tips:String) -> Void {
        showHudOnView(((UIApplication.shared.delegate?.window)!)! as UIView, caption: tips, image: nil, bActive: false, autoHideTime: 1)

    }
    
    /** show loading view */
    func showLoadingView(_ loadingTitle:String) -> Void {
        showHudOnView(((UIApplication.shared.delegate?.window)!)!, caption: loadingTitle, image: nil, bActive: true, autoHideTime: 0)
    }
    /** hidden loading view */
    func hideLoadingView() -> Void {
        hideHudInView(((UIApplication.shared.delegate?.window)!)!)
    }
    /** custom image toolTips */
    func showcaptionWithImage(_ caption:String, image:UIImage?, autoHideTime:NSInteger) -> Void {
        // 删除此view上原有的hud
        let view:UIView = (UIApplication.shared.delegate!.window!)!
        var array:[MBProgressHUD] = []
        let subviews = view.subviews
        for aView in subviews {
            if aView is MBProgressHUD {
                array.append(aView as! MBProgressHUD)
            }
        }
        
        for obj:MBProgressHUD in array {
            obj.hide(animated: false)
        }
        
        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        hud.detailsLabel.text = caption
        if image != nil {
            hud.mode = MBProgressHUDMode.customView
            let imageRect:CGRect = CGRect(x: 0, y: 0, width: image!.size.width * 2, height: image!.size.height * 2)
            hud.customView = UIImageView.init(frame: imageRect)
            (hud.customView as! UIImageView).image = image
        }
        
        if autoHideTime == 0 {
            hud.hide(animated: true, afterDelay: 3.0)
        }
        else {
            hud.hide(animated: true, afterDelay:3.0)
        }
    }
    
    /**
     show tips on current view
     
     - parameter view:         currentView
     - parameter caption:      show title
     - parameter image:        custom image
     - parameter bActive:      is show cicle loading or tips
     - parameter autoHideTime: auto dismiss after autoHideTime
     */
    func showHudOnView(_ view:UIView!, caption:String?, image:UIImage?, bActive:Bool, autoHideTime:TimeInterval) -> Void {
        let array:[MBProgressHUD] = MBProgressHUD.allHUDs(for: view) as! [MBProgressHUD]
        for obj:MBProgressHUD in array {
            obj.hide(false)
        }
        
        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        guard let caption = caption else { return }
        hud.detailsLabel.text = caption
        if !bActive {
            hud.mode = MBProgressHUDMode.text
        }else{
        
            hud.mode = MBProgressHUDMode.indeterminate
        }
        
        if image != nil {
            hud.mode = MBProgressHUDMode.customView
            hud.customView = rotate360DegreeWithImageView(UIImageView(image: image))
        }
        
        if autoHideTime > 0.0 {
            hud.hide(animated:true, afterDelay: autoHideTime)
        }
        
    }
}

// MARK: common method
extension AOHudView{

    func rotate360DegreeWithImageView(_ imageView:UIImageView) -> UIImageView {
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
        animation.byValue = (M_PI*2)
        animation.duration = 1.0
        animation.repeatCount = Float.infinity
        animation.isCumulative = true
        animation.isRemovedOnCompletion = false
        
        //在图片边缘添加一个像素的透明区域，去图片锯齿
        let imageRrect:CGRect = CGRect(x: 0, y: 0,width: imageView.image!.size.width, height: imageView.image!.size.height);
        UIGraphicsBeginImageContext(imageRrect.size);
        imageView.image?.draw(in: CGRect(x: 1,y: 1,width: imageView.image!.size.width-2,height: imageView.image!.size.height-2))
        imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        imageView.layer.add(animation, forKey: nil)
        return imageView;
        
    }
    
    func hideHudInView(_ parentView:UIView) -> Void {
        var array:[MBProgressHUD] = []
        let subviews = parentView.subviews
        for aView in subviews {
            if aView is MBProgressHUD {
                array.append(aView as! MBProgressHUD)
            }
        }
        for obj:MBProgressHUD in array {
            obj.hide(animated:false)
            obj.removeFromSuperview()
        }
    }
    
    func hideHudInView(_ parentView:UIView, time:TimeInterval) -> Void {
        var array:[MBProgressHUD] = []
        let subviews = parentView.subviews
        for aView in subviews {
            if aView is MBProgressHUD {
                array.append(aView as! MBProgressHUD)
            }
        }
        for obj:MBProgressHUD in array {
            obj.hide(animated:true, afterDelay: time)
        }
    }
    
}

// MAKR: MBProgress extension
extension AOHudView {

    func showLoadingHUD(_ showStr: String, parentView:UIView) -> Void {
        hud = MBProgressHUD.showAdded(to: parentView, animated: true)
        hud.label.text = showStr
        
    }
    
    func hideHUD() -> Void {
        hideLoadingView()
    }
}
