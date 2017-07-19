//
//  CustomSearchBar.swift
//  Spider
//
//  Created by Atuooo on 5/11/16.
//  Copyright © 2016 oOatuo. All rights reserved.
//

import UIKit

class CustomSearchBar: UISearchBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = frame.height * 0.2
        layer.masksToBounds = true
        
        placeholder = "搜索"
        
        let searchField = self.value(forKey: "searchField") as! UITextField
        searchField.backgroundColor = UIColor.color(withHex: 0xf0f0f0)
        
        setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, w: kScreenWidth, h: 30))
        
        layer.cornerRadius = 0
        layer.masksToBounds = true
        
        placeholder = "搜索"
        
        let searchField = self.value(forKey: "searchField") as! UITextField
        searchField.backgroundColor = UIColor.color(withHex: 0xf0f0f0)
        
        setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
