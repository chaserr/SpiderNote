//
//  CustomAlertView.swift
//  Spider
//
//  Created by 童星 on 16/7/14.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  自定义弹框

import UIKit

@objc protocol AlertViewDelegate {
    
    @objc optional func clickButtonIndex(_ index:Int) -> Void
}

typealias ClickButtonBlock = (_ index:Int, _ string:String) -> Void

class CustomAlertView: UIView, UITableViewDataSource, UITableViewDelegate {

    var titleArr:[String]!
    var delegate:AlertViewDelegate?
    var cellHeight:CGFloat = 50
    var clickBtnIndex:ClickButtonBlock = {
    
        (index:Int, string:String) -> Void in
    }
    
    
    fileprivate var tableview:UITableView!
    fileprivate var backView:UIView!
    init(frame: CGRect, titlesArray:Array<String>) {
        super.init(frame: frame)
        backView = UIView.init(frame: CGRect(x: 50, y: 0, width: kScreenWidth - 100, height: kScreenHeight))
        self.addSubview(backView)
        titleArr = titlesArray
        let tableviewH:CGFloat = CGFloat(titleArr.count)
        tableview = UITableView.init(frame: CGRect(x: 0, y: (kScreenHeight - floor(tableviewH) * 50) * 0.5, width: kScreenWidth - 100, height: tableviewH * cellHeight), style: UITableViewStyle.plain)
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
    
    override func willMove(toSuperview newSuperview: UIView?) {
        self.frame = kScreenBounds
        setUpCellSeperatorInset()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissAlertView()
    }
    
    fileprivate func setUpCellSeperatorInset() -> Void {
        if tableview.responds(to: Selector("setSeparatorInset:")) {
            tableview.separatorInset = UIEdgeInsets.zero
        }
        if tableview.responds(to: Selector("setLayoutMargins:")) {
            tableview.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    fileprivate func dismissAlertView() -> Void {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { 
            UIView.setAnimationCurve(UIViewAnimationCurve.easeInOut)
            self.tableview.alpha = 0;
            self.alpha = 0
        }) { (finished:Bool) in
            
            self.removeFromSuperview()
        }
    }
    
    internal func show() -> Void{
    
        let currentWindow = UIApplication.shared.keyWindow
        self.backgroundColor = RGBACOLOR(0, g: 0, b: 0, a: 0.2)
        currentWindow?.addSubview(self)
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.tableview.alpha = 1.0
            self.alpha = 1.0
            self.backView.alpha = 1;
        }) { (finished:Bool) in
            
        }
        
    }
    

}

// MARK: -- tableviewDelegate
extension CustomAlertView{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsets.zero
        }
        if cell.responds(to: Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableview.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.text = titleArr[indexPath.row]
        cell?.textLabel?.textAlignment = NSTextAlignment.center
        cell?.textLabel?.font = SYSTEMFONT(15)
        cell?.textLabel?.textColor = RGBCOLORV(0x555555)
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        if indexPath.row == titleArr.count - 1 {
            cell?.textLabel?.textColor = RGBCOLORV(0xff5f5f)
        }
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        
        delegate?.clickButtonIndex!(indexPath.row)
        clickBtnIndex(indexPath.row, titleArr[indexPath.row])
        
        dismissAlertView()
    }
    
    
    
    
    
}
