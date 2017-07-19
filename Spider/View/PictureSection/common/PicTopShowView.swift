//
//  PicTopShowView.swift
//  Spider
//
//  Created by Atuooo on 5/31/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class PicTopShowView: UIView {
    
    var backHandler: (() -> Void)?
    var editHandler: (() -> Void)?
    
    var count = Int(0)
    
    var currentIndex = Int(1) {
        didSet {
            indexLabel.text = "\(self.currentIndex + 1)/\(self.count)"
        }
    }
    
    lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 18)
        label.frame.size = CGSize(width: 60, height: 30)
        label.textAlignment = .center
        label.center = CGPoint(x: kScreenWidth / 2, y: (kPicThumbH + kStatusBarH) / 2)
        self.addSubview(label)
        return label
    }()
    
    init(index:Int, num: Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kPicThumbH))
        count = num
        indexLabel.text = "\(index+1)/\(num)"
        
        backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        do {
            let backButton = UIButton(frame: CGRect(x: kPicBackRO, y: kPicBackOy, width: kPicBackS, height: kPicBackS))
            backButton.setBackgroundImage(UIImage(named: "pic_back_button"), for: UIControlState())
            backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
            addSubview(backButton)
        }
        
        do {
            let editorButton = UIButton(frame: CGRect(x: kScreenWidth - kPicBackRO - kPicBackS, y: kPicBackOy, width: kPicBackS, height: kPicBackS))
            editorButton.setBackgroundImage(UIImage(named: "pic_edit_button"), for: UIControlState())
            editorButton.addTarget(self, action: #selector(editorButtonClicked), for: .touchUpInside)
            addSubview(editorButton)
        }
    }
    
    func backButtonClicked() {
        backHandler?()
    }
    
    func editorButtonClicked() {
        editHandler?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
