//
//  AlertView.swift
//  Spider
//
//  Created by 童星 on 16/8/31.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

typealias AlertViewBlock =  () -> Void
typealias AlertViewStringBlock = (String) -> Void

class AlertView: NSObject, UIAlertViewDelegate {

    enum AlertViewType: String{
        case AlertViewTypeNormal = "AlertViewTypeNormal"
        case AlertViewTypeTextField = "AlertViewTypeTextField"
    }
    
    var alertView: UIAlertView?
    var cancleBtnBlock: AlertViewBlock?
    var otherBtnBlock: AlertViewBlock?
    
    
    
    
    init(title: String?, message: String?, cancleBtnTitle: String?, otherButtonTitle: String?, theCancleBtnBlock: AlertViewBlock, theOtherBtnBlock: AlertViewBlock) {
        super.init()
        cancleBtnBlock = theCancleBtnBlock
        otherBtnBlock = theOtherBtnBlock
        alertView = UIAlertView.init(title: title!, message: message!, delegate: self, cancelButtonTitle: cancleBtnTitle, otherButtonTitles: otherButtonTitle!)
        alertView!.show()
    }
    

    class func alert(title: String?, message: String?, cancleBtnTitle: String?, otherButtonTitle: String?, theCancleBtnBlock: AlertViewBlock, theOtherBtnBlock: AlertViewBlock) -> AlertView {
        let alert = AlertView.init(title: title!, message: message!, cancleBtnTitle: cancleBtnTitle!, otherButtonTitle: otherButtonTitle!, theCancleBtnBlock: theCancleBtnBlock, theOtherBtnBlock: theOtherBtnBlock)
        
        return alert
    }
    
}

extension AlertView{

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            if cancleBtnBlock != nil {
                cancleBtnBlock!()
            }
        case 1:
            if otherBtnBlock != nil {
                otherBtnBlock!()
            }
        default:
            break
        }
    }
    
    func alertViewCancel(alertView: UIAlertView) {
        if cancleBtnBlock != nil {
            cancleBtnBlock!()
        }
    }
}
