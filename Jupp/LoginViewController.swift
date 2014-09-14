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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func login(sender: AnyObject) {
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
        
        var postString = "client_id=\(clientId)&password_grant_secret=\(passwordGrantSecret)&grant_type=password&username=\(usernameTextField.text)&password=\(passwordTextField.text)&scope=write_post"
        
        var request = NSMutableURLRequest(URL: NSURL(string: urlString))
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        println("start request")
        
        let session = NSURLSession.sharedSession()
        let sessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            let responseDict  = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as [String:AnyObject]
            println("responseDict: \(responseDict)")
            
            if let accessToken = responseDict["access_token"]! as AnyObject as? String {
                println("accessToken \(accessToken)")
                
                KeychainAccess.setPassword(accessToken, account: "AccessToken")
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
