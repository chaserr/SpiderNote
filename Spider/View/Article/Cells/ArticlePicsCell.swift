//
//  ArticlePicsCell.swift
//  Spider
//
//  Created by ooatuoo on 16/7/7.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import SnapKit

private let commonEdge = UIEdgeInsetsMake(kArticleCellTopOffset, 0, kArticleCellBottomOffset, 0)
private let editEdge   = UIEdgeInsetsMake(kArticleVerticlSpace + 2, 0, kArticleVerticlSpace - 2, 0)

class ArticlePicsCell: ArticleBaseCell {
    var tapAction: (() -> Void)?
    
    fileprivate var beEditing = false
    fileprivate var picEdge: Constraint? = nil
    
    fileprivate var picsView: InfinitePictureView = {
        return InfinitePictureView()
    }()
    
    fileprivate var tagCountView: SectionTagCountView = {
        return SectionTagCountView()
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        picsView.addGestureRecognizer(tap)
                
        contentView.addSubview(picsView)
        picsView.addSubview(tagCountView)
        tagCountView.translatesAutoresizingMaskIntoConstraints = false
        picsView.translatesAutoresizingMaskIntoConstraints = false
        
        picsView.snp_makeConstraints { (make) in
            picEdge = make.edges.equalTo(contentView).inset(commonEdge).constraint
        }
        
        tagCountView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 20, height: 23))
            make.top.equalTo(9)
            make.right.equalTo(picsView).offset(-8)
        }
    }
    
    func didTap(_ sender: UITapGestureRecognizer) {
        tapAction?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        picsView.prepareForReuse()
    }
    
    func congfigureWithSection(_ section: SectionObject, layout: SectionLayout, editing: Bool = false) {
        super.configureSection(layout, editing: editing)

        guard let picInfos = layout.pics else { return }
        tagCountView.tagCount = section.tagCount
        picsView.update(picInfos)
        
        if beEditing != editing {
            beEditing = editing

            picEdge?.updateInsets(editing ? editEdge : commonEdge)
            tagCountView.isHidden = editing
        }
    }
    
    // 防止与侧滑冲突
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let popRect = CGRect(x: 0, y: 0, w: 30, h: bounds.height)
        
        if popRect.contains(point){
            return self
        }  else {
            return super.hitTest(point, with: event)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
