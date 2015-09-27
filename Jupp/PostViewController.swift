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
import MediaPlayer

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
  @IBOutlet weak var numberOfTweetLabel: UILabel!
  
  internal var isPosting = false
  
  var crosspost = false {
    didSet {
      numberOfTweetLabel.hidden = !crosspost
    }
  }
  
  var finishedADNPosting = true {
    didSet {
      if finishedADNPosting {
        resetTextViewIfPossible()
      }
    }
  }
  
  var finishedTweeing = true {
    didSet {
      if finishedTweeing {
        resetTextViewIfPossible()
      }
    }
  }
  
  internal var startRange = NSMakeRange(0, 0)
  internal let cursorVelocity = CGFloat(1.0/8.0)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    
    statusLabel.text = ""
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    var buttonTitle = "Post"
    if let _ = NSUserDefaults.standardUserDefaults().stringForKey(kActiveTwitterAccountIdKey) {
      buttonTitle = "Crosspost"
      crosspost = true
    } else {
      crosspost = false
    }
    let postButton = UIBarButtonItem(title: buttonTitle, style: UIBarButtonItemStyle.Plain, target: self, action: "post:")
    
    navigationItem.rightBarButtonItem = postButton
    
    postTextView?.becomeFirstResponder()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    accessToken = KeychainAccess.passwordForAccount("AccessToken")
    if accessToken == nil || accessToken == "" {
      performSegueWithIdentifier("ShowLoginViewController", sender: self)
      return
    }
    
    updateCharacterCount()
    
    accountStore = ACAccountStore()
    
  }
  
  @IBAction func post(sender: AnyObject) {
    
    var errorMessage: String?
    if  postTextView.text!.utf16.count < 1 {
      errorMessage = NSLocalizedString("A post should have at least one character.", comment: "Empty post alert message")
    } else if postTextView.text!.utf16.count > 256 {
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
    
    let linkExtractor = LinkExtractor()
    let (postText, linksArray) = linkExtractor.extractLinks(postTextView.text)
    
    if isPosting {
      return
    }
    isPosting = true
    
    sendActivityIndicator.startAnimating()
//    let session = NSURLSession.sharedSession()
    
    statusLabel.text = "Posting"
    finishedADNPosting = false
    ADNAPICommunicator().postText(postText, linksArray: linksArray, accessToken: accessToken!, image: imageView.image) {
      
      dispatch_async(dispatch_get_main_queue(), {
        self.finishedADNPosting = true
      })
      
    }
    
    if linksArray.count < 2 {
      
      if let accountIdentifier = NSUserDefaults.standardUserDefaults().stringForKey(kActiveTwitterAccountIdKey) {
        
        if let statusString = statusLabel.text {
          statusLabel.text = "\(statusString) and Tweeting"
        } else {
          statusLabel.text = "Tweeting"
        }
        finishedTweeing = false
        tweetText(postText, linksArray: linksArray, accountIdentifier: accountIdentifier, image: self.imageView.image, completion: {
          dispatch_async(dispatch_get_main_queue(), {
            self.finishedTweeing = true
          })
        })
      } else {
        dispatch_async(dispatch_get_main_queue(), {
          self.finishedTweeing = true
        })
      }
    }
  }
  
  func textViewDidChange(textView: UITextView) {
    updateCharacterCount()
    
    let linkExtractor = LinkExtractor()
    let (postText, linksArray) = linkExtractor.extractLinks(postTextView.text)
    
    let (tweetOne, tweetTwo) = tweetsFromText(postText, linksArray: linksArray)
    
    if tweetTwo.utf16.count > 0 {
      numberOfTweetLabel.text = "2 Tweets"
    } else {
      numberOfTweetLabel.text = "1 Tweet"
    }
    
    previewTextView.text = tweetOne + "\n\n" + tweetTwo
  }
  
  private func updateCharacterCount() {
    let characterCount = 256 - postTextView.text.utf16.count
    characterCountLabel.text = "\(characterCount)"
    if characterCount < 5 && characterCount >= 0 {
      characterCountLabel.textColor = UIColor.blackColor()
    } else if characterCount < 0 {
      characterCountLabel.textColor = UIColor.redColor()
    } else {
      characterCountLabel.textColor = UIColor.lightGrayColor()
    }
  }
  
  //MARK: Gesture recognizer actions
  @IBAction func dismissKeyboard(sender: UISwipeGestureRecognizer) {
    if crosspost {
      postTextView?.resignFirstResponder()
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
    
    let (tweetOne, tweetTwo) = tweetsFromText(text, linksArray: linksArray)
    
    print("postTextPartOne: \(tweetOne)")
    print("postTextPartTwo: \(tweetTwo)")
    
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
      print("error: \(tweetError)")
      print("tweetResponse: \(tweetResponse)")
      
      if tweetResponse.statusCode != 200 {
        dispatch_async(dispatch_get_main_queue(), {
          
          let alertMessage = "Tweeting didn't work."
          let alert = UIAlertController(title: "There was an error", message: alertMessage, preferredStyle: .Alert)
          let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            print("OK")
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
          print("error: \(tweetError)")
          print("tweetResponse: \(tweetResponse)")
          
          dispatch_async(dispatch_get_main_queue(), {
            
            let alertMessage = "Tweet 1: \(tweetOne)" + "\n\n" + "Tweet 2: \(tweetTwo)"
            let alert = UIAlertController(title: "You tweeted two tweets:", message: alertMessage, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
              print("OK")
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
    if text.utf16.count > 140 {
      let components = text.componentsSeparatedByString(" ")
      
      tweetOne = ""
      for word in components {
        if tweetOne.utf16.count + word.utf16.count > 130 {
          if word.isURL() && tweetOne.utf16.count + 10 < 130 {
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
        tweetOne += " \(linkString)"
      } else {
        tweetTwo += " \(linkString)"
      }
    }
    
    if tweetTwo != "" {
      if tweetOne.utf16.count < 134 {
        tweetOne = tweetOne + " ...\n1/2"
      }
      tweetTwo = "... " + tweetTwo + "\n2/2"
      
    }
    
    return (tweetOne, tweetTwo)
  }
  
  private func resetTextViewIfPossible() {
    if finishedADNPosting && finishedTweeing {
      sendActivityIndicator.stopAnimating()
      isPosting = false
      postTextView.text = ""
      updateCharacterCount()
      imageView.image = nil
      statusLabel.text = ""
      numberOfTweetLabel.text = crosspost ? "1 Tweet" : ""
      previewTextView.text = ""
    }
  }
  
  func cancel(sender: UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func keyboardWillShow(sender: NSNotification) {
    if let userInfo = sender.userInfo {
      if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
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
  
  @IBAction func addButtonTouched(sender: UIButton) {
    let actionViewController = UIAlertController(title: "Add", message: "", preferredStyle: .ActionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
    }
    
    actionViewController.addAction(cancelAction)
    
//    let lastPhotoAction = UIAlertAction(title: "Last Photo", style: .Default) { (action) -> Void in
//      
//    }
//    
//    actionViewController.addAction(lastPhotoAction)
    
    let cameraPhotoAction = UIAlertAction(title: "Camera Photo", style: .Default) { (action) -> Void in
      let imagePickerViewController = UIImagePickerController()
      imagePickerViewController.sourceType = .Camera
      imagePickerViewController.delegate = self
      
      self.presentViewController(imagePickerViewController, animated: true, completion: nil)
    }
    
    actionViewController.addAction(cameraPhotoAction)
    
    let galleryPhotoAction = UIAlertAction(title: "Gallery Photo", style: .Default) { (action) -> Void in
      let imagePickerViewController = UIImagePickerController()
      imagePickerViewController.sourceType = .PhotoLibrary
      imagePickerViewController.delegate = self
      
      self.presentViewController(imagePickerViewController, animated: true, completion: nil)
    }
    
    actionViewController.addAction(galleryPhotoAction)
    
    let song = MPMusicPlayerController.systemMusicPlayer().nowPlayingItem
    let nowPlayingAction = UIAlertAction(title: "Now Playing", style: .Default) { (action) -> Void in
//      NSString *title   = [song valueForProperty:MPMediaItemPropertyTitle];
//      //    NSString * album   = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
//      NSString *artist  = [song valueForProperty:MPMediaItemPropertyArtist];
//      UIImage *artwork = [[song valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(200.0f, 200.0f)];
//      
//      if ([self.postTextView.text isEqualToString:@""]) {
//        self.postTextView.text = [self.postTextView.text stringByAppendingFormat:@"#nowplaying %@ - %@", title, artist];
//      } else {
//        self.postTextView.text = [self.postTextView.text stringByAppendingFormat:@"\n#nowplaying %@ - %@", title, artist];
//      }
//      if (artwork) {
//        self.pictureImageView.image = artwork;
//        self.postImage = artwork;
//        
        //      }
        
        if let song = song {
            
            let title = song.valueForProperty(MPMediaItemPropertyTitle) as! String
            let artist = song.valueForProperty(MPMediaItemPropertyArtist) as! String
            if let artwork = song.valueForProperty(MPMediaItemPropertyArtwork)?.imageWithSize(CGSize(width: 200.0, height: 200.0)) {
                self.imageView.image = artwork
            }
            
            if self.postTextView.text.utf16.count < 1 {
                self.postTextView.text = self.postTextView.text.stringByAppendingFormat("#nowplaying %@ - %@", title, artist)
            } else {
                self.postTextView.text = self.postTextView.text.stringByAppendingFormat("\n#nowplaying %@ - %@", title, artist)
            }
        }
    }
    
    if let _ = song {
      actionViewController.addAction(nowPlayingAction)
    }
    presentViewController(actionViewController, animated: true, completion: nil)
  }
  
  @IBAction func toggleKeyboard(sender: UIButton) {
    if postTextView.isFirstResponder() {
      postTextView.resignFirstResponder()
    } else {
      postTextView.becomeFirstResponder()
    }
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    imageView.image = image
    
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
}