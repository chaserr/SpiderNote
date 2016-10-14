//
//  OutlineNewView.swift
//  Spider
//
//  Created by Atuooo on 07/09/2016.
//  Copyright © 2016 auais. All rights reserved.
//

import UIKit

class OutlineNewView: UIView {
    
    var doneHandler: ((String, MindType) -> Void)?
    
    private var type = MindType.Mind
    
    private var tap: UITapGestureRecognizer!
    
    private var newMind: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        button.backgroundColor = UIColor.whiteColor()
        button.setTitle("新建节点", forState: .Normal)
        button.setTitleColor(SpiderConfig.Color.DarkText, forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        return button
    }()
    
    private var newArticle: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        button.backgroundColor = UIColor.whiteColor()
        button.setTitle("新建长文", forState: .Normal)
        button.setTitleColor(SpiderConfig.Color.DarkText, forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        return button
    }()
    
    private lazy var addView: AddNewMindView = {
        let view = AddNewMindView()
        view.doneHandler = { [weak self] text in
            self?.doneHandler?(text, self!.type)
            self?.quitAdd()
        }
        
        view.cancelHandler = { [weak self] in
            self?.quitAdd()
        }
        
        return view
    }()
    
    init(state: OutlineEditBarState) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        
        alpha = 0
        backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        switch state {
            
        case .InNewMind, .NewMind:
            newMind.center = center
            addSubview(newMind)
            
        case .NewBoth:
            newMind.center = CGPoint(x: center.x, y: center.y - 20.5)
            addSubview(newMind)
            newArticle.center = CGPoint(x: center.x, y: center.y + 20.5)
            addSubview(newArticle)
            
        default:
            break
        }
        
        tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        newMind.addTarget(self, action: #selector(newMindClicked), forControlEvents: .TouchUpInside)
        newArticle.addTarget(self, action: #selector(newArticleClicked), forControlEvents: .TouchUpInside)
    }
    
    func moveTo(view: UIView) {
        view.addSubview(self)
        UIView.animateWithDuration(0.3) {
            self.alpha = 1
        }
    }
    
    func didTap(ges: UITapGestureRecognizer) {
        
        UIView.animateWithDuration(0.3, animations: {
            self.alpha = 0
        }) { done in
            self.removeFromSuperview()
        }
    }
    
    func newMindClicked() {
        type = .Mind
        addTextView()
    }
    
    func newArticleClicked() {
        type = .Article
        addTextView()
    }
    
    func addTextView() {
        tap.enabled = false
        addView.alpha = 0
        addSubview(addView)
        newArticle.hidden = true
        newMind.hidden = true
        
        UIView.animateWithDuration(0.3, animations: {
            self.addView.alpha = 1
        }, completion: nil)
    }
    
    func quitAdd() {
        UIView.animateWithDuration(0.3, animations: { 
            self.alpha = 0
        }) { done in
            self.addView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
