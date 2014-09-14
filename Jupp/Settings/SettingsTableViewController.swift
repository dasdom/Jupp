//
//  SettingsTableViewController.swift
//  Jupp
//
//  Created by dasdom on 06.09.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit
import Accounts

let kActiveAccountIdKey = "kActiveAccountIdKey"

class SettingsTableViewController: UITableViewController {

    var accountStore: ACAccountStore?
    var accounts: [AnyObject]?
    var activeAccountId: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        accountStore = ACAccountStore()
        let accountType = accountStore!.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        println("accountType: \(accountType)")
        
        accountStore!.requestAccessToAccountsWithType(accountType, options: nil, completion: { [unowned self] (granted, error) in
            println("granted: \(granted)")
            self.accounts = self.accountStore?.accounts
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        })
        
        activeAccountId = NSUserDefaults.standardUserDefaults().stringForKey(kActiveAccountIdKey)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return accounts?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("twitterAccountCell", forIndexPath: indexPath) as UITableViewCell

        let account = accounts![indexPath.row] as ACAccount
        cell.textLabel?.text = account.username
        
        if activeAccountId == account.identifier {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let account = accounts![indexPath.row] as ACAccount
        if activeAccountId == account.identifier {
            activeAccountId = nil
        } else {
            activeAccountId = account.identifier
        }
        NSUserDefaults.standardUserDefaults().setObject(activeAccountId, forKey: kActiveAccountIdKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        tableView.reloadData()
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
