//
//  TextSectionView.swift
//  Spider
//
//  Created by 童星 on 16/8/8.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class TextSectionView: UIView {
    
    typealias TapTextAction = (_ type:ClickViewType) -> Void
    var tapTextAction:TapTextAction!
    
    var seperatorView: UIView!
    var backgroundView: UIView!
    var contentText: UILabel!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        seperatorView                      = UIView()
        seperatorView.backgroundColor      = RGBCOLORV(0xeaeaea)
        backgroundView                     = UIView()
        backgroundView.backgroundColor     = RGBCOLORV(0xf0f0f0)
        backgroundView.layer.cornerRadius  = 5
        backgroundView.layer.masksToBounds = true
        contentText                        = UILabel()
        contentText.font                   = SYSTEMFONT(16)
        contentText.textColor              = RGBCOLORV(0x666666)
        contentText.lineBreakMode          = NSLineBreakMode.byTruncatingTail
        contentText.numberOfLines          = 0

        addSubview(seperatorView)
        addSubview(backgroundView)
        backgroundView.addSubview(contentText)
        addUIConstraints()
        addTapGesture { (UITapGestureRecognizer) in
            self.tapTextAction(ClickViewType.text)
        }

    }
    
    func addUIConstraints() -> Void {
        seperatorView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview().offset(0)
            make.height.equalTo(1)
        }
        backgroundView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(seperatorView.snp.bottom).offset(10)
            make.center.equalToSuperview()
        }
        
        contentText.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.left.equalTo(10)
            make.center.equalToSuperview()
        }
    }
    
    func tapTextView(_ tap:@escaping TapTextAction) -> Void {
        tapTextAction = tap
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    

}
