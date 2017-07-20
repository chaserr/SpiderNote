//
//  AddMediaButton.swift
//  Spider
//
//  Created by Atuooo on 5/9/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class AddMediaButton: UIButton {
    fileprivate var hasShowed = false
    fileprivate lazy var mediaView: AddMediaView = {
        return AddMediaView(unDoc: true)
    }()
    
    init() {
        super.init(frame: CGRect(x: kScreenWidth - 45 - 8, y: kScreenHeight - 45 - 19, width: 45, height: 45))
        
        layer.cornerRadius = frame.size.width / 2
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 0.2
        
        backgroundColor = UIColor.white
        setBackgroundImage(UIImage(named: "add_media_button"), for: UIControlState())
        
        mediaView.removeHandler = { [unowned self] in
            self.removeAction()
        }
        self.addTarget(self, action: #selector(addMediaaction), for: .touchUpInside)
    }
    
    func addMediaaction() {
        
        if hasShowed {
            
            removeAction()
            
        } else {
            
            showAnimation()
            
            AppNavigator.getInstance().mainNav?.view.addSubview(mediaView)
            mediaView.alpha = 1.0
            superview!.bringSubview(toFront: self)
            
            buttonAnimation({
                self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/4))
            }, completion: { done in
                self.hasShowed = true
            })
        }
    }
    
    func removeAction() {
        showAnimation()
        
        buttonAnimation({
            self.transform = CGAffineTransform.identity
            
        }, completion: { done in
            
            self.hasShowed = false
            self.mediaView.removeFromSuperview()
        })
    }
    
    fileprivate func buttonAnimation(_ animation: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.3,
                                   delay: 0,
                                   usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 0.3,
                                   options: [],
                                   animations: animation,
                                   completion: completion)
    }
    
    fileprivate func showAnimation() {
        let startRect = frame.insetBy(dx: 10, dy: 10)
        let startPath = UIBezierPath(ovalIn: startRect).cgPath
        let finalRaduis = sqrt(center.x * center.x + center.y * center.y)
        let finalPath = UIBezierPath(ovalIn: frame.insetBy(dx: -finalRaduis, dy: -finalRaduis)).cgPath
                
        let maskLayer = CAShapeLayer()
        maskLayer.isOpaque = false
        maskLayer.path = hasShowed ? startPath : finalPath
        mediaView.layer.mask = maskLayer
        
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = hasShowed ? finalPath : startPath
        maskLayerAnimation.toValue = hasShowed ? startPath : finalPath
        maskLayerAnimation.duration = 0.3
        maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        maskLayerAnimation.isRemovedOnCompletion = false
        maskLayerAnimation.fillMode = kCAFillModeForwards
        
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
