//
//  ArticleBaseCell.swift
//  Spider
//
//  Created by ooatuoo on 16/8/4.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

private let unChooseColor = UIColor.color(withHex: 0xf0eff0)
private let choosedColor  = UIColor.color(withHex: 0x5fb85e)

class ArticleBaseCell: UITableViewCell {
    
    var addSectionHandler: (() -> Void)? {
        willSet {
            addSectionView.addSectionHandler = newValue
        }
    }
        
    private var addSectionView: AddSectionView = {
        return AddSectionView()
    }()
    
    private lazy var topSeparator: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 4))
        view.backgroundColor = SpiderConfig.Color.EditTheme
        return view
    }()
    
    private lazy var chooseView: UIView = {
        let view = UIView(frame: CGRect(x: kScreenWidth - 6 - 18, y: 4, w: 18, h: 18))
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.color(withHex: 0xf8f8f8).CGColor
        view.addSubview(self.chooseIndicator)
        return view
    }()
    
    private lazy var chooseIndicator: UIView = {
        let view = UIView(frame: CGRect(x: 4, y: 4, w: 10, h: 10))
        view.backgroundColor = unChooseColor
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        
        contentView.addSubview(addSectionView)
        addSectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSectionView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(contentView)
            make.height.equalTo(kArticlePlusHeight)
        }
    }
    
    func configureSection(layout: SectionLayout, editing: Bool) {
        
        if editing {
            
            addSectionView.hidden = true
            
            if !chooseView.isDescendantOfView(contentView) { contentView.addSubview(chooseView) }
            if !topSeparator.isDescendantOfView(contentView) { contentView.addSubview(topSeparator) }
            
            chooseIndicator.backgroundColor = layout.selected ? choosedColor : unChooseColor
            contentView.alpha = layout.selected ? 1 : 0.6
            
        } else {
            
            addSectionView.hidden = false
            chooseView.removeFromSuperview()
            topSeparator.removeFromSuperview()
            
            contentView.alpha = 1
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
