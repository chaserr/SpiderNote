//
//  CreateMindView.swift
//  Spider
//
//  Created by 童星 on 26/09/2016.
//  Copyright © 2016 auais. All rights reserved.
//

import UIKit

class CreateMindView: UIView {
    var doneHandler: ((String) -> Void)?
    
    fileprivate var addView: AddNewMindView!
    
    init(text: String = "") {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))

        alpha = 0
        backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        addView = AddNewMindView(text: text)
        
        addView.doneHandler = { [weak self] text in
            self?.doneHandler?(text)
            self?.quitEdit()
        }
        
        addView.cancelHandler = { [weak self] in
            self?.quitEdit()
        }
    }
    
    func moveTo(_ view: UIView) {
        view.addSubview(self)
        addView.alpha = 0
        addSubview(addView)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
            self.addView.alpha = 1
        }) 
    }
    
    func quitEdit() {
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 0
        }, completion: { done in
            self.addView.removeFromSuperview()
            self.removeFromSuperview()
        }) 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
