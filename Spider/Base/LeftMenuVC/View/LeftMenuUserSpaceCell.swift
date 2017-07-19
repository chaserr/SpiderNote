//
//  LeftMenuUserSpaceCell.swift
//  Spider
//
//  Created by 童星 on 16/7/13.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class LeftMenuUserSpaceCell: UITableViewCell {

   
    
    @IBOutlet weak var nickNameLabel: UILabel!
    
    @IBOutlet weak var cellTitle: UILabel!
    
    @IBOutlet weak var cellDetail: UIButton!
    
    @IBOutlet weak var cellArrow: UIButton!
    /** 流量使用情况*/
    @IBOutlet weak var cellSubTitle: UILabel!
    /** 流量使用情况*/
    @IBOutlet weak var cellSubTitleDetail: UILabel!
    
    @IBOutlet weak var cellStoreProgress:UIView!
    
    var userData: UserObject?
    
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
            cell = Bundle.main.loadNibNamed(className, owner: nil, options: nil)!.first as! LeftMenuUserSpaceCell
        }
        return cell!
    }
    
    class func flowCellWithTableView(_ tableview:UITableView) -> UITableViewCell {
        
        let cellID = "flow" + className
        var cell = tableview.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = Bundle.main.loadNibNamed(className, owner: nil, options: nil)!.last as! LeftMenuUserSpaceCell

        }
        return cell!
    }
    
    
    func setDefaultValue(_ indexPath:IndexPath, titleArray:Array<AnyObject>) -> Void {
        
        let userObj = UserObject.fetchUserObj((APP_UTILITY.currentUser?.userID)!)
        
        let sectionOTitle:Array = (titleArray[indexPath.section]) as! Array<AnyObject>
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            if userObj!.userPortrial != nil {
                cellDetail.setImage(userObj!.userPortrial!, for: UIControlState())

            }else{
            
                cellDetail.setImage(UIImage.init(named: "default_protrial_square"), for: UIControlState())

            }
            cellTitle.text = sectionOTitle[indexPath.row] as? String
        case (0,1):
            
            nickNameLabel.text = userObj!.userName
            nickNameLabel.isHidden = false
            cellTitle.text = sectionOTitle[indexPath.row] as? String
        case (0,2):
            cellDetail.setTitle(userObj!.sex, for: UIControlState())
            cellTitle.text = sectionOTitle[indexPath.row] as? String
        case (1,0):
            cellTitle.text = sectionOTitle[indexPath.row] as? String
        case (2,0):
            cellSubTitle.text = sectionOTitle[indexPath.row] as? String
        case (2,1):
            cellSubTitle.text = sectionOTitle[indexPath.row] as? String
        default:
            break
        }
        
    }
    
    
}
