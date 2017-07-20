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
        tableViewStyle = UITableViewStyle.plain
    }
    
    init(style:UITableViewStyle) {
        super.init()
        tableViewStyle = style
    }
    
    override func loadView() {
        super.loadView()
        let bounds = view.bounds
        let tableRect:CGRect!
        let viewController = self.parent
        if viewController != nil && viewController?.isKind(of: UINavigationController.self) == true {
            tableRect = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height);

        }else{
        
            tableRect = CGRect(x: 0, y: 64, width: bounds.size.width, height: bounds.size.height);

        }
        
        tableView = UITableView.init(frame: tableRect, style: tableViewStyle)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.white
        tableView.showsVerticalScrollIndicator = false
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.tableFooterView = UIView()
//        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        view.addSubview(tableView)
        
        let tableHeaderRect:CGRect = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 0.01);
        
        self.tableView.tableHeaderView = UIView.init(frame: tableHeaderRect);
        self.edgesForExtendedLayout = UIRectEdge();
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setEditing(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if tableView != nil {
            let indexPath:IndexPath? = tableView.indexPathForSelectedRow
            if indexPath != nil {
            tableView.deselectRow(at: indexPath!, animated: true)
            }
        }
    }
    
    func reloadData() -> Void {
        tableView.reloadData()
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

extension BaseTableViewController{

    // MARK: --TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }

    
}
