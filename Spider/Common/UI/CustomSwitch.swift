//
//  CustomSwitch.swift
//  Spider
//
//  Created by 童星 on 16/8/26.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

class CustomSwitch: UIControl {
    /*
     * Set (without animation) whether the switch is on or off
     */
    var on: Bool = false {
    
        didSet{
            if on {
                self.showOn(true)
            }else{
                
                self.showOff(true)
            }
        }
    }
    /*
     *	Sets the background color when the switch is off.
     *  Defaults to clear color.
     */
    var inactiveColor: UIColor? {
    
        willSet{
            if !self.on && !self.tracking {
                background?.backgroundColor = newValue
            }
        }
        
    }
    /*
     *	Sets the background color that shows when the switch off and actively being touched.
     *  Defaults to light gray.
     */
    var activeColor: UIColor?
    /*
     *	Sets the background color that shows when the switch is on.
     *  Defaults to green.
     */
    var onColor: UIColor?{
    
        willSet{
        
            if self.on && self.tracking {
                background?.backgroundColor = newValue
                background?.layer.borderColor = newValue?.CGColor
            }
        }
    }
    /*
     *	Sets the border color that shows when the switch is off. Defaults to light gray.
     */
    var boardColor: UIColor?{
    
        willSet{
        
            if !self.on {
                background?.layer.borderColor = newValue?.CGColor
            }
        }
    }
    /*
     *	Sets the knob color. Defaults to white.
     */
    var knobColor: UIColor?{
    
        didSet{
        
            knob?.backgroundColor = knobColor
        }
    }
    /*
     *	Sets the shadow color of the knob. Defaults to gray.
     */
    var shadowColor: UIColor?{
    
        didSet{
        
            knob?.layer.shadowColor = shadowColor?.CGColor
        }
    }
    /*
     *	Sets whether or not the switch edges are rounded.
     *  Set to NO to get a stylish square switch.
     *  Defaults to YES.
     */
    var isRounded: Bool = false {
    
        didSet{
        
            background?.layer.cornerRadius = isRounded ? self.h * 0.5 : 2
            knob?.layer.cornerRadius = isRounded ? self.h * 0.5 - 1 : 2
           
        }
    }
    /*
     *	Sets the image that shows when the switch is on.
     *  The image is centered in the area not covered by the knob.
     *  Make sure to size your images appropriately.
     */
    var onImage: UIImage?
    /*
     *	Sets the image that shows when the switch is off.
     *  The image is centered in the area not covered by the knob.
     *  Make sure to size your images appropriately.
     */
    var offImage: UIImage?
    
    private var background: UIView?
    private var knob: UIView?
    private var onImageView: UIImageView?
    private var offImageView: UIImageView?
    private var startTime: Double?
    private var isAnimating: Bool = false
    
    
    init() {
        super.init(frame: CGRectMake(0, 0, 50, 30))
        setup()
    }
    
    override init(frame: CGRect) {
        let  initialFrame: CGRect?
        if CGRectIsEmpty(frame) {
            initialFrame = CGRectMake(0, 0, 50, 30)
        }else{
        
            initialFrame = frame
        }
        super.init(frame: initialFrame!)
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() -> Void {
        inactiveColor                      = UIColor.clearColor()
        activeColor                        = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
        onColor                            = UIColor(red: 0.3, green: 0.85, blue: 0.39, alpha: 1)
        boardColor                         = UIColor(red: 0.89, green: 0.89, blue: 0.91, alpha: 1)
        knobColor                          = UIColor.whiteColor()
        shadowColor                        = UIColor.grayColor()

        background                         = UIView.init(frame: CGRectMake(0, 0, self.w, self.h))
        background?.backgroundColor        = UIColor.clearColor()
        background?.layer.cornerRadius     = self.h * 0.5
        background?.layer.borderColor       = boardColor?.CGColor
        background?.layer.borderWidth      = 1.0
        background?.userInteractionEnabled = false
        self.addSubview(background!)

        onImageView                        = UIImageView.init(frame: CGRectMake(0, 0, self.w - self.h, self.h))
        onImageView?.alpha                 = 0
        onImageView?.contentMode           = UIViewContentMode.Center
        self.addSubview(onImageView!)

        offImageView                       = UIImageView.init(frame: CGRectMake(0, 0, self.w - self.h, self.h))
        offImageView?.alpha                = 0
        offImageView?.contentMode          = UIViewContentMode.Center
        self.addSubview(offImageView!)

        knob                               = UIView.init(frame: CGRectMake(1, 1, self.h - 2, self.h - 2))
        knob!.backgroundColor               = self.knobColor
        knob!.layer.cornerRadius            = (self.frame.size.height * 0.5) - 1
        knob!.layer.shadowColor             = self.shadowColor!.CGColor
        knob!.layer.shadowRadius            = 2.0
        knob!.layer.shadowOpacity           = 0.5
        knob!.layer.shadowOffset            = CGSizeMake(0, 3)
        knob!.layer.masksToBounds           = false
        knob!.userInteractionEnabled        = false
        self.addSubview(knob!)
        isAnimating = false
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        startTime = NSDate().timeIntervalSince1970
        let activeKnobWidth = self.bounds.h - 2 + 5
        isAnimating = true
        UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: { 
                if (self.on) {
                    self.knob!.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + 1), self.knob!.frame.origin.y, activeKnobWidth, self.knob!.frame.size.height);
                    self.background!.backgroundColor = self.onColor;
                }
                else {
                    self.knob!.frame = CGRectMake(self.knob!.frame.origin.x, self.knob!.frame.origin.y, activeKnobWidth, self.knob!.frame.size.height);
                    self.background!.backgroundColor = self.activeColor;
                }
            }, completion: {(finished: Bool) in
        
                self.isAnimating = false;
        })

        return true
        
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        let  lastPoint = touch.locationInView(self)
        if (lastPoint.x > self.bounds.size.width * 0.5){
        self.showOn(true)
        }else{
        self.showOff(true)
        }
        return true;
        
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        super.endTrackingWithTouch(touch, withEvent: event)
        let endTime = NSDate().timeIntervalSince1970
        let difference = endTime - startTime!
        let previousValue = on
        if (difference <= 0.2) {
            let normalKnobWidth = self.bounds.size.height - 2;
            knob!.frame = CGRectMake(knob!.frame.origin.x, knob!.frame.origin.y, normalKnobWidth, knob!.frame.size.height);
            if on {
                self.showOn(true)
            }else{
                
                self.showOff(true)
            }
        }
        else {
            // Get touch location
            let lastPoint = touch!.locationInView(self)
            
            // update the switch to the correct value depending on if
            // their touch finished on the right or left side of the switch
            if (lastPoint.x > self.bounds.size.width * 0.5){
                self.on = true
            }else{
                self.on = false
            }
        }
        if previousValue != self.on {
            sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
        
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        super.cancelTrackingWithEvent(event)
        if on {
            self.showOn(true)
        }else{
        
            self.showOff(true)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isAnimating {
            let frame = self.frame
            background?.frame = CGRectMake(0, 0, frame.w, frame.h)
            background!.layer.cornerRadius = self.isRounded ? frame.size.height * 0.5 : 2
            
            // images
            onImageView!.frame = CGRectMake(0, 0, frame.size.width - frame.size.height, frame.size.height)
            offImageView!.frame = CGRectMake(frame.size.height, 0, frame.size.width - frame.size.height, frame.size.height)
            
            // knob
            let normalKnobWidth = frame.size.height - 2
            if (on){
            knob!.frame = CGRectMake(frame.size.width - (normalKnobWidth + 1), 1, frame.size.height - 2, normalKnobWidth)
            }else{
            knob!.frame = CGRectMake(1, 1, normalKnobWidth, normalKnobWidth)
            }
            knob!.layer.cornerRadius = self.isRounded ? (frame.size.height * 0.5) - 1 : 2;

        }
    }
    
    func showOn(animated: Bool) -> Void {
        
        let normalKnobWidth = self.bounds.h - 2
        let activeKnobWidth = normalKnobWidth + 5
        if animated {
            isAnimating = true
            UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseOut, .BeginFromCurrentState], animations: { 
                if (self.tracking){
                    self.knob!.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + 1), self.knob!.frame.origin.y, activeKnobWidth, self.knob!.frame.size.height)
                }else{
                    self.knob!.frame                   = CGRectMake(self.bounds.size.width - (normalKnobWidth + 1), self.knob!.frame.origin.y, normalKnobWidth, self.knob!.frame.size.height)
                }
                    self.background!.backgroundColor   = self.onColor
                    self.background!.layer.borderColor = self.onColor!.CGColor
                    self.onImageView!.alpha            = 1.0
                    self.offImageView!.alpha           = 0
                }, completion: { (finished: Bool) in
               
                    self.isAnimating = false
                    
            })
        }else{
        
            if (self.tracking){
                knob!.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + 1), knob!.frame.origin.y, activeKnobWidth, knob!.frame.size.height)
            }else{
                knob!.frame = CGRectMake(self.bounds.size.width - (normalKnobWidth + 1), knob!.frame.origin.y, normalKnobWidth, knob!.frame.size.height)
            }
                background!.backgroundColor = self.onColor
                background!.layer.borderColor = self.onColor!.CGColor
                onImageView!.alpha = 1.0
                offImageView!.alpha = 0
        }
        
    }
    
    func showOff(animated: Bool) -> Void {
        
        let normalKnobWidth = self.bounds.h - 2
        let activeKnobWidth = normalKnobWidth + 5
        if animated {
            isAnimating = true
            UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseOut, .BeginFromCurrentState], animations: {
                if (self.tracking){
                    self.knob!.frame = CGRectMake(1, self.knob!.frame.origin.y, activeKnobWidth, self.knob!.frame.size.height)
                    self.background!.backgroundColor = self.activeColor;

                }else{
                    self.knob!.frame = CGRectMake(1, self.knob!.frame.origin.y, normalKnobWidth, self.knob!.frame.size.height);
                    self.background!.backgroundColor = self.inactiveColor
                }
                    self.background!.layer.borderColor = self.boardColor!.CGColor
                    self.onImageView!.alpha            = 0.0
                    self.offImageView!.alpha           = 1.0
                
                }, completion: { (finished: Bool) in
                    self.isAnimating = false
                    
            })
        }else{
            
            if (self.tracking){
                knob!.frame = CGRectMake(1, knob!.frame.origin.y, activeKnobWidth, knob!.frame.size.height)
                background!.backgroundColor = self.activeColor
            }else{
                knob!.frame = CGRectMake(1, knob!.frame.origin.y, normalKnobWidth, knob!.frame.size.height)
                background!.backgroundColor = self.inactiveColor
            }
                background!.layer.borderColor = self.boardColor!.CGColor
                onImageView!.alpha = 0.0
                offImageView!.alpha = 1.0
        }
    }
    
    

}
