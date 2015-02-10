//
//  RequestFactory.swift
//  Jupp
//
//  Created by dasdom on 10.08.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit

public class RequestFactory {
    
    public init() {
        
    }
    
    public class func postRequestFromPostText(postText: String, var linksArray: [[String:String]], accessToken:String, imageDict: [String:AnyObject]? = nil, replyTo: Int? = nil) -> NSURLRequest {
        var urlString = "https://api.app.net/posts?include_post_annotations=1"
        var url = NSURL(string: urlString)
        var postRequest = NSMutableURLRequest(URL: url!)
        
        let authorizationString = "Bearer " + accessToken;
        postRequest.addValue(authorizationString, forHTTPHeaderField: "Authorization")
        postRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        postRequest.HTTPMethod = "POST"
        
        //TODO: Add case when posting links and image. (see hAppy)
        
        var postDictionary = Dictionary<String, AnyObject>()
        var alteredPostTest = postText
        if let imageDict = imageDict {
            alteredPostTest += "\n"
            alteredPostTest += "photos.app.net/{post_id}/1"
            
            let imageAnnotationDict: [String:String] = ["file_id": imageDict["id"] as! String, "file_token": imageDict["file_token"] as! String, "format": "oembed"]
            let annotationValueDict: [String:AnyObject] = ["+net.app.core.file": imageAnnotationDict]
            let annotationDict: [String:AnyObject] = ["type": "net.app.core.oembed", "value" : annotationValueDict]
            postDictionary["annotations"] = [annotationDict]
        }
        postDictionary["text"] = alteredPostTest
        
        if replyTo != nil {
            postDictionary["reply_to"] = replyTo
        }
        
        postDictionary["entities"] = ["links": linksArray, "parse_links": true]
        
        println("postDictionary \(postDictionary)")
        
        var error: NSError? = nil
        let postData = NSJSONSerialization.dataWithJSONObject(postDictionary, options: nil, error: &error)
        
        postRequest.HTTPBody = postData
        
        return postRequest
    }
    
    public class func imageUploadRequest(image: UIImage, accessToken: String) -> NSURLRequest {
        let imageData = UIImageJPEGRepresentation(image, 0.3)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd'T'HH_mm_ss'Z'"
        let imageName = "\(dateFormatter.stringFromDate(NSDate()))"
        
        var imageUploadRequest = NSMutableURLRequest(URL: NSURL(string: "https://alpha-api.app.net/stream/0/files")!)
        let authorizationString = "Bearer " + accessToken;
        imageUploadRequest.addValue(authorizationString, forHTTPHeaderField: "Authorization")
        
        imageUploadRequest.HTTPMethod = "POST"
        
        let boundary = "82481319dca6"
        let contentType = "multipart/form-data; boundary=\(boundary)"
        imageUploadRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        var postBody = NSMutableData()
        postBody.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        postBody.appendData("Content-Disposition: form-data; name=\"content\"; filename=\"\(imageName).jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        postBody.appendData("Content-Type: image/jpeg\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        postBody.appendData(imageData)
        postBody.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)

        postBody.appendData("Content-Disposition: form-data; name=\"type\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        postBody.appendData("de.dasdom.jupp.photo".dataUsingEncoding(NSUTF8StringEncoding)!)

        imageUploadRequest.HTTPBody = postBody
        
        return imageUploadRequest
    }
    
}