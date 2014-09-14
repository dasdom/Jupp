//
//  PostsParser.swift
//  GlobalADN
//
//  Created by dasdom on 19.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit

class PostsParser {
    var postBuilder: CanBuildPost
    var userBuilder: CanBuildUser
    var mentionBuilder: CanBuildMention
    
    init(postBuilder: CanBuildPost, userBuilder: CanBuildUser, mentionBuilder: CanBuildMention) {
        self.postBuilder = postBuilder
        self.userBuilder = userBuilder
        self.mentionBuilder = mentionBuilder
    }
    
    convenience init() {
        self.init(postBuilder: PostBuilder(), userBuilder: UserBuilder(), mentionBuilder: MentionBuilder())
    }
    
    
    func postsArrayFromData(data: NSData) -> (array: Array<Post>?,  meta: Meta?, error: NSError?) {
        var jsonError: NSError? = nil
        var dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? NSDictionary
//        println("dictionary \(dictionary)")

        if jsonError != nil {
            return (nil, nil, jsonError)
        }

        let metaDict = dictionary!["meta"] as Dictionary<String, AnyObject>
        println("metaDict: \(metaDict)")
        let meta = MetaBuilder().metaFromDictionary(metaDict)
        if let errorMessage = metaDict["error_message"] as? NSString {
            var code = metaDict["code"] as NSNumber
            var error = NSError.errorWithDomain(ADNFetchError, code: code.integerValue, userInfo: [NSLocalizedDescriptionKey : errorMessage])
            return (nil, nil, error)
        }

        let array = self.postsArrayFromDataDictionary(dictionary!)

        return (array, meta, nil)
    }
    
    func postsArrayFromDataDictionary(dictionary: NSDictionary) -> Array<Post> {
        var postsArray = [Post]()

        if let rawPostsArray = dictionary["data"] as? NSArray {
//            println("\(rawPostsArray)")
            for arrayEntry: AnyObject in rawPostsArray {
                if let postDictionary = arrayEntry as? NSDictionary {
                    if let post = postBuilder.postFromDictionary(postDictionary) {
                        postsArray.append(post)
                    } else {
                        println("user or post is nil")
                    }
                } else {
                    println("post dict is nil")
                }
            }
        }
        
        return postsArray
    }
}