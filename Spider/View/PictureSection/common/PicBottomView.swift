//
//  PicBottomView.swift
//  Spider
//
//  Created by 童星 on 5/31/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class PicBottomView: UIView {
    var showTagButton: UIButton!
    
    fileprivate var showTag = true
    
    init() {
        super.init(frame: CGRect(x: 0, y: kScreenHeight - 44, width: kScreenWidth, height: 44))
        
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        showTagButton = UIButton(frame: CGRect(x: (kScreenWidth - 20) / 2, y: 12, width: 20, height: 20))
        showTagButton.frame.size = CGSize(width: 20, height: 20)
        showTagButton.setBackgroundImage(UIImage(named: "pic_show_tag"), for: UIControlState())
        showTagButton.addTarget(self, action: #selector(changeImage), for: .touchUpInside)
        addSubview(showTagButton)
    }
    
    func changeImage() {
        showTag = !showTag
        
        showTagButton.setBackgroundImage(UIImage(named:  showTag ? "pic_show_tag" : "pic_hide_tag"), for: UIControlState())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
