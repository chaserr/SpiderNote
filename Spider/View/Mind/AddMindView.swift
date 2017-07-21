//
//  AddMindView.swift
//  Spider
//
//  Created by 童星 on 5/13/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class AddMindView: UIView {
    var addMindHandler: ((MindType) -> Void)?
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear // mc_add_mind
        
        let buttonS = CGFloat(36)
        let articleButton = UIButton(frame: CGRect(x: 2, y: 2, width: buttonS, height: buttonS))
        articleButton.setImage(UIImage(named: "mind_article_icon")!.resize(buttonS), for: UIControlState())
        articleButton.addTarget(self, action: #selector(addArticleButtonClicked), for: .touchUpInside)
        addSubview(articleButton)
        
        let nodeButton = UIButton(frame: CGRect(x: 2, y: 36 + 16, width: buttonS, height: buttonS))
        nodeButton.setImage(UIImage(named: "mind_submind_icon")!.resize(buttonS), for: UIControlState())
        nodeButton.addTarget(self, action: #selector(addMindButtonClicked), for: .touchUpInside)
        addSubview(nodeButton)
    }
    
    func addMindButtonClicked() {
        addMindHandler?(.mind)
    }
    
    func addArticleButtonClicked() {
        addMindHandler?(.article)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
