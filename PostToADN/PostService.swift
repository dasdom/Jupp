//
//  PostService.swift
//  Jupp
//
//  Created by dasdom on 05.12.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation
import UIKit
import KeychainAccess

public class PostService: NSObject, NSURLSessionDataDelegate, NSURLSessionTaskDelegate {
   
    var session = NSURLSession()
    
    public class var sharedService: PostService {
        struct Singleton {
            static let instance = PostService()
        }
        return Singleton.instance
    }
    
    public func uploadImage(image: UIImage, session: NSURLSession, completion: ([String:AnyObject]) -> (), progress: (Float) -> ()) {
        
        self.session = session
        
        if let accessToken = KeychainAccess.passwordForAccount("AccessToken") {
            let imageUploadRequest = RequestFactory.imageUploadRequest(image, accessToken: accessToken)
            
//            let imageURL = ImageService().saveImageToUpload(image, name: "imageName")
            
            let sessionTask = session.dataTaskWithRequest(imageUploadRequest)
            sessionTask.resume()
        }
    }

    public func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        print("didBecomeInvalidWithError \(error)")
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        print("didReceiveResponse: \(response)")
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("didSendBodyData")

    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        print("didReceiveData")
        dispatch_async(dispatch_get_main_queue()) {
            let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
            print("uploadImage dataString \(dataString)")
        }
    }
    
    public func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        print("URLSessionDidFinishEventsForBackgroundURLSession")
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        print("didCompleteWithError: session \(session) task \(task) error \(error)")
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, willCacheResponse proposedResponse: NSCachedURLResponse, completionHandler: (NSCachedURLResponse?) -> Void) {
        print("willCacheResponse")
    }

}
