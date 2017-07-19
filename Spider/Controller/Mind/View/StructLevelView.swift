//
//  StructLevelView.swift
//  Spider
//
//  Created by 童星 on 16/8/1.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  顶层层级结点

import UIKit
import RealmSwift
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
        structLevelContentView.contentSize                    = CGSize(width: 0, height: 0)
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
    
    func createLevelBtn(_ titleArr:Array<String>, currentObj:Object?) -> Void {
        self.titleArray = titleArr
        
        if titleArr.count != 1 {
            
            let levelCount = (currentObj as! MindObject).structInfo.components(separatedBy: " > ")
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
            currentMindArray = Array(tmpArr.reversed())
        }else{

            currentMindArray.append(currentObj!)
        }
        var currentRowWidth:CGFloat = 0
        
        for i in 0..<titleArr.count {
            // 计算文字宽度
            let titleSize = (titleArr[i] as String).boundingRect(with: CGSize(width: kScreenWidth / 2 - 38, height: 40), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:SYSTEMFONT(14)], context: nil)
            let button = StructLevelItem(type: UIButtonType.custom)
            button.setTitle(titleArr[i], for: UIControlState())
            button.frame = CGRect(x: currentRowWidth, y: 0, width: min(titleSize.width + 20, kScreenWidth / 2), height: 40)
            structLevelContentView.addSubview(button)
            if i <= currentMindArray.count - 1 {
                button.currenMind = currentMindArray[i] // 给每一个item绑定一个model
            }
            containMindArr.append(button)
            // 如果只有一级节点，那么只拼接尾部三角形
            if titleArr.count == 1 {
//                structIcon.hidden = true // 一级节点隐藏大纲
                // 默认最后一个结点高亮
                button.isSelected = true
                selectBtn = button
                let buttonFront              = StructLevelItem.init(frame: CGRect(x: button.x + button.w, y: 0, width: (normalTriangleImage.size.width), height: (normalTriangleImage.size.height)))
                buttonFront.setImage(normalTriangleImage, for: UIControlState())
                buttonFront.setImage(hightLightTriangleImage, for: UIControlState.selected)
                buttonFront.adjustsImageWhenHighlighted = true
                structLevelContentView.addSubview(buttonFront)
                buttonFront.isSelected         = button.isSelected
                containMindArr.append(buttonFront)
                
            }
            else if i == titleArr.count - 1 {
                // 默认最后一个结点高亮
                button.isSelected = true
                selectBtn = button
                if currentRowWidth + button.w > kScreenWidth - 38 - 10 { // 如果当前currentRowWidth+butto.w超出了屏幕宽度，那么最后一个不再拼接
                    currentRowWidth = button.x + button.w
                }else{
                    // 如果最后一个没有超过屏幕，拼接矩形,
                    let buttonFront              = StructLevelItem.init(frame: CGRect(x: button.x - 0.1 + button.w, y: 0, width: (normalTriangleImage.size.width), height: (normalTriangleImage.size.height)))
                    buttonFront.setImage(hightLightTriangleImage, for: UIControlState())
                    buttonFront.setImage(hightLightTriangleImage, for: UIControlState.selected)
                    buttonFront.adjustsImageWhenHighlighted = true
                    structLevelContentView.addSubview(buttonFront)
                    buttonFront.isSelected         = button.isSelected
                    currentRowWidth              = buttonFront.x + buttonFront.w
                    
                    containMindArr.append(buttonFront)
                    
                    
                }
            }
            else{ // 既不是第一个也不是最后一个\
                if i == titleArr.count - 2 { // 如果是倒第二个,需要拼接
                    
                    let buttonFront      = StructLevelItem.init(frame: CGRect(x: button.x - 0.1 + button.w, y: 0, width: (normalRectangleImage.size.width), height: (normalRectangleImage.size.height)))
                    buttonFront.setImage(normalRectangleImage, for: UIControlState())
                    buttonFront.setImage(hightLightRectangleImage, for: UIControlState.selected)
                    buttonFront.adjustsImageWhenHighlighted = true
                    structLevelContentView.addSubview(buttonFront)
                    buttonFront.isSelected = button.isSelected
                    currentRowWidth      = buttonFront.x + buttonFront.w
                    
                    containMindArr.append(buttonFront)
                }else{
                
                    
                    let buttonFront      = StructLevelItem.init(frame: CGRect(x: button.x - 0.1 + button.w, y: 0, width: (unSelectLinkRectangleImage.size.width), height: (unSelectLinkRectangleImage.size.height)))
                    buttonFront.setImage(unSelectLinkRectangleImage, for: UIControlState())
                    structLevelContentView.addSubview(buttonFront)
                    buttonFront.adjustsImageWhenHighlighted = true
                    buttonFront.isSelected = button.isSelected
                    currentRowWidth      = buttonFront.x + buttonFront.w
                    
                    containMindArr.append(buttonFront)
                }
            
            }
            
            buttonSetting(button)

        }
        
        // 更新contentSize
        structLevelContentView.contentSize = CGSize(width: currentRowWidth, height: 40)

    }
    
    func buttonSetting(_ button:StructLevelItem) -> Void {
        button.titleLabel?.numberOfLines             = 1
        button.adjustsImageWhenHighlighted           = false
        button.setTitleColor(RGBCOLORV(0xA0A0A0), for: UIControlState())
        button.titleLabel?.font                      = SYSTEMFONT(14)
        button.setTitleColor(RGBCOLORV(0x5fb85f), for: UIControlState.selected)
        button.setBackgroundColor(RGBCOLORV(0xffffff), forState: UIControlState.selected)
        button.setBackgroundColor(RGBCOLORV(0xFAFAFA), forState: UIControlState())
        button.addTarget(self, action: #selector(btnAction), for: UIControlEvents.touchUpInside)
    }
    
    func btnAction(_ sender:StructLevelItem) -> Void {
        
        if titleArray.count == 1 || SPIDERSTRUCT.selectLevelItem == sender || selectBtn == sender { // 点击自身只触发事件。
            selectBtn = sender
            SPIDERSTRUCT.selectLevelItem = sender
            if isTriggerEvent {
                
                sender.onClick(sender)
            }
            return
        }else{
        
            selectBtn.isSelected = !selectBtn.isSelected
            sender.isSelected = !sender.isSelected
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
    
    func updateUI(_ sender:StructLevelItem) -> Void {
        
        let preSelectBtnIdx = containMindArr.index(of: selectBtn)
        let currSelectBtnIdx = containMindArr.index(of: sender)
        if titleArray.count == 1 {
            
            let frontBtn:UIButton = containMindArr[currSelectBtnIdx! + 1]
            frontBtn.setImage(hightLightTriangleImage, for: UIControlState.selected)
            frontBtn.isSelected = sender.isSelected
            
        }
        // 选中第一个，那么只修改其前面button的图片
        else if currSelectBtnIdx == 0 {
            
            let frontBtn:UIButton = containMindArr[currSelectBtnIdx! + 1]
            frontBtn.setImage(hightLightRectangleImage, for: UIControlState.selected)
            frontBtn.isSelected = sender.isSelected
            // 把之前选中的去掉高亮
            // 判断之前选中和现在选中是否相邻
            if abs(preSelectBtnIdx! - currSelectBtnIdx!) == 2 {
                if preSelectBtnIdx == containMindArr.count - 2 { // 判断之前选中的是最后一个，并且是否有拼接（超过屏幕的不拼接）
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.isSelected = sender.isSelected
                    frontBtn.setImage(normalTriangleImage, for: UIControlState.selected)
                }else if preSelectBtnIdx == containMindArr.count - 1 {
                    // 最后一个无拼接， 不作操作
                }else{
                    
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.isSelected = sender.isSelected
                    frontBtn.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
                    
                }
                
            }
            else{
                
                if preSelectBtnIdx == containMindArr.count - 2 { // 判断之前选中的是最后一个，并且是否有拼接（超过屏幕的不拼接）
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.isSelected = sender.isSelected
                    frontBtn.setImage(normalTriangleImage, for: UIControlState.selected)
                    
                    let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                    behind.isSelected = sender.isSelected
                    behind.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
                    
                }else if preSelectBtnIdx == containMindArr.count - 1 {
                    let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                    behind.isSelected = sender.isSelected
                    behind.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
                }
            }
            
        }
        // 如果选中了最后一个
        else if currSelectBtnIdx == containMindArr.count - 2 || currSelectBtnIdx == containMindArr.count - 1 {
            
            if currSelectBtnIdx == containMindArr.count - 2 { // 判断当前选中的是最后一个，并且是否有拼接（超过屏幕的不拼接）
                let frontBtn:UIButton = containMindArr[currSelectBtnIdx! + 1]
                frontBtn.isSelected = sender.isSelected
                frontBtn.setImage(hightLightTriangleImage, for: UIControlState.selected)
                
                let behindBtn:UIButton = containMindArr[currSelectBtnIdx! - 1]
                behindBtn.isSelected = sender.isSelected
                behindBtn.setImage(normalRectangleImage, for: UIControlState.selected)
            }else if currSelectBtnIdx == containMindArr.count - 1 {
                let behindBtn:UIButton = containMindArr[currSelectBtnIdx! - 1]
                behindBtn.isSelected = sender.isSelected
                behindBtn.setImage(normalRectangleImage, for: UIControlState.selected)
            }
            
            // 判断之前选中和现在选中是否相邻
            if abs(preSelectBtnIdx! - currSelectBtnIdx!) == 2 {
                if preSelectBtnIdx == 0 { // 判断之前选中的是否是第一个
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.isSelected = sender.isSelected
                    frontBtn.setImage(normalRectangleImage, for: UIControlState.selected)
                }else{
                    
                    let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                    behind.isSelected = sender.isSelected
                    behind.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
                }
            }
            else{
                
                if preSelectBtnIdx == 0 { // 判断之前选中的是否是第一个
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.isSelected = sender.isSelected
                    frontBtn.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
                }else{
                    
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.isSelected = sender.isSelected
                    frontBtn.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
                    
                    let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                    behind.isSelected = sender.isSelected
                    behind.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
                }
            }
            
        }
        // 选中其他中间组件
        else {
            
            let frontBtn:UIButton = containMindArr[currSelectBtnIdx! + 1]
            frontBtn.isSelected = sender.isSelected
            frontBtn.setImage(hightLightRectangleImage, for: UIControlState.selected)
            
            let behindBtn:UIButton = containMindArr[currSelectBtnIdx! - 1]
            behindBtn.isSelected = sender.isSelected
            behindBtn.setImage(normalRectangleImage, for: UIControlState.selected)
            
            
            // 判断之前选中和现在选中是否相邻
            if abs(preSelectBtnIdx! - currSelectBtnIdx!) == 2 {
                if preSelectBtnIdx == 0 { // 判断之前选中的是否是第一个
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.isSelected = sender.isSelected
                    frontBtn.setImage(normalRectangleImage, for: UIControlState.selected)
                }else if preSelectBtnIdx == containMindArr.count - 2 || preSelectBtnIdx == containMindArr.count - 1 { // 判断之前选中的是否是最后一个
                    if preSelectBtnIdx == containMindArr.count - 2 {
                        let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                        frontBtn.isSelected = sender.isSelected
                        frontBtn.setImage(normalTriangleImage, for: UIControlState.selected)
                    }else{
                        
                    }
                }else{
                    
                    if preSelectBtnIdx > currSelectBtnIdx {
                        // 往后点
                        let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                        frontBtn.isSelected = sender.isSelected
                        frontBtn.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
                    }else{
                        let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                        behind.isSelected = sender.isSelected
                        behind.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
                        
                    }
                }
            }
            else{
                
                if preSelectBtnIdx == 0 { // 判断之前选中的是否是第一个
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.isSelected = sender.isSelected
                    frontBtn.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
                }else if preSelectBtnIdx == containMindArr.count - 2 || preSelectBtnIdx == containMindArr.count - 1 { // 判断之前选中的是否是最后一个
                    if preSelectBtnIdx == containMindArr.count - 2 {
                        let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                        frontBtn.isSelected = sender.isSelected
                        frontBtn.setImage(normalTriangleImage, for: UIControlState.selected)
                        
                        let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                        behind.isSelected = sender.isSelected
                        behind.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
                    }else{
                        
                        let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                        behind.isSelected = sender.isSelected
                        behind.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
                        
                    }
                }else{
                    
                    let frontBtn:UIButton = containMindArr[preSelectBtnIdx! + 1]
                    frontBtn.isSelected = sender.isSelected
                    frontBtn.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
                    let behind:UIButton = containMindArr[preSelectBtnIdx! - 1]
                    behind.isSelected = sender.isSelected
                    behind.setImage(unSelectLinkRectangleImage, for: UIControlState.selected)
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

