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
    func showTipsWithAutoHide(tips:String, autoHideTime:NSTimeInterval) -> Void {
        showHudOnView(((UIApplication.sharedApplication().delegate?.window)!)! as UIView, caption: tips, image: nil, bActive: false, autoHideTime: autoHideTime)
    }
    
    /** message box:  default 1 second auto dismiss*/
    func showTips(tips:String) -> Void {
        showHudOnView(((UIApplication.sharedApplication().delegate?.window)!)! as UIView, caption: tips, image: nil, bActive: false, autoHideTime: 1)

    }
    
    /** show loading view */
    func showLoadingView(loadingTitle:String) -> Void {
        showHudOnView(((UIApplication.sharedApplication().delegate?.window)!)!, caption: loadingTitle, image: nil, bActive: true, autoHideTime: 0)
    }
    /** hidden loading view */
    func hideLoadingView() -> Void {
        hideHudInView(((UIApplication.sharedApplication().delegate?.window)!)!)
    }
    /** custom image toolTips */
    func showcaptionWithImage(caption:String, image:UIImage?, autoHideTime:NSInteger) -> Void {
        // 删除此view上原有的hud
        let view:UIView = (UIApplication.sharedApplication().delegate!.window!)!
        let array:[MBProgressHUD] = MBProgressHUD.allHUDsForView(view) as! [MBProgressHUD]
        for obj:MBProgressHUD in array {
            obj.hide(false)
        }
        
        let hud:MBProgressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.detailsLabelText = caption
        if image != nil {
            hud.mode = MBProgressHUDMode.CustomView
            let imageRect:CGRect = CGRectMake(0, 0, image!.size.width * 2, image!.size.height * 2)
            hud.customView = UIImageView.init(frame: imageRect)
            (hud.customView as! UIImageView).image = image
        }
        
        if autoHideTime == 0 {
            hud.hide(true, afterDelay:3)
        }
        else {
            hud.hide(true, afterDelay:3)
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
    func showHudOnView(view:UIView, caption:String?, image:UIImage?, bActive:Bool, autoHideTime:NSTimeInterval) -> Void {
        let array:[MBProgressHUD] = MBProgressHUD.allHUDsForView(view) as! [MBProgressHUD]
        for obj:MBProgressHUD in array {
            obj.hide(false)
        }
        
        let hud:MBProgressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.detailsLabelText = caption
        if !bActive {
            hud.mode = MBProgressHUDMode.Text
        }else{
        
            hud.mode = MBProgressHUDMode.Indeterminate
        }
        
        if image != nil {
            hud.mode = MBProgressHUDMode.CustomView
            hud.customView = rotate360DegreeWithImageView(UIImageView(image: image))
        }
        
        if autoHideTime > 0.0 {
            hud.hide(true, afterDelay: autoHideTime)
        }
        
    }
}

// MARK: common method
extension AOHudView{

    func rotate360DegreeWithImageView(imageView:UIImageView) -> UIImageView {
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
        animation.byValue = (M_PI*2)
        animation.duration = 1.0
        animation.repeatCount = Float.infinity
        animation.cumulative = true
        animation.removedOnCompletion = false
        
        //在图片边缘添加一个像素的透明区域，去图片锯齿
        let imageRrect:CGRect = CGRectMake(0, 0,imageView.image!.size.width, imageView.image!.size.height);
        UIGraphicsBeginImageContext(imageRrect.size);
        imageView.image?.drawInRect(CGRectMake(1,1,imageView.image!.size.width-2,imageView.image!.size.height-2))
        imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        imageView.layer.addAnimation(animation, forKey: nil)
        return imageView;
        
    }
    
    func hideHudInView(parentView:UIView) -> Void {
        let array:[MBProgressHUD] = MBProgressHUD.allHUDsForView(parentView) as! [MBProgressHUD]
        for obj:MBProgressHUD in array {
            obj.hide(false)
            obj.removeFromSuperview()
        }
    }
    
    func hideHudInView(parentView:UIView, time:NSTimeInterval) -> Void {
        let array:[MBProgressHUD] = MBProgressHUD.allHUDsForView(parentView) as! [MBProgressHUD]
        for obj:MBProgressHUD in array {
            obj.hide(true, afterDelay: time)
        }
    }
    
}

// MAKR: MBProgress extension
extension AOHudView {

    func showLoadingHUD(showStr: String, parentView:UIView) -> Void {
        hud = MBProgressHUD.showHUDAddedTo(parentView, animated: true)
        hud.labelText = showStr
        
    }
    
    func hideHUD() -> Void {
        hideLoadingView()
    }
}
