//
//  SettingsTableViewController.swift
//  Jupp
//
//  Created by dasdom on 06.09.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit
import Accounts

let kActiveTwitterAccountIdKey = "kActiveTwitterAccountIdKey"
let kActiveFacebookAccountIdKey = "kActiveFacebookAccountIdKey"

class SettingsTableViewController: UITableViewController {
  
  var accountStore: ACAccountStore?
  var twitterAccounts: [AnyObject]?
  var facebookAccounts: [AnyObject]?
  var activeTwitterAccountId: String?
  var activeFacebookAccountId: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    accountStore = ACAccountStore()
    let accountType = accountStore!.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    
    print("accountType: \(accountType)")
    
    accountStore!.requestAccessToAccountsWithType(accountType, options: nil, completion: { [unowned self] (granted, error) in
      print("granted: \(granted)")
      self.twitterAccounts = self.accountStore?.accounts
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.tableView.reloadData()
      })
      })
    
//    accountType = accountStore!.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
//    
//    println("accountType: \(accountType)")
//    
//    accountStore!.requestAccessToAccountsWithType(accountType, options: nil, completion: { [unowned self] (granted, error) in
//      println("granted: \(granted)")
//      self.facebookAccounts = self.accountStore?.accounts
//      dispatch_async(dispatch_get_main_queue(), { () -> Void in
//        self.tableView.reloadData()
//      })
//      })
    
    activeTwitterAccountId = NSUserDefaults.standardUserDefaults().stringForKey(kActiveTwitterAccountIdKey)
//    activeFacebookAccountId = NSUserDefaults.standardUserDefaults().stringForKey(kActiveFacebookAccountIdKey)
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
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return twitterAccounts?.count ?? 0
    } else {
      return facebookAccounts?.count ?? 0
    }
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("twitterAccountCell", forIndexPath: indexPath) 
    
    let account = twitterAccounts![indexPath.row] as! ACAccount
    cell.textLabel!.text = account.username
    
    if activeTwitterAccountId == account.identifier {
      cell.accessoryType = .Checkmark
    } else {
      cell.accessoryType = .None
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let account = twitterAccounts![indexPath.row] as! ACAccount
    if activeTwitterAccountId == account.identifier {
      activeTwitterAccountId = nil
    } else {
      activeTwitterAccountId = account.identifier
    }
    NSUserDefaults.standardUserDefaults().setObject(activeTwitterAccountId, forKey: kActiveTwitterAccountIdKey)
    NSUserDefaults.standardUserDefaults().synchronize()
    tableView.reloadData()
  }
  
  @IBAction func done(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}
