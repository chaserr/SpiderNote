//
//  OutlineNewView.swift
//  Spider
//
//  Created by 童星 on 07/09/2016.
//  Copyright © 2016 auais. All rights reserved.
//

import UIKit

class OutlineNewView: UIView {
    
    var doneHandler: ((String, MindType) -> Void)?
    
    fileprivate var type = MindType.mind
    
    fileprivate var tap: UITapGestureRecognizer!
    
    fileprivate var newMind: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        button.backgroundColor = UIColor.white
        button.setTitle("新建节点", for: UIControlState())
        button.setTitleColor(SpiderConfig.Color.DarkText, for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    fileprivate var newArticle: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        button.backgroundColor = UIColor.white
        button.setTitle("新建长文", for: UIControlState())
        button.setTitleColor(SpiderConfig.Color.DarkText, for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    fileprivate lazy var addView: AddNewMindView = {
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
            
        case .inNewMind, .newMind:
            newMind.center = center
            addSubview(newMind)
            
        case .newBoth:
            newMind.center = CGPoint(x: center.x, y: center.y - 20.5)
            addSubview(newMind)
            newArticle.center = CGPoint(x: center.x, y: center.y + 20.5)
            addSubview(newArticle)
            
        default:
            break
        }
        
        tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        newMind.addTarget(self, action: #selector(newMindClicked), for: .touchUpInside)
        newArticle.addTarget(self, action: #selector(newArticleClicked), for: .touchUpInside)
    }
    
    func moveTo(_ view: UIView) {
        view.addSubview(self)
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
        }) 
    }
    
    func didTap(_ ges: UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion: { done in
            self.removeFromSuperview()
        }) 
    }
    
    func newMindClicked() {
        type = .mind
        addTextView()
    }
    
    func newArticleClicked() {
        type = .article
        addTextView()
    }
    
    func addTextView() {
        tap.isEnabled = false
        addView.alpha = 0
        addSubview(addView)
        newArticle.isHidden = true
        newMind.isHidden = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.addView.alpha = 1
        }, completion: nil)
    }
    
    func quitAdd() {
        UIView.animate(withDuration: 0.3, animations: { 
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
