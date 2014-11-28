//
//  ShareViewController.swift
//  ShareToADN
//
//  Created by dasdom on 09.08.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import PostToADN
import KeychainAccess

class ShareViewController: SLComposeServiceViewController, NSURLSessionDelegate {

    var urlSession: NSURLSession?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let inputItem = self.extensionContext!.inputItems.first as NSExtensionItem
        println("inputItems: \(self.extensionContext!.inputItems)")
        
        if let urlProvider = inputItem.attachments!.first as? NSItemProvider {
            urlProvider.loadItemForTypeIdentifier("public.url", options: nil) {
                (decoder: NSSecureCoding!, error: NSError!) -> Void in
                if let url = decoder as? NSURL {
                    println("\(url.absoluteString)")
                }
            }
        }
        
    }
    
    override func isContentValid() -> Bool {
        charactersRemaining = 256 - contentText.utf16Count
        
        return contentText.utf16Count < 256
    }

    override func didSelectPost() {
       
        let accessToken = KeychainAccess.passwordForAccount("AccessToken")
        if accessToken == nil {
            return
        }
        
        let inputItem = self.extensionContext!.inputItems.first as NSExtensionItem
        println("\(self.extensionContext!.inputItems)")
        
        if let urlProvider = inputItem.attachments!.first as? NSItemProvider {
            urlProvider.loadItemForTypeIdentifier(kUTTypeURL as NSString, options: nil) {
                (decoder: NSSecureCoding!, error: NSError!) -> Void in
                if let url = decoder as? NSURL {
                    println("\(url.absoluteString)")

                    let length = self.contentText.utf16Count
                    let linkDict = ["url" : url.absoluteString!, "pos": "0", "len": "\(length)"]
                    let linksArray: [[String:String]] = [linkDict]
                    
                    let urlSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
                    self.urlSession = NSURLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: nil)
//                    let urlSessionTask = self.urlSession!.dataTaskWithRequest(self.postRequestFromPostText(self.contentText, linksArray: linksArray,  accessToken: accessToken))
                    let request = RequestFactory()
                    let urlSessionTask = self.urlSession!.dataTaskWithRequest(RequestFactory.postRequestFromPostText(self.contentText, linksArray: linksArray, accessToken: accessToken!), completionHandler: { (data, response, error) -> Void in
                        println("response: \(response)")
                        let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                        println("responseString: \(responseString)")
                        self.extensionContext!.completeRequestReturningItems(nil, completionHandler: nil)
                    })
                    
                    urlSessionTask.resume()
                }
            }
        }
        
    }

    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return NSArray()
    }

//    func postRequestFromPostText(postText: String, linksArray: [[String:String]], accessToken:String) -> NSURLRequest {
//        var urlString = "https://api.app.net/posts?include_post_annotations=1"
//        var url = NSURL(string: urlString)
//        var postRequest = NSMutableURLRequest(URL: url)
//        
//        let authorizationString = "Bearer " + accessToken;
//        postRequest.addValue(authorizationString, forHTTPHeaderField: "Authorization")
//        postRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        postRequest.HTTPMethod = "POST"
//        
//        var postDictionary = Dictionary<String, AnyObject>()
//        postDictionary["text"] = postText
//        
//        postDictionary["entities"] = ["links": linksArray, "parse_links": true]
//        
//        println("postDictionary \(postDictionary)")
//        
//        var error: NSError? = nil
//        let postData = NSJSONSerialization.dataWithJSONObject(postDictionary, options: nil, error: &error)
//        
//        postRequest.HTTPBody = postData
//        
//        return postRequest
//    }
}
