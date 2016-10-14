//
//  BaseTableViewController.swift
//  Spider
//
//  Created by 童星 on 16/7/11.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

class BaseTableViewController: MainViewController , UITableViewDelegate, UITableViewDataSource {

    
    var tableView:UITableView!
    var tableViewStyle:UITableViewStyle!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override init() {
        super.init()
        tableViewStyle = UITableViewStyle.Plain
    }
    
    init(style:UITableViewStyle) {
        super.init()
        tableViewStyle = style
    }
    
    override func loadView() {
        super.loadView()
        let bounds = view.bounds
        let tableRect:CGRect!
        let viewController = self.parentViewController
        if viewController != nil && viewController?.isKindOfClass(UINavigationController) == true {
            tableRect = CGRectMake(0, 0, bounds.size.width, bounds.size.height);

        }else{
        
            tableRect = CGRectMake(0, 64, bounds.size.width, bounds.size.height);

        }
        
        tableView = UITableView.init(frame: tableRect, style: tableViewStyle)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.showsVerticalScrollIndicator = false
        tableView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        tableView.tableFooterView = UIView()
//        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        view.addSubview(tableView)
        
        let tableHeaderRect:CGRect = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 0.01);
        
        self.tableView.tableHeaderView = UIView.init(frame: tableHeaderRect);
        self.edgesForExtendedLayout = UIRectEdge.None;
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setEditing(false, animated: animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if tableView != nil {
            let indexPath:NSIndexPath? = tableView.indexPathForSelectedRow
            if indexPath != nil {
            tableView.deselectRowAtIndexPath(indexPath!, animated: true)
            }
        }
    }
    
    func reloadData() -> Void {
        tableView.reloadData()
    }
    
    
// MARK: --TableView DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
        
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
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
