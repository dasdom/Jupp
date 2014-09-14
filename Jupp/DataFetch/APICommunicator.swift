//
//  APICommunicator.swift
//  GlobalADN
//
//  Created by dasdom on 18.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation

let ADNFetchError = "ADNFetchError"

class APICommunicator {
    
    class func fetchPostsForRequest(request: NSURLRequest, completion: (array: Array<Post>?, meta: Meta?, error: NSError?) -> ()) {
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            var theError: NSError? = error
            var array: Array<Post>?
            var meta: Meta?
            if theError == nil {
                (array, meta, theError) = PostsParser().postsArrayFromData(data)
            }
            
            if theError != nil {
                completion(array: nil, meta: nil, error: theError)
                return
            }
            
            completion(array: array, meta: meta, error: nil)
        }
        task.resume()
    }
    
    class func fetchGlobalStream(completion: (array: Array<Post>?, meta: Meta?, error: NSError?) -> ()) {
        fetchPostsForRequest(ADNRequestFactory.globalRequest, completion: completion)
    }
    
    class func fetchPersonalTimeLineBefore(id: Int?, sinceId theSinceId: Int?, completion: (array: Array<Post>?, meta: Meta?, error: NSError?) -> ()) {
        fetchPostsForRequest(ADNRequestFactory.personalTimeLineRequestBefore(id, sinceId: theSinceId), completion: completion)
    }
    
    class func fetchMentionsBefore(id: Int?, sinceId theSinceId: Int?, completion: (array: Array<Post>?, meta: Meta?, error: NSError?) -> ()) {
        fetchPostsForRequest(ADNRequestFactory.mentionsRequestBefore(id, sinceId: theSinceId), completion: completion)
    }
    
    class func repostPostWithId(id: Int, completion: (error: NSError?) -> ()) {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(ADNRequestFactory.repostRequestForPostId(id)) { (data, response, error) in
            completion(error: error)
        }
        task.resume()
    }
    
//    func postsArrayFromData(data: NSData) -> (array: NSArray?, error: NSError?) {
//        var jsonError: NSError? = nil
//        var dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? NSDictionary
//        println("dictionary \(dictionary)")
//        
//        if jsonError {
//            return (nil, jsonError)
//        }
//        
//        let metaDict = dictionary?["meta"] as NSDictionary
//        if let errorMessage = metaDict["error_message"] as? NSString {
//            var error = NSError.errorWithDomain(ADNFetchError, code: metaDict["code"].integerValue, userInfo: nil)
//            return (nil, error)
//        }
//
//        return (nil, nil)
//    }
}
