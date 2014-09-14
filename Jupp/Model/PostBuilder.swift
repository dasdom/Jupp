//
//  PostBuilder.swift
//  GlobalADN
//
//  Created by dasdom on 20.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit

protocol CanBuildPost {
    func postFromDictionary(dictionary: NSDictionary) -> Post?
}

class PostBuilder : CanBuildPost {
    let userBuilder = UserBuilder()
    let mentionBuilder = MentionBuilder()
    let linkBuilder = LinkBuilder()
    
    func postFromDictionary(dictionary: NSDictionary) -> Post? {
        var post: Post = Post()
        
        let canonicalURLString = dictionary["canonical_url"] as? String
        let id = dictionary["id"] as? String
        let text = dictionary["text"] as? String
        let threadId = dictionary["thread_id"] as? String
        
        let user = userBuilder.userFromDictionary(dictionary["user"] as NSDictionary)
        
        let rawMentionsArray = (dictionary["entities"] as NSDictionary)["mentions"] as NSArray
        var mentionsArray = [Mention]()
        for mentionsDictionary: AnyObject in rawMentionsArray {
//            println("mentionsDictionary \(mentionsDictionary)")
            if let mention = mentionBuilder.mentionFromDictionary(mentionsDictionary as NSDictionary) {
                mentionsArray.append(mention)
            }
        }
        
        let rawLinksArray = (dictionary["entities"] as NSDictionary)["links"] as NSArray
        var linksArray = [Link]()
        for linkDictionary: AnyObject in rawLinksArray {
            if let link = linkBuilder.linkFromDictionary(linkDictionary as NSDictionary) {
                linksArray.append(link)
            }
        }
        
//        println("\(canonicalURLString) && \(id) && \(text) && \(threadId)")
        if canonicalURLString != nil && id != nil && text != nil && threadId != nil && user != nil {
            post.canonicalURL   = NSURL(string: canonicalURLString!)
            post.id             = id!.toInt()!
            post.text           = text!
            post.threadId       = threadId!.toInt()!
            post.user           = user!
            post.mentions       = mentionsArray
            post.links          = linksArray
            
            post.attributedText = {
                let tintColor = UIColor(red: 0.206, green: 0.338, blue: 0.586, alpha: 1.000)
                let theAttributedText = NSMutableAttributedString(string: text!)
                for mention in mentionsArray {
                    theAttributedText.addAttribute(NSForegroundColorAttributeName, value: tintColor, range: NSMakeRange(mention.position, mention.length))
                }
                for link in linksArray {
                    theAttributedText.addAttribute(NSForegroundColorAttributeName, value: tintColor, range: NSMakeRange(link.position, link.length))
                }
                
                theAttributedText.addAttribute(NSFontAttributeName, value: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), range: NSMakeRange(0, theAttributedText.length))
                return theAttributedText
                }()
            
        } else {
            return nil
        }
        
        return post
    }
    
}