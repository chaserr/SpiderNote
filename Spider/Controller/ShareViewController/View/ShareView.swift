//
//  ShareView.swift
//  Spider
//
//  Created by 童星 on 16/8/24.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

enum ShareType: String {
    case CopyLink     = "复制链接"
    case TakePassword = "带密访问"
    case SendEmail    = "邮件"
    case More         = "更多"
    case WeiXin       = "微信"
    case FriendCircle = "朋友圈"
    case MobileQQ     = "手机QQ"
    case Qzone        = "QQ空间"
    case Sina         = "新浪微博"
    case CancelShare  = "取消分享"
}

protocol ShareViewDelegate {
    func shareView(_ shareType: ShareType) -> Void
}

class ShareView: UIView {

    typealias SwitchClosure = (_ switchOn: Bool) -> Void
    
    var switchClosure: SwitchClosure?
    
    @IBOutlet weak var copyLabel: CopyLabel!
    @IBOutlet weak var switchBgVIew: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    var delegate: ShareViewDelegate?
    

    class func createShareView() -> ShareView {
    
       let nibName = className
        
       let shareView = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)!.first as! ShareView
       return shareView
    }
    
    @IBAction func longPressToCopy(_ sender: UITapGestureRecognizer) {
        // 轻拍手势
//        let labelIdenfify = sender.view?.accessibilityIdentifier
//        if labelIdenfify == ShareType.TakePassword.rawValue {
//            delegate?.shareView(.TakePassword)
//        }
        
    }
    

    @IBAction func actionBtn(_ sender: UIButton) {
        let shareType: String = sender.accessibilityIdentifier!
        
        switch shareType {
        case ShareType.CopyLink.rawValue:
            delegate?.shareView(.CopyLink)
        case ShareType.SendEmail.rawValue:
            delegate?.shareView(.SendEmail)
        case ShareType.More.rawValue:
            delegate?.shareView(.More)
        case ShareType.WeiXin.rawValue:
            delegate?.shareView(.WeiXin)
        case ShareType.FriendCircle.rawValue:
            delegate?.shareView(.FriendCircle)
        case ShareType.MobileQQ.rawValue:
            delegate?.shareView(.MobileQQ)
        case ShareType.Qzone.rawValue:
            delegate?.shareView(.Qzone)
        case ShareType.Sina.rawValue:
            delegate?.shareView(.Sina)

        default: break
            
        }
    }

    @IBAction func cancelShareAction(_ sender: AnyObject) {
        if sender.accessibilityIdentifier! == ShareType.CancelShare.rawValue {
            delegate?.shareView(.CancelShare)
        }
    }
    
    override func layoutSubviews() {
        let switchView = SevenSwitch.init(frame: CGRect(x: 0, y: 0, width: 65, height: 35))
        switchView.isRounded = false
        switchView.on = true
        switchView.addTarget(self, action: #selector(valueChange), for: UIControlEvents.valueChanged)
        switchBgVIew.addSubview(switchView)
    }
    
    func switchValueChange(_ closure: @escaping SwitchClosure) -> Void {
        switchClosure = closure
    }
    
    func valueChange(_ sender: SevenSwitch) -> Void {
        if switchClosure != nil {
            switchClosure!(sender.on)
        }
    }
    
}
