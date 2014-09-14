//
//  TimeLineViewController.swift
//  GlobalADN
//
//  Created by dasdom on 17.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit

class TimeLineViewController: UITableViewController {
    @IBOutlet var dataSource: TimeLineDataSource?
    
//    init(tableViewDataSource aDataSource: TimeLineDataSource) {
//        
//        dataSource = aDataSource
//        
//        super.init(nibName: nil, bundle: nil)
//    }
   
    required init(coder aDecoder: NSCoder) {
//        self.init(tableViewDataSource: TimeLineDataSource())
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theRefreshControl = UIRefreshControl()
        theRefreshControl.addTarget(dataSource, action: "fetchData:", forControlEvents: .ValueChanged)
        refreshControl = theRefreshControl
        
        tableView.delegate = dataSource as? UITableViewDelegate
        tableView.dataSource = dataSource as? UITableViewDataSource
        dataSource?.registerCellsAndSetTableView(tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
//        dataSource?.postsArray = [Post]()
        dataSource?.fetchData(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func replyToPost(post: Post) {
        let navigationController = UIStoryboard(name: "Post", bundle: nil).instantiateInitialViewController() as UINavigationController
        let postViewController = navigationController.viewControllers.first as PostViewController
        postViewController.replyToPost = post
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
}
