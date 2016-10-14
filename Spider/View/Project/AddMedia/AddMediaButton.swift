//
//  AddMediaButton.swift
//  Spider
//
//  Created by Atuooo on 5/9/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class AddMediaButton: UIButton {
    private var hasShowed = false
    private lazy var mediaView: AddMediaView = {
        return AddMediaView(unDoc: true)
    }()
    
    init() {
        super.init(frame: CGRect(x: kScreenWidth - 45 - 8, y: kScreenHeight - 45 - 19, width: 45, height: 45))
        
        layer.cornerRadius = frame.size.width / 2
        layer.shadowOffset = CGSizeZero
        layer.shadowOpacity = 0.2
        
        backgroundColor = UIColor.whiteColor()
        setBackgroundImage(UIImage(named: "add_media_button"), forState: .Normal)
        
        mediaView.removeHandler = { [unowned self] in
            self.removeAction()
        }
        
        self.addTarget(self, action: #selector(action), forControlEvents: .TouchUpInside)
    }
    
    func action() {
        
        if hasShowed {
            
            removeAction()
            
        } else {
            
            showAnimation()
            
            AppNavigator.getInstance().mainNav?.view.addSubview(mediaView)
            mediaView.alpha = 1.0
            superview!.bringSubviewToFront(self)
            
            buttonAnimation({
                self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
            }, completion: { done in
                self.hasShowed = true
            })
        }
    }
    
    func removeAction() {
        showAnimation()
        
        buttonAnimation({
            self.transform = CGAffineTransformIdentity
            
        }, completion: { done in
            
            self.hasShowed = false
            self.mediaView.removeFromSuperview()
        })
    }
    
    private func buttonAnimation(animation: () -> Void, completion: (Bool) -> Void) {
        UIView.animateWithDuration(0.3,
                                   delay: 0,
                                   usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 0.3,
                                   options: [],
                                   animations: animation,
                                   completion: completion)
    }
    
    private func showAnimation() {
        let startRect = CGRectInset(frame, 10, 10)
        let startPath = UIBezierPath(ovalInRect: startRect).CGPath
        let finalRaduis = sqrt(center.x * center.x + center.y * center.y)
        let finalPath = UIBezierPath(ovalInRect: CGRectInset(frame, -finalRaduis, -finalRaduis)).CGPath
                
        let maskLayer = CAShapeLayer()
        maskLayer.opaque = false
        maskLayer.path = hasShowed ? startPath : finalPath
        mediaView.layer.mask = maskLayer
        
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = hasShowed ? finalPath : startPath
        maskLayerAnimation.toValue = hasShowed ? startPath : finalPath
        maskLayerAnimation.duration = 0.3
        maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        maskLayerAnimation.removedOnCompletion = false
        maskLayerAnimation.fillMode = kCAFillModeForwards
        
        maskLayer.addAnimation(maskLayerAnimation, forKey: "path")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
