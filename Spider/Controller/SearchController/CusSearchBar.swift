//
//  CustomSearchBar.swift
//  Spider
//
//  Created by 童星 on 16/7/18.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class CusSearchBar: UISearchBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        shareInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shareInit() {
        
//        backgroundColor = RGBCOLORV(0xf0f0f0)
        placeholder = "搜索节点或长文内容"
//        showsSearchResultsButton = true
        searchResultsButtonSelected = true
        showsCancelButton = true
        let searchField = self.valueForKey("searchField") as! UITextField
        searchField.backgroundColor = UIColor.color(withHex: 0xf0f0f0)
        searchField.returnKeyType = UIReturnKeyType.Search
        setBackgroundImage(UIImage.init(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        tintColor = RGBCOLORV(0x5fb85f)
        UIBarButtonItem.appearanceWhenContainedWithin(UISearchBar).title = "取消"
//        if #available(iOS 9.0, *) {
//            UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).title = "取消"
//        }
    }

}
