//
//  ArticleTitleCell.swift
//  Spider
//
//  Created by ooatuoo on 16/8/1.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class ArticleTitleCell: ArticleBaseCell {
    
    private var titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = SpiderConfig.Color.BackgroundDark
        return view
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(20)
        label.textColor = SpiderConfig.Color.LightText
        return label
    }()
    
    var sectionCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0个段落"
        label.font = UIFont.systemFontOfSize(10)
        label.textColor = SpiderConfig.Color.HintText
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        makeUI()
    }
    
    private func makeUI() {
        titleView.addSubview(titleLabel)
        titleView.addSubview(sectionCountLabel)
        contentView.addSubview(titleView)
        
        titleView.snp_makeConstraints { (make) in
            make.top.left.right.equalTo(contentView)
            make.height.equalTo(80)
        }
        
        titleLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(titleView).offset(-10)
            make.left.equalTo(16)
            make.right.equalTo(-30)
        }
        
        sectionCountLabel.snp_makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp_bottom).offset(6)
        }
    }
    
    func configureTitleCell(name: String, sectionCount: Int) {
        titleLabel.text = name
        sectionCountLabel.text = "\(sectionCount)个段落"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
