//
//  AboutMeCell.swift
//  Spider
//
//  Created by 童星 on 16/7/14.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class AboutMeCell: UITableViewCell {

    @IBOutlet weak var cellTitle:UILabel!
    @IBOutlet weak var cellDetail:UILabel!
    @IBOutlet weak var disclaimerBtn:UIButton!
    @IBOutlet weak var PrivacyPolicyBtn:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code


    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func cellWithTableView(_ tableview:UITableView, indexPath:IndexPath) -> UITableViewCell {
        var identifier = ""
        var index = 0
        
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            identifier = className + "First"
            index = 0
        case (1, _), (2, _):
            identifier = className + "Second"
            index = 1

        case (3, _):
            identifier = className + "Third"
            index = 2

        default:
            break
        }
        
        var cell = tableview.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = Bundle.main.loadNibNamed(className, owner: nil, options: nil)![index] as! AboutMeCell
        }
        return cell!
    }
    
    func setDefaultValue(_ indexPath:IndexPath, titleArray:Array<AnyObject>) -> Void {
        
        let sectionOTitle:Array = (titleArray[indexPath.section]) as! Array<AnyObject>
        
        switch (indexPath.section, indexPath.row) {
        case (1,0):
            cellTitle.text = sectionOTitle[indexPath.row] as? String
            cellDetail.text = "蜘蛛笔记"
        case (1,1):
            cellTitle.text = sectionOTitle[indexPath.row] as? String
            cellDetail.text = "spider note"
        case (1,2):
            cellTitle.text = sectionOTitle[indexPath.row] as? String
            cellDetail.text = "6548945"
        case (2,0):
            cellTitle.text = sectionOTitle[indexPath.row] as? String
            cellDetail.text = "025-46578041"
        case (2,1):
            cellTitle.text = sectionOTitle[indexPath.row] as? String
            cellDetail.text = "business@zznote.com"
//        case (3, _):
//            disclaimerBtn.layer.borderWidth = 1
//            disclaimerBtn.layer.borderColor = UIColor.blackColor().CGColor
//            PrivacyPolicyBtn.layer.borderWidth = 1
//            PrivacyPolicyBtn.layer.borderColor = UIColor.blackColor().CGColor
        default:
            break
        }
        
    }
    
}
