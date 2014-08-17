//
//  ViewController.swift
//  Jupp
//
//  Created by dasdom on 09.08.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit
import PostToADN
import KeychainAccess

class ViewController: UIViewController, UITextViewDelegate {
    
    var accessToken: String?
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        accessToken = KeychainAccess.passwordForAccount("AccessToken")
        if accessToken == nil {
            performSegueWithIdentifier("ShowLoginViewController", sender: self)
        }
        
        postTextView.becomeFirstResponder()
        updateCharacterCount()
    }
    
    @IBAction func post(sender: AnyObject) {
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
        
        let request = RequestFactory.postRequestFromPostText(postTextView.text, linksArray: [], accessToken: accessToken!)
        
        let session = NSURLSession.sharedSession()
        let sessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            let responseDict  = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as [String:AnyObject]
            println("responseDict: \(responseDict)")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.postTextView.text = ""
                self.updateCharacterCount()
            })
            
        })
    
        sessionTask.resume()
    }
    
    @IBAction func deleteText(sender: AnyObject) {
        postTextView.text = ""
        updateCharacterCount()
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
}