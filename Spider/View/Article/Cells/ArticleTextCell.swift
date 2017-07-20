//
//  ArticleBaseCell.swift
//  Spider
//
//  Created by ooatuoo on 16/7/7.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import SnapKit

private let commonEdge = UIEdgeInsetsMake(kArticleCellTopOffset, 16, kArticleCellBottomOffset, 16)
private let editEdge   = UIEdgeInsetsMake(4 + 10, 16, 10, 16)

class ArticleTextCell: ArticleBaseCell {
    var tapAction: (() -> Void)?
    
    fileprivate var contentLabelEdge: Constraint? = nil
    
    fileprivate var beEditing = false
    
    fileprivate var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = SpiderConfig.Font.Text
        label.textColor = SpiderConfig.Color.DarkText
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(contentLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        contentLabel.addGestureRecognizer(tap)
        
        contentLabel.snp.makeConstraints { (make) in
            contentLabelEdge = make.edges.equalTo(contentView).inset(commonEdge).constraint
        }
    }
    
    func didTap(_ sender: UITapGestureRecognizer) {
        tapAction?()
    }
    
    func configurationWithSection(_ section: SectionObject, layout: SectionLayout, editing: Bool) {
        super.configureSection(layout, editing: editing)
        contentLabel.text = section.text
        
        if beEditing != editing {
            beEditing = editing
            contentLabelEdge?.updateInsets(amount: editing ? editEdge : commonEdge)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
