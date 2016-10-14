//
//  TopHitView.swift
//  Spider
//
//  Created by 童星 on 16/8/11.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

let kTopBarBackgroundColor = "kTopBarBackgroundColor"
let kTopBarTextColor = "kTopBarTextColor"
let kTopBarTextFont = "kTopBarTextFont"
let kTopBarIcon = "kTopBarIcon"
let kTopBarHeight: CGFloat = 40.0
let kDefaultDimissDelay = 3.0

class TopHitView: UIView {

    var warningText: String? {
        didSet{
            label.text = warningText
            setNeedsLayout()
        }
    }
    var iconIgv: UIImageView!
    var tapHandler: dispatch_block_t!
    var dismissHandler: dispatch_block_t!
    var label: UILabel!
    var dismissDelay: Float = 0
    var defaultTopMessageConfig = [String:AnyObject]()
    var dismissTimer: NSTimer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = UIViewAutoresizing.FlexibleWidth
        backgroundColor = RGBACOLOR(0.64, g: 0.65, b: 0.66, a: 0.96)
        label = UILabel(frame: CGRectMake(0, 0, 50, kTopBarHeight))
        label.backgroundColor = UIColor.clearColor()
        label.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        label.font = SYSTEMFONT(13)
        label.userInteractionEnabled = true
        
        addSubview(label)
        iconIgv = UIImageView()
        addSubview(iconIgv)
        iconIgv.contentMode = UIViewContentMode.Center
        addTapGesture(target: self, action: #selector(tapNow))
        iconIgv.addTapGesture { (UITapGestureRecognizer) in
            self.dismiss()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showTopMessage(message: String, config: NSDictionary?, delay: Float, tapHandler: dispatch_block_t?) -> Void {
        
        warningText = message;
        self.tapHandler = tapHandler;
        dismissDelay = delay;
        if (config != nil) {
            defaultTopMessageConfig = config as! Dictionary
        }
        resetViews()
        
    }
    
    func resetViews(){
        
        if defaultTopMessageConfig.isEmpty {
            defaultTopMessageConfig = [kTopBarBackgroundColor : RGBACOLOR(0.64, g: 0.65, b: 0.66, a: 0.96), kTopBarTextColor : UIColor.whiteColor(), kTopBarTextFont : SYSTEMFONT(14)]
        }
        
        iconIgv.image = (defaultTopMessageConfig[kTopBarIcon] as? UIImage)?.scaleToSize(CGSizeMake(20, 20))
        label.textColor = UIColor.whiteColor()
        label.font = defaultTopMessageConfig[kTopBarTextFont] as? UIFont
    }
    
    override func layoutSubviews() {
        let textSize: CGSize = label.text!.boundingRectWithSize(CGSizeMake(CGRectGetWidth(self.bounds) * 0.9, 20.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : label.font], context: nil).size
        
        var iconWidth: CGFloat = 30.0
        let betweenIconAndText: CGFloat = 10.0
        if (iconIgv.image == nil) {
            iconWidth = 0.0
        }
        
        self.label.frame = CGRectMake(betweenIconAndText, (CGRectGetHeight(self.bounds) - textSize.height) * 0.5, textSize.width, textSize.height);
        self.iconIgv.frame = CGRectMake(kScreenWidth - 45, (CGRectGetHeight(self.bounds) - iconWidth) * 0.5, iconWidth, iconWidth);
        
    }
    
    
    func dismiss() -> Void {
        // 提示框消失，开始计时
        let closeWarnLoginTime: String = DateUtil.getCurrentDateStringWithFormat(kDU_YYYYMMddhhmmss)
        APP_USER.closeWarnLoginTime = closeWarnLoginTime
        APP_USER.saveUserInfo()
        
        var selfFrame: CGRect = self.frame
        selfFrame.origin.y -= CGRectGetHeight(selfFrame)
        UIView.animateWithDuration(0.25, animations: { 
            self.frame = selfFrame
            self.alpha = 0.3
        }) { (finished: Bool) in
                self.removeFromSuperview()
        }
        
        dismissHandler()
        
    }
    
    func tapNow() -> Void {
        if (tapHandler != nil) {
            tapHandler()
        }
    }
    
    
    deinit{
    
        if (dismissTimer != nil) {
            self.dismissTimer.invalidate()
            self.dismissTimer = nil
        }
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        if (newSuperview != nil) {
            alpha = 1.0
            var selfFrame: CGRect = self.frame
            selfFrame.y -= CGRectGetHeight(selfFrame)
            self.frame = selfFrame
            selfFrame.y = 0
            UIView.animateWithDuration(0.5, animations: { 
                self.frame = selfFrame
                }, completion: { (Bool) in
                    super.willMoveToSuperview(newSuperview)
            })
            if (dismissTimer != nil) {
                self.dismissTimer.invalidate()
                self.dismissTimer = nil
            }
            
            if (self.dismissDelay > 0) {
                self.dismissTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.dismissDelay), target: self, selector: #selector((dismiss)), userInfo: nil, repeats: false)
            }
            
        }else{
        
            if (dismissTimer != nil) {
                self.dismissTimer.invalidate()
                
                self.dismissTimer = nil
            }
        }
    }
    
}

var TopWarningKey =  "TopWarningKey"

extension UIViewController {

    func setTopMessageDefaultApperance(apperance: NSDictionary) -> Void {
        
        
    }
    
//    func showTopMessage(message: String, config: NSDictionary?, delay: Float, tapHandler: dispatch_block_t?) -> Void {
    
//        var topV: TopHitView? = objc_getAssociatedObject(self, &TopWarningKey) as? TopHitView
//        objc_setAssociatedObject(self, &TopWarningKey, topV, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
//        if topV == nil {
//            topV = TopHitView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kTopBarHeight))
//            topV!.warningText = message;
//            topV!.tapHandler = tapHandler;
//            topV!.dismissDelay = delay;
//            if (config != nil) {
//                topV!.defaultTopMessageConfig = config as! Dictionary
//            }
//            topV!.resetViews()
//            view.addSubview(topV!)
//        }
//    }
//    
//    func showTopMessage(message: String) -> Void {
//        showTopMessage(message, config: nil, delay: 0, tapHandler: nil)
//    }
}
