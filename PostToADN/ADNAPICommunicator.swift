//
//  ADNAPICommunicator.swift
//  Jupp
//
//  Created by dasdom on 03.12.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit

public class ADNAPICommunicator: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate {
    
    var data = NSMutableData()
    var postText = String()
    var accessToken = String()
    var session = NSURLSession()
    
    public func uploadImage(image: UIImage, accessToken: String, completion: ([String: AnyObject]) -> () ) {
//    public func uploadImage(image: UIImage, accessToken: String) {
    
        let imageUploadRequest = RequestFactory.imageUploadRequest(image, accessToken: accessToken)
        
//        let sessionId = "de.dasdom.jupp.image.backgroundsession"
//        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(sessionId)
//        
//        config.sharedContainerIdentifier = "group.de.dasdom.Jupp"
        
        session = NSURLSession.sharedSession()
        let sessionTask = session.dataTaskWithRequest(imageUploadRequest, completionHandler: { (data, response, error) -> Void in
            
            let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("uploadImage dataString \(dataString)")
            
            let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! [String: AnyObject]
            completion(dictionary)
        })
        sessionTask.resume()
        
//        let sessionTask = session.dataTaskWithRequest(imageUploadRequest)
//        sessionTask.resume()
    
    }
    
    public func postText(text: String, linksArray: [[String:String]], accessToken: String, image: UIImage?, completion: () -> ()) {
       
        func postText(text: String, linksArray: [[String:String]], accessToken: String, imageDict: [String:AnyObject]?, completion: () -> ()) {
            let request = RequestFactory.postRequestFromPostText(text, linksArray: linksArray, accessToken: accessToken, imageDict: imageDict)
            
//                let sessionId = "de.dasdom.jupp.backgroundsession"
//                let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(sessionId)
            
            let session = NSURLSession.sharedSession()
            let sessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                
                let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("postText dataString \(dataString)")
                completion()
            })
            sessionTask.resume()
        }
        
        if let image = image {
            uploadImage(image, accessToken: accessToken) { (dictionary) -> () in
                let imageDict = dictionary["data"] as? [String:AnyObject]
                
                postText(text, linksArray, accessToken, imageDict, { () -> () in
                    completion()
                })
            }
        } else {
            postText(text, linksArray, accessToken, nil, { () -> () in
                completion()
            })
        }

    }
    
    
//    public func postText(text: String, image: UIImage, accessToken: String) {
//        uploadImage(image, accessToken: accessToken)
//        
//        println("session: \(session)")
//        
//        postText = text
//        self.accessToken = accessToken
//    }
//    
//    public func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
//        println("didBecomeInvalidWithError \(error)")
//    }
//    
//    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
//        println("didReceiveResponse: \(response)")
//        data = NSMutableData()
//    }
//    
//    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
//        println("didSendBodyData")
//
//    }
//    
//    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
//        println("didReceiveData")
//        self.data.appendData(data)
//    }
//    
//    public func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
//        let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
//        println("uploadImage dataString \(dataString)")
//        
//        let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as [String: AnyObject]
//        println("dictionary: \(dictionary)")
//    }
//    
//    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
//        println("didCompleteWithError")
//    }
    
}
