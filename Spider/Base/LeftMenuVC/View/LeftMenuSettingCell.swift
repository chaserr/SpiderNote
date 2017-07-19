//
//  LeftMenuSettingCell.swift
//  Spider
//
//  Created by 童星 on 16/7/12.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
typealias SwitchBlock = (_ senderOn: Bool) -> Void
class LeftMenuSettingCell: UITableViewCell {

    var indexPath:IndexPath!
    
    @IBOutlet weak var cellTitle: UILabel!
    
    @IBOutlet weak var cellDetail: UIButton!
    
    @IBOutlet weak var cellSwitch: UISwitch!
    
    var switchBlock: SwitchBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    class func cellWithTableView(_ tableview:UITableView) -> UITableViewCell {
        
        let cellID = className
        var cell = tableview.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = Bundle.main.loadNibNamed(className, owner: nil, options: nil)!.last as! LeftMenuSettingCell
        }
        return cell!
    }
    
    func setDefaultValue(_ indexPath:IndexPath, titleArray:Array<AnyObject>, cellDetailDic:Dictionary<String, String>) -> Void {

        self.indexPath = indexPath
        let sectionOTitle:Array = (titleArray[indexPath.section]) as! Array<AnyObject>
        cellTitle.text = sectionOTitle[indexPath.row] as? String
        
        let cellDetailContent = cellDetailDic["\(indexPath.row)\(indexPath.section)"]

        switch (indexPath.section, indexPath.row) {
        case (0,0):
            cellSwitch.isHidden = false
            cellSwitch.isOn = APP_USER.autoSync == 0 ? false : true
            cellDetail.isHidden = true
        case (0,1):
            cellDetail.setTitle(APP_USER.syncrate, for: UIControlState())
        case (0,2):
            cellSwitch.isHidden = false
            cellSwitch.isOn = APP_USER.wifiSync == 0 ? false : true
            cellDetail.isHidden = true
        case (0,3):
            cellDetail.setTitle(APP_USER.uploadPhotoSizeLiimit, for: UIControlState())
        case (1,0):
            cellDetail.setTitle(cellDetailContent, for: UIControlState())
        case (2,0):
            cellDetail.setTitle(VERSIONMANAGE.appLocalVersion(), for: UIControlState())
        case (3,_):
            self.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        default:
            break
        }

    }
    
    func switchBlock(_ block: @escaping SwitchBlock) -> Void {
        switchBlock = block
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            APP_USER.autoSync = sender.isOn == true ? 1 : 0
            switchBlock!(sender.isOn)
        case (0,2):
            APP_USER.wifiSync = sender.isOn == true ? 1 : 0

        default:
            break
        }
        APP_USER.saveUserInfo()
    }

}


