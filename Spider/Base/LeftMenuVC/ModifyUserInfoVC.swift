//
//  ModifyUserInfoVC.swift
//  Spider
//
//  Created by 童星 on 16/7/13.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class ModifyUserInfoVC: MainViewController, UITextFieldDelegate {

    @IBOutlet weak var modifyGenderView: UIView!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    
    @IBOutlet weak var maleArrow: UIImageView!
    @IBOutlet weak var femaleArrow: UIImageView!
    @IBOutlet weak var modifyTtextField: UITextField!
    
    @IBOutlet weak var modifyNicknameView: UIView!
    
    private var selectSex: String?
    enum FromViewCell{
        case nickName
        case gendle
    }
    
    var navTitle:String!
    var currentFromCell = FromViewCell.nickName
    
    var selectGender:(String) -> Void = {
    
        (gendet:String) -> Void in
    }
    var modifyNickName:(String) -> Void = {
    
        (nickName:String) -> Void in
    }
    
    
    
    init(navigationTitle:String, fromCell:String) {
        super.init()
        navTitle = navigationTitle
        currentFromCell = getFromCell(fromCell)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleLabel.text = navTitle
        
        setLeftBarButtonItem(UIBarButtonItem.init(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(backAction)))
        setRightBarButtonItem(UIBarButtonItem.init(title: "完成", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(modifyDown)))
        
        switch currentFromCell {
        case .nickName:
            modifyGenderView.hidden = true
            modifyNicknameView.hidden = false
            
        case .gendle:
            modifyNicknameView.hidden = true
            modifyGenderView.hidden = false
            maleBtn.selected = true
            
        }
    }
    
    
    
    @objc private func modifyDown() -> Void {
        
        AODlog("完成")
        let currentUsr = UserObject.fetchUserObj((APP_UTILITY.currentUser?.userID)!)
        switch currentFromCell {
        case .nickName:
            if modifyTtextField.text?.lengths > 1 {
                currentUsr!.updateUserObj({[weak self] in
                    currentUsr!.userName = self!.modifyTtextField.text!
                })
                
                backAction()
                
            }else{
            
                AOHUDVIEW.showTips("昵称不少于2个字")
            }
            
        case .gendle:
            currentUsr!.updateUserObj({[weak self] in
                currentUsr!.sex = self!.selectSex!
                })
            backAction()

        }
        
        
        
    }
    
    override func backAction() {
        AppNavigator.popViewControllerAnimated(true)
    }
    
    
    private func getFromCell(fromCell:String) -> FromViewCell {
        if fromCell == "昵称" {
            return .nickName
        }else if fromCell == "性别" {
        
            return .gendle

        }else{
        
            return .nickName

        }
    }
    
    
    @IBAction func clickMaleBtn(sender: UIButton) {
        maleArrow.hidden = false
        femaleArrow.hidden = true
        selectGender(sender.currentTitle!)
        selectSex = sender.currentTitle
    }

    @IBAction func clickFemaleBtn(sender: UIButton) {
       femaleArrow.hidden = false
        maleArrow.hidden = true
        selectGender(sender.currentTitle!)
        selectSex = sender.currentTitle

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: -- UITextFieldDelegate
extension ModifyUserInfoVC{

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == modifyTtextField {
            textField.resignFirstResponder()
            modifyDown()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {

        if textField.text?.length != 0 {
            modifyNickName(textField.text!)
        }
    }
}
