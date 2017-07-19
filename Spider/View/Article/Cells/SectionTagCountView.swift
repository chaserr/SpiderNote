//
//  SectionTagCountView.swift
//  Spider
//
//  Created by ooatuoo on 16/8/15.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class SectionTagCountView: UIImageView {
    
    var tagCount: Int = 0 {
        didSet {
            label.text = "\(tagCount)"
        }
    }
    
    fileprivate var label: UILabel!
    
    init() {
        super.init(frame: CGRect.zero)
        image = UIImage(named: "article_bookmark")
        
        label                           = UILabel()
        label.font                      = UIFont.systemFont(ofSize: 10)
        label.textColor                 = UIColor.white
        label.textAlignment             = .center
        label.adjustsFontSizeToFitWidth = true
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.snp_makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.bottom.equalTo(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
