//
//  SearchResultCell.swift
//  Spider
//
//  Created by 童星 on 16/7/27.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    
    @IBOutlet weak var structPath: UILabel!
    @IBOutlet weak var mindName: UILabel!
    
    class func cellWithTableView(tableview:UITableView) -> UITableViewCell {
        
        let cellID = className + "Mind"
        var cell = tableview.dequeueReusableCellWithIdentifier(cellID)
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed(className, owner: nil, options: nil)!.last as! SearchResultCell
        }
        return cell!
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
