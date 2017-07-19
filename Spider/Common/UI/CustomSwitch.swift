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
            if !self.on && !self.isTracking {
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
        
            if self.on && self.isTracking {
                background?.backgroundColor = newValue
                background?.layer.borderColor = newValue?.cgColor
            }
        }
    }
    /*
     *	Sets the border color that shows when the switch is off. Defaults to light gray.
     */
    var boardColor: UIColor?{
    
        willSet{
        
            if !self.on {
                background?.layer.borderColor = newValue?.cgColor
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
        
            knob?.layer.shadowColor = shadowColor?.cgColor
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
    
    fileprivate var background: UIView?
    fileprivate var knob: UIView?
    fileprivate var onImageView: UIImageView?
    fileprivate var offImageView: UIImageView?
    fileprivate var startTime: Double?
    fileprivate var isAnimating: Bool = false
    
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        setup()
    }
    
    override init(frame: CGRect) {
        let  initialFrame: CGRect?
        if frame.isEmpty {
            initialFrame = CGRect(x: 0, y: 0, width: 50, height: 30)
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
        inactiveColor                      = UIColor.clear
        activeColor                        = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
        onColor                            = UIColor(red: 0.3, green: 0.85, blue: 0.39, alpha: 1)
        boardColor                         = UIColor(red: 0.89, green: 0.89, blue: 0.91, alpha: 1)
        knobColor                          = UIColor.white
        shadowColor                        = UIColor.gray

        background                         = UIView.init(frame: CGRect(x: 0, y: 0, width: self.w, height: self.h))
        background?.backgroundColor        = UIColor.clear
        background?.layer.cornerRadius     = self.h * 0.5
        background?.layer.borderColor       = boardColor?.cgColor
        background?.layer.borderWidth      = 1.0
        background?.isUserInteractionEnabled = false
        self.addSubview(background!)

        onImageView                        = UIImageView.init(frame: CGRect(x: 0, y: 0, width: self.w - self.h, height: self.h))
        onImageView?.alpha                 = 0
        onImageView?.contentMode           = UIViewContentMode.center
        self.addSubview(onImageView!)

        offImageView                       = UIImageView.init(frame: CGRect(x: 0, y: 0, width: self.w - self.h, height: self.h))
        offImageView?.alpha                = 0
        offImageView?.contentMode          = UIViewContentMode.center
        self.addSubview(offImageView!)

        knob                               = UIView.init(frame: CGRect(x: 1, y: 1, width: self.h - 2, height: self.h - 2))
        knob!.backgroundColor               = self.knobColor
        knob!.layer.cornerRadius            = (self.frame.size.height * 0.5) - 1
        knob!.layer.shadowColor             = self.shadowColor!.cgColor
        knob!.layer.shadowRadius            = 2.0
        knob!.layer.shadowOpacity           = 0.5
        knob!.layer.shadowOffset            = CGSize(width: 0, height: 3)
        knob!.layer.masksToBounds           = false
        knob!.isUserInteractionEnabled        = false
        self.addSubview(knob!)
        isAnimating = false
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        startTime = Date().timeIntervalSince1970
        let activeKnobWidth = self.bounds.h - 2 + 5
        isAnimating = true
        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: { 
                if (self.on) {
                    self.knob!.frame = CGRect(x: self.bounds.size.width - (activeKnobWidth + 1), y: self.knob!.frame.origin.y, width: activeKnobWidth, height: self.knob!.frame.size.height);
                    self.background!.backgroundColor = self.onColor;
                }
                else {
                    self.knob!.frame = CGRect(x: self.knob!.frame.origin.x, y: self.knob!.frame.origin.y, width: activeKnobWidth, height: self.knob!.frame.size.height);
                    self.background!.backgroundColor = self.activeColor;
                }
            }, completion: {(finished: Bool) in
        
                self.isAnimating = false;
        })

        return true
        
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        let  lastPoint = touch.location(in: self)
        if (lastPoint.x > self.bounds.size.width * 0.5){
        self.showOn(true)
        }else{
        self.showOff(true)
        }
        return true;
        
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        let endTime = Date().timeIntervalSince1970
        let difference = endTime - startTime!
        let previousValue = on
        if (difference <= 0.2) {
            let normalKnobWidth = self.bounds.size.height - 2;
            knob!.frame = CGRect(x: knob!.frame.origin.x, y: knob!.frame.origin.y, width: normalKnobWidth, height: knob!.frame.size.height);
            if on {
                self.showOn(true)
            }else{
                
                self.showOff(true)
            }
        }
        else {
            // Get touch location
            let lastPoint = touch!.location(in: self)
            
            // update the switch to the correct value depending on if
            // their touch finished on the right or left side of the switch
            if (lastPoint.x > self.bounds.size.width * 0.5){
                self.on = true
            }else{
                self.on = false
            }
        }
        if previousValue != self.on {
            sendActions(for: UIControlEvents.valueChanged)
        }
        
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
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
            background?.frame = CGRect(x: 0, y: 0, width: frame.w, height: frame.h)
            background!.layer.cornerRadius = self.isRounded ? frame.size.height * 0.5 : 2
            
            // images
            onImageView!.frame = CGRect(x: 0, y: 0, width: frame.size.width - frame.size.height, height: frame.size.height)
            offImageView!.frame = CGRect(x: frame.size.height, y: 0, width: frame.size.width - frame.size.height, height: frame.size.height)
            
            // knob
            let normalKnobWidth = frame.size.height - 2
            if (on){
            knob!.frame = CGRect(x: frame.size.width - (normalKnobWidth + 1), y: 1, width: frame.size.height - 2, height: normalKnobWidth)
            }else{
            knob!.frame = CGRect(x: 1, y: 1, width: normalKnobWidth, height: normalKnobWidth)
            }
            knob!.layer.cornerRadius = self.isRounded ? (frame.size.height * 0.5) - 1 : 2;

        }
    }
    
    func showOn(_ animated: Bool) -> Void {
        
        let normalKnobWidth = self.bounds.h - 2
        let activeKnobWidth = normalKnobWidth + 5
        if animated {
            isAnimating = true
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: { 
                if (self.isTracking){
                    self.knob!.frame = CGRect(x: self.bounds.size.width - (activeKnobWidth + 1), y: self.knob!.frame.origin.y, width: activeKnobWidth, height: self.knob!.frame.size.height)
                }else{
                    self.knob!.frame                   = CGRect(x: self.bounds.size.width - (normalKnobWidth + 1), y: self.knob!.frame.origin.y, width: normalKnobWidth, height: self.knob!.frame.size.height)
                }
                    self.background!.backgroundColor   = self.onColor
                    self.background!.layer.borderColor = self.onColor!.cgColor
                    self.onImageView!.alpha            = 1.0
                    self.offImageView!.alpha           = 0
                }, completion: { (finished: Bool) in
               
                    self.isAnimating = false
                    
            })
        }else{
        
            if (self.isTracking){
                knob!.frame = CGRect(x: self.bounds.size.width - (activeKnobWidth + 1), y: knob!.frame.origin.y, width: activeKnobWidth, height: knob!.frame.size.height)
            }else{
                knob!.frame = CGRect(x: self.bounds.size.width - (normalKnobWidth + 1), y: knob!.frame.origin.y, width: normalKnobWidth, height: knob!.frame.size.height)
            }
                background!.backgroundColor = self.onColor
                background!.layer.borderColor = self.onColor!.cgColor
                onImageView!.alpha = 1.0
                offImageView!.alpha = 0
        }
        
    }
    
    func showOff(_ animated: Bool) -> Void {
        
        let normalKnobWidth = self.bounds.h - 2
        let activeKnobWidth = normalKnobWidth + 5
        if animated {
            isAnimating = true
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                if (self.isTracking){
                    self.knob!.frame = CGRect(x: 1, y: self.knob!.frame.origin.y, width: activeKnobWidth, height: self.knob!.frame.size.height)
                    self.background!.backgroundColor = self.activeColor;

                }else{
                    self.knob!.frame = CGRect(x: 1, y: self.knob!.frame.origin.y, width: normalKnobWidth, height: self.knob!.frame.size.height);
                    self.background!.backgroundColor = self.inactiveColor
                }
                    self.background!.layer.borderColor = self.boardColor!.cgColor
                    self.onImageView!.alpha            = 0.0
                    self.offImageView!.alpha           = 1.0
                
                }, completion: { (finished: Bool) in
                    self.isAnimating = false
                    
            })
        }else{
            
            if (self.isTracking){
                knob!.frame = CGRect(x: 1, y: knob!.frame.origin.y, width: activeKnobWidth, height: knob!.frame.size.height)
                background!.backgroundColor = self.activeColor
            }else{
                knob!.frame = CGRect(x: 1, y: knob!.frame.origin.y, width: normalKnobWidth, height: knob!.frame.size.height)
                background!.backgroundColor = self.inactiveColor
            }
                background!.layer.borderColor = self.boardColor!.cgColor
                onImageView!.alpha = 0.0
                offImageView!.alpha = 1.0
        }
    }
    
    

}
