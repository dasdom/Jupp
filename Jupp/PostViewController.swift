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

class PostViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var accessToken: String?
    var accountStore: ACAccountStore?
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var sendActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var previewTextView: UITextView!
    
    internal var isPosting = false
    
    var replyToPost: Post?
    
    internal var startRange = NSMakeRange(0, 0)
    internal let cursorVelocity = CGFloat(1.0/8.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)

        statusLabel.text = ""
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
        
        postTextView?.becomeFirstResponder()
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
        
//        postTextView?.becomeFirstResponder()
        updateCharacterCount()
        
        accountStore = ACAccountStore()

    }
    
    @IBAction func post(sender: AnyObject) {
        
        var errorMessage: String?
        if  postTextView.text?.utf16Count < 1 {
            errorMessage = NSLocalizedString("A post should have at least one character.", comment: "Empty post alert message")
        } else if postTextView.text?.utf16Count > 256 {
            errorMessage = NSLocalizedString("A post cannot have more than 256 characters.", comment: "To many characters alert message")
        }
        
        if errorMessage != nil {
            let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error message title"), message: errorMessage, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Ok button title"), style: .Default, handler: nil)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        if accessToken == nil {
            accessToken = KeychainAccess.passwordForAccount("AccessToken")
        }
        if accessToken == nil {
            performSegueWithIdentifier("ShowLoginViewController", sender: self)
            return
        }
        
//        let imageUploadRequest = RequestFactory.imageUploadRequest(imageView.image!, accessToken: accessToken!)
//        
//        let sessionId = "de.dasdom.jupp.image.backgroundsession"
//        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(sessionId)
//        
//        config.sharedContainerIdentifier = "group.de.dasdom.Jupp"
//        
//        let session1 = NSURLSession(configuration: config, delegate: PostService.sharedService, delegateQueue: NSOperationQueue.mainQueue())
//        
//        let sessionTask1 = session1.dataTaskWithRequest(imageUploadRequest)
//        sessionTask1.resume()
//        return
        
        let linkExtractor = LinkExtractor()
        let (postText, linksArray) = linkExtractor.extractLinks(postTextView.text)
//        let request = RequestFactory.postRequestFromPostText(postText, linksArray: linksArray, accessToken: accessToken!, replyTo: replyToPost?.id)
        
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
//        let sessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
        
//            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
//
//            println("responseString \(responseString)")
//            println("response: \(response)")
//            println("error: \(error)")
//            let responseDict  = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as [String:AnyObject]
//            println("responseDict: \(responseDict)")
        
        statusLabel.text = "...Posting to App.net..."
        ADNAPICommunicator().postText(postText, linksArray: linksArray, accessToken: accessToken!, image: imageView.image) {
        
            dispatch_async(dispatch_get_main_queue(), {
                self.sendActivityIndicator.stopAnimating()
                
                if self.replyToPost != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.isPosting = false
                    return
                }
            })
            if linksArray.count > 1 {
                dispatch_async(dispatch_get_main_queue(), {
                    self.resetTextView()
                    })
                return
            }
            
            if let accountIdentifier = NSUserDefaults.standardUserDefaults().stringForKey(kActiveAccountIdKey) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.statusLabel.text = "...Tweeting to Twitter..."
                })
                self.tweetText(postText, linksArray: linksArray, accountIdentifier: accountIdentifier, image: self.imageView.image, completion: {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.resetTextView()
                    })
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.resetTextView()
                })
            }
            
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        updateCharacterCount()
        
        let linkExtractor = LinkExtractor()
        let (postText, linksArray) = linkExtractor.extractLinks(postTextView.text)

        var (tweetOne, tweetTwo) = tweetsFromText(postText, linksArray: linksArray)

        previewTextView.text = tweetOne + "\n\n" + tweetTwo
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
        if let accountIdentifier = NSUserDefaults.standardUserDefaults().stringForKey(kActiveAccountIdKey) {
            postTextView?.resignFirstResponder()
            if self.replyToPost != nil {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func showKeyboard(sender: UISwipeGestureRecognizer) {
        postTextView.becomeFirstResponder()
    }
    
    
    
    @IBAction func moveCurser(sender: UIPanGestureRecognizer) {
        if sender.state == .Began {
            startRange = postTextView.selectedRange
        }
        
        let translation = sender.translationInView(postTextView)
        let cursorLocation = max(startRange.location+Int(translation.x*cursorVelocity), 0)
        
        let selectedRange = NSMakeRange(cursorLocation, 0)
        postTextView.selectedRange = selectedRange
    }
    
    //MARK: Twitter
    func tweetText(text: String, linksArray: [[String:String]], accountIdentifier: String, image: UIImage?, completion: () -> ()) {
//        var tweetOne = text
//        var tweetTwo = ""
//
//        var addToFirstPart = true
//        if text.utf16Count > 140 {
//            let components = text.componentsSeparatedByString(" ")
//            
//            tweetOne = ""
//            for word in components {
//                if tweetOne.utf16Count + word.utf16Count > 130 {
//                    if word.isURL() && tweetOne.utf16Count + 10 < 130 {
//                        addToFirstPart = true
//                    } else {
//                        addToFirstPart = false
//                    }
//                }
//                if addToFirstPart {
//                    tweetOne += " \(word)"
//                } else {
//                    tweetTwo += " \(word)"
//                }
//            }
//        }
        
        var (tweetOne, tweetTwo) = tweetsFromText(text, linksArray: linksArray)
        
//        if linksArray.count > 0 {
//            let linkString = linksArray.first!["url"]!
//            if addToFirstPart {
//                if tweetOne.utf16Count < 130 {
//                    
//                    tweetOne += " \(linkString)"
//                } else {
//                    dispatch_async(dispatch_get_main_queue(), {
//                        
//                        let alertMessage = "Tweeting was not possible because there would be two tweets but the second one would only have a link in it."
//                        let alert = UIAlertController(title: "There was an error", message: alertMessage, preferredStyle: .Alert)
//                        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
//                            println("OK")
//                        })
//                        alert.addAction(okAction)
//                        
//                        self.presentViewController(alert, animated: true, completion: nil)
//                        
//                        completion()
//                    })
//                    return
//                }
//            } else {
//                tweetTwo += " \(linkString)"
//            }
//        }
//        
//        if tweetTwo != "" {
//            if tweetOne.utf16Count < 134 {
//                tweetOne = tweetOne + " ...\n1/2"
//            }
//            tweetTwo = "... " + tweetTwo + "\n2/2"
//
//        }
        
        println("postTextPartOne: \(tweetOne)")
        println("postTextPartTwo: \(tweetTwo)")
        
        var urlString = "https://api.twitter.com/1.1/statuses/update.json"
        if imageView.image != nil {
            urlString = "https://api.twitter.com/1.1/statuses/update_with_media.json"
        }
        
        let parameters = ["status" : tweetOne]
        let tweetRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: NSURL(string: urlString), parameters: parameters)
        
        if imageView.image != nil {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy_MM_dd'T'HH_mm_ss'Z'"
            let imageName = "\(dateFormatter.stringFromDate(NSDate()))" + "jpg"
            
            tweetRequest.addMultipartData(UIImageJPEGRepresentation(image!, 0.3), withName: "media", type: "image/jpg", filename: imageName)
        }
        
        let account = accountStore?.accountWithIdentifier(accountIdentifier)
        tweetRequest.account = account
        tweetRequest.performRequestWithHandler { (tweetData, tweetResponse, tweetError) in
            println("error: \(tweetError)")
            println("tweetResponse: \(tweetResponse)")
            
            if tweetResponse.statusCode != 200 {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let alertMessage = "Tweeting didn't work."
                    let alert = UIAlertController(title: "There was an error", message: alertMessage, preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                        println("OK")
                    })
                    alert.addAction(okAction)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    completion()
                })
                return
            }
            
            if tweetTwo != "" {
                let parameters = ["status" : tweetTwo]
                let tweetRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: NSURL(string: "https://api.twitter.com/1.1/statuses/update.json"), parameters: parameters)
                tweetRequest.account = account
                tweetRequest.performRequestWithHandler { (tweetData, tweetResponse, tweetError) in
                    println("error: \(tweetError)")
                    println("tweetResponse: \(tweetResponse)")
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        let alertMessage = "Tweet 1: \(tweetOne)" + "\n\n" + "Tweet 2: \(tweetTwo)"
                        let alert = UIAlertController(title: "You tweeted two tweets:", message: alertMessage, preferredStyle: .Alert)
                        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                            println("OK")
                        })
                        alert.addAction(okAction)
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                        
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
    
    func tweetsFromText(text: String, linksArray: [[String:String]]) -> (tweetOne: String, tweetTwo: String) {
        var tweetOne = text
        var tweetTwo = ""
        
        var addToFirstPart = true
        if text.utf16Count > 140 {
            let components = text.componentsSeparatedByString(" ")
            
            tweetOne = ""
            for word in components {
                if tweetOne.utf16Count + word.utf16Count > 130 {
                    if word.isURL() && tweetOne.utf16Count + 10 < 130 {
                        addToFirstPart = true
                    } else {
                        addToFirstPart = false
                    }
                }
                if addToFirstPart {
                    tweetOne += " \(word)"
                } else {
                    tweetTwo += " \(word)"
                }
            }
        }
        
        if linksArray.count > 0 {
            let linkString = linksArray.first!["url"]!
            if addToFirstPart {
//                if tweetOne.utf16Count < 130 {
                
                    tweetOne += " \(linkString)"
//                } else {
//                    dispatch_async(dispatch_get_main_queue(), {
//                        
//                        let alertMessage = "Tweeting was not possible because there would be two tweets but the second one would only have a link in it."
//                        let alert = UIAlertController(title: "There was an error", message: alertMessage, preferredStyle: .Alert)
//                        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
//                            println("OK")
//                        })
//                        alert.addAction(okAction)
//                        
//                        self.presentViewController(alert, animated: true, completion: nil)
//                        
//                        completion()
//                    })
//                    return
//                }
            } else {
                tweetTwo += " \(linkString)"
            }
        }
        
        if tweetTwo != "" {
            if tweetOne.utf16Count < 134 {
                tweetOne = tweetOne + " ...\n1/2"
            }
            tweetTwo = "... " + tweetTwo + "\n2/2"
            
        }
        
        return (tweetOne, tweetTwo)
    }
    
    private func resetTextView() {
        isPosting = false
        postTextView.text = ""
        updateCharacterCount()
        imageView.image = nil
        statusLabel.text = ""
    }
    
    func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                textViewBottomConstraint.constant = keyboardHeight + 40.0
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
        
    }
    
    // MARK: Button actions
    @IBAction func addPhoto(sender: UIButton) {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.sourceType = .PhotoLibrary
        imagePickerViewController.delegate = self
        
        presentViewController(imagePickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func toggleKeyboard(sender: UIButton) {
        if postTextView.isFirstResponder() {
            postTextView.resignFirstResponder()
        } else {
            postTextView.becomeFirstResponder()
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}