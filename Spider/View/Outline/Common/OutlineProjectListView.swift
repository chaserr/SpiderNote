//
//  OutlineProjectListView.swift
//  Spider
//
//  Created by ooatuoo on 16/9/1.
//  Copyright © 2016年 auais. All rights reserved.
//

import UIKit

class OutlineProjectListView: UITableView {
    
    var selectHandler: ((ProjectObject) -> ())?
    
    fileprivate var projects = SpiderRealm.getProjects()
    fileprivate var currentID = ""
    
    init(currentID: String) {
        super.init(frame: CGRect(x: 0, y: 64, width: kScreenWidth, height: kScreenHeight - 64), style: .plain)
        
        self.currentID = currentID
        
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        tableFooterView = UIView()
        separatorInset = UIEdgeInsetsMake(0, 50, 0, 0)
        separatorColor = SpiderConfig.Color.Line
        
        rowHeight = 50
        delegate = self
        dataSource = self
    }
    
    func addOrRemoveTo(_ view: UIView? = nil) {
        let superView = view ?? superview!
        
        if self.isDescendant(of: superView) {
        
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
            }, completion: { done in
                self.removeFromSuperview()
            })
            
        } else {
            
            alpha = 0
            reloadData()
            superView.addSubview(self)
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 1
            }) 
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OutlineProjectListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let project = projects[indexPath.item]
        let cell = OutlineProjectListCell(text: project.name, hightlight: project.id == currentID)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let project = projects[indexPath.item]
        currentID = project.id
        selectHandler?(project)
        addOrRemoveTo()
    }
}
