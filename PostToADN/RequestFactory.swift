//
//  RequestFactory.swift
//  Jupp
//
//  Created by dasdom on 10.08.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation

public class RequestFactory {
    
    public init() {
        
    }
    
    public class func postRequestFromPostText(postText: String, linksArray: [[String:String]], accessToken:String) -> NSURLRequest {
        var urlString = "https://api.app.net/posts?include_post_annotations=1"
        var url = NSURL(string: urlString)
        var postRequest = NSMutableURLRequest(URL: url)
        
        let authorizationString = "Bearer " + accessToken;
        postRequest.addValue(authorizationString, forHTTPHeaderField: "Authorization")
        postRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        postRequest.HTTPMethod = "POST"
        
        var postDictionary = Dictionary<String, AnyObject>()
        postDictionary["text"] = postText
        
        postDictionary["entities"] = ["links": linksArray, "parse_links": true]
        
        println("postDictionary \(postDictionary)")
        
        var error: NSError? = nil
        let postData = NSJSONSerialization.dataWithJSONObject(postDictionary, options: nil, error: &error)
        
        postRequest.HTTPBody = postData
        
        return postRequest
    }
}