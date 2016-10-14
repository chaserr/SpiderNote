//
//  StructLevelView.swift
//  Spider
//
//  Created by 童星 on 16/8/1.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  顶层层级结点

import UIKit
import RealmSwift

//let STRUCTMANAGER = StructLevelView.instance()

class StructLevelView: UIView, UIScrollViewDelegate {
    
    
    var onTap = {() -> Void in}
    var structIcon: UIImageView!
    var structLevelContentView: UIScrollView!
    
    var containMindArr:Array = [StructLevelItem]()
    var selectBtn:StructLevelItem!
    var titleArray:Array = [String]()
    var currentMindArray = [Object]()
    var isTriggerEvent:Bool = true

    let normalTriangleImage:UIImage       = UIImage.init(named: "struct_level4")!
    let hightLightTriangleImage:UIImage!  = UIImage.init(named: "struct_level3")!
    let normalRectangleImage:UIImage      = UIImage.init(named: "struct_level1")!
    let hightLightRectangleImage:UIImage! = UIImage.init(named: "struct_level2")!
    let unSelectLinkRectangleImage:UIImage      = UIImage.init(named: "struct_level5")!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor                                  = RGBCOLORV(0xf0f0f0)
        structIcon                                            = UIImageView.init(image: UIImage.init(named: "mind_struct_icon"))
        
        structIcon.addTapGesture { (tapGesture:UITapGestureRecognizer) in
            self.onTap()
        }
        self.addSubview(structIcon)
        structLevelContentView                                = UIScrollView()
        structLevelContentView.delegate                       = self
        structLevelContentView.contentSize                    = CGSizeMake(0, 0)
        self.addSubview(structLevelContentView)
        structLevelContentView.showsHorizontalScrollIndicator = false
        structLevelContentView.showsVerticalScrollIndicator   = false
        structLevelContentView.snp_makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(structIcon.snp_left).offset(-10)
        }
        structIcon.snp_makeConstraints { (make) in
            make.rightMargin.equalTo(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLevelBtn(titleArr:Array<String>, currentObj:Object?) -> Void {
        self.titleArray = titleArr
        
        if titleArr.count != 1 {
            
            let levelCount = (currentObj as! MindObject).structInfo.componentsSeparatedByString(" > ")
            var superMind:MindObject?            = ((currentObj as! MindObject).ownerMind.first)// 父节点
            var superProject:ProjectObject?      = ((currentObj as! MindObject).ownerProject.first)
            let currentMind = (currentObj as! MindObject)
            
            var tmpArr = [Object]()
            tmpArr.append(currentMind)
            for _ in 0..<levelCount.count {
                if superMind != nil {
                    tmpArr.append(superMind!)
                    superProject = superMind?.ownerProject.first
                    superMind = superMind!.ownerMind.first
                }else{
                
                    // 先判断父级结点是否是mind, 如果不是，那就是项目结点，否则在进行赋值
                    tmpArr.append(superProject!)
                    break
                    // 结束for循环
                }
            }
            // 数组倒序插入
            currentMindArray = Array(tmpArr.reverse())
        }else{

            currentMindArray.append(currentObj!)
        }
        var currentRowWidth:CGFloat = 0
        
        for i in 0..<titleArr.count {
            // 计算文字宽度
            let titleSize = (titleArr[i] as String).boundingRectWithSize(CGSizeMake(kScreenWidth / 2 - 38, 40), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:SYSTEMFONT(14)], context: nil)
            let button = StructLevelItem(type: UIButtonType.Custom)
            button.setTitle(titleArr[i], forState: UIControlState.Normal)
            button.frame = CGRectMake(currentRowWidth, 0, min(titleSize.width + 20, kScreenWidth / 2), 40)
            structLevelContentView.addSubview(button)
            if i <= currentMindArray.count - 1 {
                button.currenMind = currentMindArray[i] // 给每一个item绑定一个model
            }
            containMindArr.append(button)
            // 如果只有一级节点，那么只拼接尾部三角形
            if titleArr.count == 1 {
//                structIcon.hidden = true // 一级节点隐藏大纲
                // 默认最后一个结点高亮
                button.selected = true
                selectBtn = button
                let buttonFront              = StructLevelItem.init(frame: CGRectMake(button.x + button.w, 0, (normalTriangleImage.size.width), (normalTriangleImage.size.height)))
                buttonFront.setImage(normalTriangleImage, forState: UIControlState.Normal)
                buttonFront.setImage(hightLightTriangleImage, forState: UIControlState.Selected)
                buttonFront.adjustsImageWhenHighlighted = true
                structLevelContentView.addSubview(buttonFront)
                buttonFront.selected         = button.selected
                containMindArr.append(buttonFront)
                
            }
            else if i == titleArr.count - 1 {
                // 默认最后一个结点高亮
                button.selected = true
                selectBtn = button
                if currentRowWidth + button.w > kScreenWidth - 38 - 10 { // 如果当前currentRowWidth+butto.w超出了屏幕宽度，那么最后一个不再拼接
                    currentRowWidth = button.x + button.w
                }else{
                    // 如果最后一个没有超过屏幕，拼接矩形,
                    let buttonFront              = StructLevelItem.init(frame: CGRectMake(button.x - 0.1 + button.w, 0, (normalTriangleImage.size.width), (normalTriangleImage.size.height)))
                    buttonFront.setImage(hightLightTriangleImage, forState: UIControlState.Normal)
                    buttonFront.setImage(hightLightTriangleImage, forState: UIControlState.Selected)
                    buttonFront.adjustsImageWhenHighlighted = true
                    structLevelContentView.addSubview(buttonFront)
                    buttonFront.selected         = button.selected
                    currentRowWidth              = buttonFront.x + buttonFront.w
                    
                    containMindArr.append(buttonFront)
                    
                    
                }
            }
            else{ // 既不是第一个也不是最后一个\
                if i == titleArr.count - 2 { // 如果是倒第二个,需要拼接
                    
                    let buttonFront      = StructLevelItem.init(frame: CGRectMake(button.x - 0.1 + button.w, 0, (normalRectangleImage.size.width), (normalRectangleImage.size.height)))
                    buttonFront.setImage(normalRectangleImage, forState: UIControlState.Normal)
                    buttonFront.setImage(hightLightRectangleImage, forState: UIControlState.Selected)
                    buttonFront.adjustsImageWhenHighlighted = true
                    structLevelContentView.addSubview(buttonFront)
                    buttonFront.selected = button.selected
                    currentRowWidth      = buttonFront.x + buttonFront.w
                    
                    containMindArr.append(buttonFront)
                }else{
                
                    
                    let buttonFront      = StructLevelItem.init(frame: CGRectMake(button.x - 0.1 + button.w, 0, (unSelectLinkRectangleImage.size.width), (unSelectLinkRectangleImage.size.height)))
                    buttonFront.setImage(unSelectLinkRectangleImage, forState: UIControlState.Normal)
                    structLevelContentView.addSubview(buttonFront)
                    buttonFront.adjustsImageWhenHighlighted = true
                    buttonFront.selected = button.selected
                    currentRowWidth      = buttonFront.x + buttonFront.w
                    
                    containMindArr.append(buttonFront)
                }
            
            }
            
            buttonSetting(button)

        }
        
        // 更新contentSize
        structLevelContentView.contentSize = CGSizeMake(currentRowWidth, 40)

    }
    
    func buttonSetting(button:StructLevelItem) -> Void {
        button.titleLabel?.numberOfLines             = 1
        button.adjustsImageWhenHighlighted           = false
        button.setTitleColor(RGBCOLORV(0xA0A0A0), forState: UIControlState.Normal)
        button.titleLabel?.font                      = SYSTEMFONT(14)
        button.setTitleColor(RGBCOLORV(0x5fb85f), forState: UIControlState.Selected)
        button.setBackgroundColor(RGBCOLORV(0xffffff), forState: UIControlState.Selected)
        button.setBackgroundColor(RGBCOLORV(0xFAFAFA), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(btnAction), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func btnAction(sender:StructLevelItem) -> Void {
        
        if titleArray.count == 1 || SPIDERSTRUCT.selectLevelItem == sender || selectBtn == sender { // 点击自身只触发事件。
            selectBtn = sender
            SPIDERSTRUCT.selectLevelItem = sender
            if isTriggerEvent {
                
                sender.onClick(sender)
            }
            return
        }else{
        
            selectBtn.selected = !selectBtn.selected
            sender.selected = !sender.selected
        }
        // 更新UI
        updateUI(sender)
        
        // 添加事件
        selectBtn = sender
        SPIDERSTRUCT.selectLevelItem = sender
        if isTriggerEvent {
            
            sender.onClick(sender)
            
        }
    
    }
    
    func updateUI(sender:StructLevelItem) -> Void {
        
        let preSelectBtnIdx = containMindArr.indexOf(selectBtn)
        let currSelectBtnIdx = containMindArr.indexOf(sender)
        if titleArray.count == 1 {
            
            let frontBtn:UIButton = containMindArr[currSelectBtnIdx! + 1]
            frontBtn.setImage(hightLightTriangleImage, forState: UIControlState.Selected)
            frontBtn.selected = sender.selected
            
        }
        // 选中第一个，那么只修改其前面button的图片
        else if currSelectBtnIdx == 0 {
            
            let frontBtn:UIButton = containMindArr[currSelectBtnIdx! + 1]
            frontBtn.setImage(hightLightRectangleImage, forState: UIControlState.Selected)
            frontBtn.selected = sender.selected
            // 把之前选中的去掉高亮
            // 判断之前选中和现在选中是否相邻
            if abs(preSelectBtnIdx! - currSelectBtnIdx!) == 2 {
                if preSelectBtnIdx == containMindArr.count - 2 { // 判断之前选中的是最后一个，并且是否有拼接（超过屏幕的不拼接）
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.selected = sender.selected
                    frontBtn.setImage(normalTriangleImage, forState: UIControlState.Selected)
                }else if preSelectBtnIdx == containMindArr.count - 1 {
                    // 最后一个无拼接， 不作操作
                }else{
                    
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.selected = sender.selected
                    frontBtn.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                    
                }
                
            }
            else{
                
                if preSelectBtnIdx == containMindArr.count - 2 { // 判断之前选中的是最后一个，并且是否有拼接（超过屏幕的不拼接）
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.selected = sender.selected
                    frontBtn.setImage(normalTriangleImage, forState: UIControlState.Selected)
                    
                    let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                    behind.selected = sender.selected
                    behind.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                    
                }else if preSelectBtnIdx == containMindArr.count - 1 {
                    let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                    behind.selected = sender.selected
                    behind.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                }
            }
            
        }
        // 如果选中了最后一个
        else if currSelectBtnIdx == containMindArr.count - 2 || currSelectBtnIdx == containMindArr.count - 1 {
            
            if currSelectBtnIdx == containMindArr.count - 2 { // 判断当前选中的是最后一个，并且是否有拼接（超过屏幕的不拼接）
                let frontBtn:UIButton = containMindArr[currSelectBtnIdx! + 1]
                frontBtn.selected = sender.selected
                frontBtn.setImage(hightLightTriangleImage, forState: UIControlState.Selected)
                
                let behindBtn:UIButton = containMindArr[currSelectBtnIdx! - 1]
                behindBtn.selected = sender.selected
                behindBtn.setImage(normalRectangleImage, forState: UIControlState.Selected)
            }else if currSelectBtnIdx == containMindArr.count - 1 {
                let behindBtn:UIButton = containMindArr[currSelectBtnIdx! - 1]
                behindBtn.selected = sender.selected
                behindBtn.setImage(normalRectangleImage, forState: UIControlState.Selected)
            }
            
            // 判断之前选中和现在选中是否相邻
            if abs(preSelectBtnIdx! - currSelectBtnIdx!) == 2 {
                if preSelectBtnIdx == 0 { // 判断之前选中的是否是第一个
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.selected = sender.selected
                    frontBtn.setImage(normalRectangleImage, forState: UIControlState.Selected)
                }else{
                    
                    let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                    behind.selected = sender.selected
                    behind.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                }
            }
            else{
                
                if preSelectBtnIdx == 0 { // 判断之前选中的是否是第一个
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.selected = sender.selected
                    frontBtn.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                }else{
                    
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.selected = sender.selected
                    frontBtn.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                    
                    let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                    behind.selected = sender.selected
                    behind.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                }
            }
            
        }
        // 选中其他中间组件
        else {
            
            let frontBtn:UIButton = containMindArr[currSelectBtnIdx! + 1]
            frontBtn.selected = sender.selected
            frontBtn.setImage(hightLightRectangleImage, forState: UIControlState.Selected)
            
            let behindBtn:UIButton = containMindArr[currSelectBtnIdx! - 1]
            behindBtn.selected = sender.selected
            behindBtn.setImage(normalRectangleImage, forState: UIControlState.Selected)
            
            
            // 判断之前选中和现在选中是否相邻
            if abs(preSelectBtnIdx! - currSelectBtnIdx!) == 2 {
                if preSelectBtnIdx == 0 { // 判断之前选中的是否是第一个
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.selected = sender.selected
                    frontBtn.setImage(normalRectangleImage, forState: UIControlState.Selected)
                }else if preSelectBtnIdx == containMindArr.count - 2 || preSelectBtnIdx == containMindArr.count - 1 { // 判断之前选中的是否是最后一个
                    if preSelectBtnIdx == containMindArr.count - 2 {
                        let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                        frontBtn.selected = sender.selected
                        frontBtn.setImage(normalTriangleImage, forState: UIControlState.Selected)
                    }else{
                        
                    }
                }else{
                    
                    if preSelectBtnIdx > currSelectBtnIdx {
                        // 往后点
                        let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                        frontBtn.selected = sender.selected
                        frontBtn.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                    }else{
                        let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                        behind.selected = sender.selected
                        behind.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                        
                    }
                }
            }
            else{
                
                if preSelectBtnIdx == 0 { // 判断之前选中的是否是第一个
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.selected = sender.selected
                    frontBtn.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                }else if preSelectBtnIdx == containMindArr.count - 2 || preSelectBtnIdx == containMindArr.count - 1 { // 判断之前选中的是否是最后一个
                    if preSelectBtnIdx == containMindArr.count - 2 {
                        let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                        frontBtn.selected = sender.selected
                        frontBtn.setImage(normalTriangleImage, forState: UIControlState.Selected)
                        
                        let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                        behind.selected = sender.selected
                        behind.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                    }else{
                        
                        let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                        behind.selected = sender.selected
                        behind.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                        
                    }
                }else{
                    
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.selected = sender.selected
                    frontBtn.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                    let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                    behind.selected = sender.selected
                    behind.setImage(unSelectLinkRectangleImage, forState: UIControlState.Selected)
                }
            }
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if selectBtn.x + selectBtn.w > kScreenWidth - 38 - 10 {
            structLevelContentView.contentOffset.x = selectBtn.x + selectBtn.w - kScreenWidth + 38
        }
    }

}

