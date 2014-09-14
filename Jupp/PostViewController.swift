//
//  PostViewController.swift
//  Jupp
//
//  Created by dasdom on 09.08.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit
import PostToADN
import KeychainAccess
import Accounts
import Social

class PostViewController: UIViewController, UITextViewDelegate {
    
    var accessToken: String?
    var accountStore: ACAccountStore?
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var sendActivityIndicator: UIActivityIndicatorView!
    
    var isPosting = false
    
    var replyToPost: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var buttonTitle = "Post"
        if let accountIdentifier = NSUserDefaults.standardUserDefaults().stringForKey(kActiveAccountIdKey) {
            buttonTitle = "Crosspost"
        }
        let postButton = UIBarButtonItem(title: buttonTitle, style: UIBarButtonItemStyle.Plain, target: self, action: "post:")
        
        navigationItem.rightBarButtonItem = postButton
        
        if replyToPost != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel:")
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        if let replyToPost = replyToPost {
            postTextView.text = "@\(replyToPost.user.username) "
        }
        
        accessToken = KeychainAccess.passwordForAccount("AccessToken")
        if accessToken == nil || accessToken == "" {
            performSegueWithIdentifier("ShowLoginViewController", sender: self)
            return
        }
        
        postTextView.becomeFirstResponder()
        updateCharacterCount()
        
        accountStore = ACAccountStore()

    }
    
    @IBAction func post(sender: AnyObject) {
        
//        var button = UIButton()
//        button.setTitle("title", forState: .Normal)
        var errorMessage: String?
        if postTextView.text.utf16Count < 1 {
            errorMessage = NSLocalizedString("A post should have at least one character.", comment: "Empty post alert message")
        } else if postTextView.text.utf16Count > 256 {
            errorMessage = NSLocalizedString("A post cannot have more than 256 characters.", comment: "To many characters alert message")
        }
        
        if errorMessage != nil {
            let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error message title"), message: errorMessage, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Ok button title"), style: .Default, handler: nil)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        let linkExtractor = LinkExtractor()
        let (postText, linksArray) = linkExtractor.extractLinks(postTextView.text)
        let request = RequestFactory.postRequestFromPostText(postText, linksArray: linksArray, accessToken: accessToken!, replyTo: replyToPost?.id)
        
//        var tweetText = postText
//        for linkDict in linksArray {
//            let url = linkDict["url"]
//            tweetText = tweetText + " \(url!)"
//        }
//        println("tweetText: \(tweetText)")
//        println("request: \(request)")
        
        if isPosting {
            return
        }
        isPosting = true

        sendActivityIndicator.startAnimating()
        let session = NSURLSession.sharedSession()
        let sessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            
//            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
//            
//            println("responseString \(responseString)")
//            println("response: \(response)")
//            println("error: \(error)")
            let responseDict  = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as [String:AnyObject]
            println("responseDict: \(responseDict)")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.sendActivityIndicator.stopAnimating()
                })
            
            if self.replyToPost != nil {
                self.dismissViewControllerAnimated(true, completion: nil)
                self.isPosting = false
                return
            }
            if linksArray.count > 0 {
                dispatch_async(dispatch_get_main_queue(), {
                    self.resetTextView()
                    })
                return
            }
            
            if let accountIdentifier = NSUserDefaults.standardUserDefaults().stringForKey(kActiveAccountIdKey) {
                
                self.tweetText(postText, linksArray: linksArray, accountIdentifier: accountIdentifier, completion: {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.resetTextView()
                    })
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.resetTextView()
                })
            }
            
        })
    
        sessionTask.resume()
    }
    
    func textViewDidChange(textView: UITextView!) {
        updateCharacterCount()
    }
    
    private func updateCharacterCount() {
        let count = 256 - postTextView.text.utf16Count
        characterCountLabel.text = "\(count)"
        if count < 5 && count >= 0 {
            characterCountLabel.textColor = UIColor.blackColor()
        } else if count < 0 {
            characterCountLabel.textColor = UIColor.redColor()
        } else {
            characterCountLabel.textColor = UIColor.lightGrayColor()
        }
    }
    
    //MARK: Gesture recognizer actions
    @IBAction func dismissKeyboard(sender: UISwipeGestureRecognizer) {
        postTextView?.resignFirstResponder()
        if self.replyToPost != nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //MARK: Twitter
    func tweetText(text: String, linksArray: [[String:String]], accountIdentifier: String, completion: () -> ()) {
        var postTextPartOne = ""
        var postTextPartTwo = ""
        if text.utf16Count > 140 {
//            let index = advance(postTextPartOne.startIndex, 130)
//            postTextPartTwo = "..." + postTextPartOne.substringFromIndex(index) + "\n2/2"
//            postTextPartOne = postTextPartOne.substringToIndex(index) + "...\n1/2"
            let components = text.componentsSeparatedByString(" ")
            var addToFirstPart = true
            for word in components {
                if postTextPartOne.utf16Count + word.utf16Count > 130 {
                    addToFirstPart = false
                }
                if addToFirstPart {
                    postTextPartOne += " \(word)"
                } else {
                    postTextPartTwo += " \(word)"
                }
            }
        }
        
        if postTextPartTwo != "" {
            postTextPartOne = postTextPartOne + " ...\n1/2"
            postTextPartTwo = "... " + postTextPartTwo + "\n2/2"

        }
        
        println("postTextPartOne: \(postTextPartOne)")
        println("postTextPartTwo: \(postTextPartTwo)")
        
        let parameters = ["status" : postTextPartOne]
        let tweetRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: NSURL(string: "https://api.twitter.com/1.1/statuses/update.json"), parameters: parameters)
        
        let account = self.accountStore?.accountWithIdentifier(accountIdentifier)
        tweetRequest.account = account
        tweetRequest.performRequestWithHandler { (tweetData, tweetResponse, tweetError) in
            println("error: \(tweetError)")
            println("tweetResponse: \(tweetResponse)")
            
            if postTextPartTwo != "" {
                let parameters = ["status" : postTextPartTwo]
                let tweetRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: NSURL(string: "https://api.twitter.com/1.1/statuses/update.json"), parameters: parameters)
                tweetRequest.account = account
                tweetRequest.performRequestWithHandler { (tweetData, tweetResponse, tweetError) in
                    println("error: \(tweetError)")
                    println("tweetResponse: \(tweetResponse)")
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        completion()
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    completion()
                })
            }
        }
    }
    
    private func resetTextView() {
        isPosting = false
        postTextView.text = ""
        updateCharacterCount()
    }
    
    func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}