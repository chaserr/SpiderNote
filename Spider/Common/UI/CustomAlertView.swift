//
//  CustomAlertView.swift
//  Spider
//
//  Created by 童星 on 16/7/14.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  自定义弹框

import UIKit

@objc protocol AlertViewDelegate {
    
    optional func clickButtonIndex(index:Int) -> Void
}

typealias ClickButtonBlock = (index:Int, string:String) -> Void

class CustomAlertView: UIView, UITableViewDataSource, UITableViewDelegate {

    var titleArr:[String]!
    var delegate:AlertViewDelegate?
    var cellHeight:CGFloat = 50
    var clickBtnIndex:ClickButtonBlock = {
    
        (index:Int, string:String) -> Void in
    }
    
    
    private var tableview:UITableView!
    private var backView:UIView!
    init(frame: CGRect, titlesArray:Array<String>) {
        super.init(frame: frame)
        backView = UIView.init(frame: CGRectMake(50, 0, kScreenWidth - 100, kScreenHeight))
        self.addSubview(backView)
        titleArr = titlesArray
        let tableviewH:CGFloat = CGFloat(titleArr.count)
        tableview = UITableView.init(frame: CGRectMake(0, (kScreenHeight - floor(tableviewH) * 50) * 0.5, kScreenWidth - 100, tableviewH * cellHeight), style: UITableViewStyle.Plain)
        tableview.delegate = self
        tableview.dataSource = self
        backView.addSubview(tableview)
        self.tableview.alpha = 0;
        self.backView.alpha = 0;
        self.alpha = 0
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        self.frame = kScreenBounds
        setUpCellSeperatorInset()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissAlertView()
    }
    
    private func setUpCellSeperatorInset() -> Void {
        if tableview.respondsToSelector(Selector("setSeparatorInset:")) {
            tableview.separatorInset = UIEdgeInsetsZero
        }
        if tableview.respondsToSelector(Selector("setLayoutMargins:")) {
            tableview.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    private func dismissAlertView() -> Void {
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { 
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
            self.tableview.alpha = 0;
            self.alpha = 0
        }) { (finished:Bool) in
            
            self.removeFromSuperview()
        }
    }
    
    internal func show() -> Void{
    
        let currentWindow = UIApplication.sharedApplication().keyWindow
        self.backgroundColor = RGBACOLOR(0, g: 0, b: 0, a: 0.2)
        currentWindow?.addSubview(self)
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.tableview.alpha = 1.0
            self.alpha = 1.0
            self.backView.alpha = 1;
        }) { (finished:Bool) in
            
        }
        
    }
    

}

// MARK: -- tableviewDelegate
extension CustomAlertView{

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableview.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.text = titleArr[indexPath.row]
        cell?.textLabel?.textAlignment = NSTextAlignment.Center
        cell?.textLabel?.font = SYSTEMFONT(15)
        cell?.textLabel?.textColor = RGBCOLORV(0x555555)
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        if indexPath.row == titleArr.count - 1 {
            cell?.textLabel?.textColor = RGBCOLORV(0xff5f5f)
        }
        return cell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableview.deselectRowAtIndexPath(indexPath, animated: true)
        
        delegate?.clickButtonIndex!(indexPath.row)
        clickBtnIndex(index: indexPath.row, string: titleArr[indexPath.row])
        
        dismissAlertView()
    }
    
    
    
    
    
}
