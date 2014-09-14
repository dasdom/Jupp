//
//  TableViewProtocol.swift
//  GlobalADN
//
//  Created by dasdom on 21.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit

@objc protocol TableViewProtocol: UITableViewDelegate, UITableViewDataSource {
    func registerCellsAndSetTableView(theTableView: UITableView)
    func fetchData(sender: AnyObject?)
}
