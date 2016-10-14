//
//  MindViewCell.swift
//  Spider
//
//  Created by ooatuoo on 16/7/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
import SnapKit

private let mindReuseID = "MindTableViewCell_Submind"
private let articleReuseID = "MindTableViewCell_Article"

//private let mindType = MindType.Mind.rawValue
//private let articleType = MindType.Article.rawValue

private let unChooseColor = UIColor.color(withHex: 0xf0eff0)
private let choosedColor  = UIColor.color(withHex: 0x5fb85e)

final class MindViewCell: UITableViewCell {
    
    var foldHandler: (() -> Void)?
    var unfoldHandler: (() -> Void)?
    var editHandler: (() -> Void)?
    
    private var isFirst = false
    private var info: MindUIInfo!
    private var folding = true
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SpiderConfig.Font.Text
        label.textColor = UIColor.color(withHex: 0x222222)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: self.info.type == .Mind ? "mind_submind_icon" : "mind_article_icon")
        return imageView
    }()
    
    private lazy var sepatator: MindSeparatorView = {
        let view = MindSeparatorView(foldable: self.info.foldable)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(named: self.info.type == .Mind ? "mind_edit_mind" : "mind_edit_article"), forState: .Normal)
        return button
    }()
    
    private lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    private lazy var chooseView: UIView = {
        let view = UIView(frame: CGRect(x: kScreenWidth - 28, y: 0, w: 18, h: 18))
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.color(withHex: 0xf8f8f8).CGColor
        return view
    }()
    
    private lazy var chooseIndicator: UIView = {
        let view = UIView(frame: CGRect(x: 4, y: 4, w: 10, h: 10))
        view.backgroundColor = unChooseColor
        return view
    }()
    
    init(info: MindUIInfo, isFirst: Bool = false, editing: Bool = false) {
        super.init(style: .Default, reuseIdentifier: info.type == .Mind ? mindReuseID : articleReuseID)
        self.isFirst = isFirst
        self.info = info
        
        contentLabel.text = info.name
        selectionStyle = .None
        
        if editing {
            
            makeEditUI()
            editButton.addTarget(self, action: #selector(editButtonClicked), forControlEvents: .TouchUpInside)
            
        } else {
            
            makeUI()
            folding = info.folding
            
            sepatator.foldButtonHandler = { [weak self] in
                
                if let weakSelf = self {
                    
                    if weakSelf.folding {
                        weakSelf.unfoldHandler?()
                    } else {
                        weakSelf.foldHandler?()
                    }
                    
                    weakSelf.folding = !weakSelf.folding
                    
                    weakSelf.contentLabel.snp_updateConstraints{ (make) in
                        
                        if weakSelf.folding {
                            make.height.equalTo(kMindTextLabelMinHeight)
                        } else {
                            make.height.equalTo(info.labelHeight)
                        }
                    }
                    
                }
            }
        }
    }
    
    func hightlight() {
        container.backgroundColor = UIColor.color(withHex: 0xf5f5f5)
    }
    
    func unHighlight() {
        container.backgroundColor = UIColor.whiteColor()
    }
    
    func editButtonClicked() {
        editHandler?()
    }

    func makeUI() {
        backgroundColor = UIColor.whiteColor()
        
        addSubview(iconView)
        addSubview(contentLabel)
        addSubview(sepatator)
                
        iconView.snp_makeConstraints { (make) in
            make.size.equalTo(kMindIconViewSize)
            make.left.equalTo(kMindInteritemSpacing)
            if isFirst {
                make.centerY.equalTo(self).offset(-kMindVerticalSpacing/2)
            } else {
                 make.centerY.equalTo(self).offset(-kMindVerticalSpacing)
            }
        }
        
        contentLabel.snp_makeConstraints { (make) in
            make.height.equalTo(info.folding ? kMindTextLabelMinHeight : info.labelHeight)
            make.left.equalTo(iconView.snp_right).offset(kMindInteritemSpacing)
            make.right.equalTo(-kMindInteritemSpacing)
            
            if isFirst {
                make.top.equalTo(self.snp_top).offset(6+kMindVerticalSpacing)
            } else {
                make.top.equalTo(self.snp_top).offset(6)
            }
        }
        
        sepatator.snp_makeConstraints { (make) in
            make.height.equalTo(kMindSeparatorHeight)
            make.centerX.equalTo(self)
            make.width.bottom.equalTo(self)
        }
    }
    
    func makeEditUI() {
        backgroundColor = UIColor.color(withHex: 0xeaeaea)
        contentLabel.textColor = UIColor.color(withHex: 0xaaaaaa)
        
        if info.choosed {
            chooseIndicator.backgroundColor = choosedColor
            contentLabel.textColor = UIColor.color(withHex: 0x222222)
        } else {
            chooseIndicator.backgroundColor = unChooseColor
            contentLabel.textColor = UIColor.color(withHex: 0xaaaaaa)
        }
        
        chooseView.addSubview(chooseIndicator)
        container.addSubview(chooseView)
        container.addSubview(iconView)
        container.addSubview(contentLabel)
        container.addSubview(editButton)
        addSubview(container)

        container.snp_makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5))
        }
        
        iconView.snp_makeConstraints { (make) in
            make.size.equalTo(kMindIconViewSize)
            make.left.equalTo(kMindInteritemSpacing - 5)
            make.top.equalTo(20)
        }
        
        editButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 20))
            make.centerX.equalTo(iconView)
            make.top.equalTo(iconView.snp_bottom).offset(5)
        }
        
        contentLabel.snp_makeConstraints { (make) in
            make.left.equalTo(iconView.snp_right).offset(kMindInteritemSpacing)
            make.right.equalTo(-kMindInteritemSpacing)
            make.height.equalTo(kMindTextLabelMinHeight)
            make.centerY.equalTo(container)
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
