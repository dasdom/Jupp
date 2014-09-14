//
//  TimeLineDataSource.swift
//  GlobalADN
//
//  Created by dasdom on 21.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit

let PostCellIdentifier = "PostCellIdentifier"

class TimeLineDataSource : NSObject, TableViewProtocol, UIGestureRecognizerDelegate {
    
    @IBOutlet var viewController: TimeLineViewController?
    var tableView: UITableView?
    var postsArray = [Post]()
    var sinceId: Int?
    var beforeId: Int?
    
//    var panGestureRecogniser: UIPanGestureRecognizer?
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        panGestureRecogniser = UIPanGestureRecognizer(target: self, action: "panCell:")
//    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PostCellIdentifier, forIndexPath: indexPath) as PostCell
        
        let post = postsArray[indexPath.row]
        
        cell.usernameLabel.text = post.user.username
                
        cell.postTextView.scrollEnabled = true
        cell.postTextView.attributedText = post.attributedText
        cell.postTextView.invalidateIntrinsicContentSize()
        cell.postTextView.scrollEnabled = false
        
        cell.panGestureRecogniser.delegate = self
        cell.panGestureRecogniser.addTarget(self, action: "panCell:")
        
        cell.avatarURL = post.user.avatarURL
        
        return cell
    }
    
//    func tableView(tableView: UITableView!, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
//        let post = postsArray[indexPath.row]
//        let textViewWidth = tableView.frame.size.width - 65.0
//        let height = floor(post.attributedText.heightForWidth(textViewWidth)) + 45.0
//        return height
//    }
//    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = postsArray[indexPath.row]
        let textViewWidth = tableView.frame.size.width - 70.0
        let height = post.attributedText.heightForWidth(textViewWidth) + 45.0
        return height
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        println("contentOffset: \(tableView.contentOffset), cellOrigin: \(cell.frame.origin)")
//    
//        let contentOffset = tableView.contentOffset
//        let cellFrame = cell.frame
//        if cellFrame.origin.y < contentOffset.y {
//            let correctedOffset = CGPointMake(0.0, tableView.contentOffset.y - cell.frame.size.height)
//            println("correctedOffset: \(correctedOffset)")
//            tableView.setContentOffset(correctedOffset, animated: true)
//        }
//    }
    
    func registerCellsAndSetTableView(theTableView: UITableView) {
        theTableView.registerClass(PostCell.self, forCellReuseIdentifier: PostCellIdentifier)
        tableView = theTableView
//        tableView?.addGestureRecognizer(panGestureRecogniser!)
    }

    func fetchData(sender: AnyObject?) {
//        assert(tableView, "At this point a tableView has to be assigned")
        
        var indexPath:NSIndexPath?
        var oldYOffsetOfCell: CGFloat = 0
        var contentOffsetY: CGFloat = 0
//        var contentHeight: CGFloat = 0
        if tableView!.numberOfRowsInSection(0) > 0 {
            let cell = tableView!.visibleCells()[0] as PostCell
            oldYOffsetOfCell = cell.frame.origin.y
            indexPath = tableView!.indexPathsForVisibleRows()![0] as? NSIndexPath
//            contentHeight = tableView!.contentSize.height
            contentOffsetY = tableView!.contentOffset.y
            println("contentOffsetY: \(contentOffsetY)")
        }
        APICommunicator.fetchMentionsBefore(nil, sinceId: sinceId) { (array, meta, error) in
            if error != nil {
                println("Error: \(error)")
            } else {
                if self.postsArray.count < 1 {
                    self.postsArray = array!
                } else {
                    self.postsArray.replaceRange(Range(start: 0, end: 0), with: array!)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView!.reloadData()
                    
                    if let theIndexPath = indexPath {
                        println("****************************************************************")
                        var newIndexPath = NSIndexPath(forRow: theIndexPath.row + array!.count, inSection: 0)
                        println("contentOffset: \(self.tableView?.contentOffset)")
                        self.tableView?.scrollToRowAtIndexPath(newIndexPath, atScrollPosition: .Top, animated: false)
                        println("contentOffset: \(self.tableView?.contentOffset)")
                        println("****************************************************************")
                        println("newIndexPath: \(newIndexPath)")
                        println("tableView!.indexPathsForVisibleRows() \(self.tableView!.indexPathsForVisibleRows())")
                        let theCell = self.tableView!.cellForRowAtIndexPath(newIndexPath)
                        println("****************************************************************")
                        println("number or rows: \(self.tableView?.numberOfRowsInSection(0))")
                        println("array.count: \(array?.count)")
                        println("theCell \(theCell)")
                        let newYOffsetOfCell = theCell?.frame.origin.y
                        println("old: \(oldYOffsetOfCell) new: \(newYOffsetOfCell)")
                    

                        if let newYOffsetOfCell = newYOffsetOfCell {
                            let yDiff = newYOffsetOfCell-oldYOffsetOfCell
                            println("yDiff: \(yDiff)")
                            self.tableView!.setContentOffset(CGPointMake(0.0, yDiff+contentOffsetY), animated: false)
                        } else {
                            println("break here")
                        }
                    }
                    
//                    let newContentHeight = self.tableView!.contentSize.height
//
//                    let yDiff = newContentHeight-contentHeight
//                    println("contentHeight: \(contentHeight), newContentHeight: \(newContentHeight)")
//                    self.tableView!.setContentOffset(CGPointMake(0.0, yDiff+contentOffsetY), animated: false)
                    
                    if let more = meta?.more {
                        self.sinceId = meta?.maxId
                    }
                    println("sinceId: \(self.sinceId)")
                    if let refreshControl = sender as? UIRefreshControl {
                        refreshControl.endRefreshing()
                    }
                    })
            }
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
        let translation = (gestureRecognizer as UIPanGestureRecognizer).translationInView(gestureRecognizer.view!.superview!)
        return abs(translation.x) > abs(translation.y)
    }
    
    func panCell(gestureRecogniser: UIPanGestureRecognizer) {
       
        let contentView = gestureRecogniser.view!.superview!
        let point = contentView.convertPoint(contentView.center, toView: tableView)
        let indexPath = tableView?.indexPathForRowAtPoint(point)
        
        let cell = tableView?.cellForRowAtIndexPath(indexPath!) as PostCell

        let translation = gestureRecogniser.translationInView(gestureRecogniser.view!.superview!)

        if gestureRecogniser.state == .Ended {
            println("ended")
            
            if let indexPath = indexPath {
                let post = postsArray[indexPath.row]
                
                if translation.x > -40 {
                    println("no action")
                } else if translation.x > -70 {
                    println("answer \(post.id)")
                    viewController?.replyToPost(post)
                } else if translation.x > -100 {
                    println("repost \(post.id)")
                    APICommunicator.repostPostWithId(post.id) { (error) in
                        println("error: \(error)")
                    }
                }
            }
            cell.hostViewCenterXConstraint?.constant = 0.0
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: nil, animations: { () in
                cell.layoutIfNeeded()
            }, completion: { (finished) in
                
            })
        } else {
            cell.hostViewCenterXConstraint?.constant = translation.x
            if translation.x > -40 {
//                cell.actionLabel.text = ""
                cell.actionImageView.image = nil
            } else if translation.x > -70 {
//                cell.actionLabel.text = "a"
                cell.actionImageView.image = UIImage(named: "reply")
            } else if translation.x > -100 {
//                cell.actionLabel.text = "r"
                cell.actionImageView.image = UIImage(named: "repost")
            }
        }
    }
}
