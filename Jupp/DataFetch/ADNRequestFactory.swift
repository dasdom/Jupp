//
//  URLRequest.swift
//  GlobalADN
//
//  Created by dasdom on 18.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation
import KeychainAccess

class ADNRequestFactory {
    
    class var globalRequest: NSURLRequest {
    return GETRequestWithSubstring("posts/stream/global", parameters: nil, authorization: false)
    }
    
    class func personalTimeLineRequestBefore(id: Int?, sinceId: Int?) -> NSURLRequest {
        var dictionary = Dictionary<String,Int>()
        if let beforeId = id {
            dictionary = ["before_id" : beforeId]
        }
        if let theSinceId = sinceId {
            dictionary["since_id"] = theSinceId
            dictionary["count"] = -200
        }
        return GETRequestWithSubstring("posts/stream/unified", parameters: dictionary, authorization: true)
    }
    
    class func mentionsRequestBefore(id: Int?, sinceId: Int?) -> NSURLRequest {
        var dictionary = Dictionary<String,Int>()
        if let beforeId = id {
            dictionary = ["before_id" : beforeId]
        }
        if let theSinceId = sinceId {
            dictionary["since_id"] = theSinceId
            dictionary["count"] = -200
        }
        return GETRequestWithSubstring("users/me/mentions", parameters: dictionary, authorization: true)
    }
    
    class func repostRequestForPostId(id: Int) -> NSURLRequest {
        return POSTRequestWithSubstring("posts/\(id)/repost", parameters: nil)
    }
    
    class func urlFromSubstring(substring: String, parameters: Dictionary<String,Int>?) -> String {
        var urlString = "https://api.app.net/" + substring + "?include_html=0&include_post_annotations=1"
        if let theParameters = parameters {
            for (name, value) in theParameters {
                println("name: \(name) value: \(value)")
                urlString = urlString + "&\(name)=\(value)"
            }
        }
        println("urlString: \(urlString)")
        return urlString
    }
    
    class func GETRequestWithSubstring(substring: String, parameters theParameters: Dictionary<String,Int>?, authorization: Bool) -> NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: urlFromSubstring(substring, parameters: theParameters))!)
        urlRequest.HTTPMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        
        if authorization {
            let accessToken = KeychainAccess.passwordForAccount("AccessToken")
            let authorizationString = "Bearer " + accessToken!
            urlRequest.addValue(authorizationString, forHTTPHeaderField: "Authorization")
        }
        return urlRequest as NSURLRequest
    }
    
    class func POSTRequestWithSubstring(substring: String, parameters theParameters: Dictionary<String,Int>?) -> NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: urlFromSubstring(substring, parameters: theParameters))!)
        urlRequest.HTTPMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let accessToken = KeychainAccess.passwordForAccount("AccessToken")
        let authorizationString = "Bearer " + accessToken!
        urlRequest.addValue(authorizationString, forHTTPHeaderField: "Authorization")
        
        return urlRequest as NSURLRequest
    }
}
