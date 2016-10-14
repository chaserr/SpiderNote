//
//  LeftMenuSettingCell.swift
//  Spider
//
//  Created by 童星 on 16/7/12.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit
typealias SwitchBlock = (senderOn: Bool) -> Void
class LeftMenuSettingCell: UITableViewCell {

    var indexPath:NSIndexPath!
    
    @IBOutlet weak var cellTitle: UILabel!
    
    @IBOutlet weak var cellDetail: UIButton!
    
    @IBOutlet weak var cellSwitch: UISwitch!
    
    var switchBlock: SwitchBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    class func cellWithTableView(tableview:UITableView) -> UITableViewCell {
        
        let cellID = className
        var cell = tableview.dequeueReusableCellWithIdentifier(cellID)
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed(className, owner: nil, options: nil)!.last as! LeftMenuSettingCell
        }
        return cell!
    }
    
    func setDefaultValue(indexPath:NSIndexPath, titleArray:Array<AnyObject>, cellDetailDic:Dictionary<String, String>) -> Void {

        self.indexPath = indexPath
        let sectionOTitle:Array = (titleArray[indexPath.section]) as! Array<AnyObject>
        cellTitle.text = sectionOTitle[indexPath.row] as? String
        
        let cellDetailContent = cellDetailDic["\(indexPath.row)\(indexPath.section)"]

        switch (indexPath.section, indexPath.row) {
        case (0,0):
            cellSwitch.hidden = false
            cellSwitch.on = APP_USER.autoSync == 0 ? false : true
            cellDetail.hidden = true
        case (0,1):
            cellDetail.setTitle(APP_USER.syncrate, forState: UIControlState.Normal)
        case (0,2):
            cellSwitch.hidden = false
            cellSwitch.on = APP_USER.wifiSync == 0 ? false : true
            cellDetail.hidden = true
        case (0,3):
            cellDetail.setTitle(APP_USER.uploadPhotoSizeLiimit, forState: UIControlState.Normal)
        case (1,0):
            cellDetail.setTitle(cellDetailContent, forState: UIControlState.Normal)
        case (2,0):
            cellDetail.setTitle(VERSIONMANAGE.appLocalVersion(), forState: UIControlState.Normal)
        case (3,_):
            self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        default:
            break
        }

    }
    
    func switchBlock(block: SwitchBlock) -> Void {
        switchBlock = block
    }
    
    @IBAction func switchAction(sender: UISwitch) {
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            APP_USER.autoSync = sender.on == true ? 1 : 0
            switchBlock!(senderOn: sender.on)
        case (0,2):
            APP_USER.wifiSync = sender.on == true ? 1 : 0

        default:
            break
        }
        APP_USER.saveUserInfo()
    }

}


