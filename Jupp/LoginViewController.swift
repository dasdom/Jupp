//
//  LoginViewController.swift
//  Jupp
//
//  Created by dasdom on 16.08.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation
import UIKit
import KeychainAccess

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var responseTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func login(sender: AnyObject) {
        passwordTextField.resignFirstResponder()
        
        if usernameTextField.text.utf16Count < 1 || passwordTextField.text.utf16Count < 1 {
            let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error message title"), message: NSLocalizedString("Please put in your username, password and touch log in.", comment: "Empty password or username field error message"), preferredStyle: .Alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Ok button title"), style: .Default, handler: nil)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        let urlString = "https://account.app.net/oauth/access_token"
        
        let clientId = ClientData.clientId
        let passwordGrantSecret = ClientData.passwordGrantSecret
        
        let username: String = usernameTextField.text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLUserAllowedCharacterSet())!
        let password: String = passwordTextField.text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        
        var postString = "client_id=\(clientId)&password_grant_secret=\(passwordGrantSecret)&grant_type=password&username=\(username)&password=\(password)&scope=write_post"
        
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        println("start request")
//        self.responseTextView.text = "start request"

        let session = NSURLSession.sharedSession()
        let sessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.responseTextView.text = "data task"
//                })
            
            let responseDict  = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! [String:AnyObject]
            println("responseDict: \(responseDict)")
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.responseTextView.text = "\(responseDict)"
//            })

            if let error = responseDict["error"] as? NSString {
                let errorText = responseDict["error_text"] as? NSString
                let alertController = UIAlertController(title: "Error", message: (errorText as! String), preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                    self.usernameTextField.text = ""
                    self.passwordTextField.text = ""
                })
                alertController.addAction(okAction)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(alertController, animated: true, completion: { () -> Void in
                    })
                })
                return
            }
            
            if let accessToken = responseDict["access_token"]! as AnyObject as? String {
                
                KeychainAccess.setPassword(accessToken, account: "AccessToken")
                
//                let token = KeychainAccess.passwordForAccount("AccessToken")
//                self.usernameTextField.text = accessToken
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }

            
        })
        sessionTask.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
