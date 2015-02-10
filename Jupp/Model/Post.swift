//
//  Post.swift
//  GlobalADN
//
//  Created by dasdom on 18.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit

@objc class Post : NSCoding {
    var canonicalURL    = NSURL()
    var id              = 0
    var text            = ""
    var threadId        = 0
    var user            = User()
    var mentions        = [Mention]()
    var links           = [Link]()
    var attributedText  = NSAttributedString()
    
    struct Constants {
        static let canonicalURLKey = "canonicalURLKey"
        static let idKey = "idKey"
        static let textKey = "textKey"
        static let threadIdKey = "threadIdKey"
        static let userKey = "userKey"
        static let mentionsKey = "mentionsKey"
        static let linksKey = "linksKey"
        static let attributedTextKey = "attributedTextKey"
    }
    
    init() {
        
    }
    
    required init(coder aDecoder: NSCoder) {
        canonicalURL = aDecoder.decodeObjectForKey(Constants.canonicalURLKey) as! NSURL
        id = aDecoder.decodeIntegerForKey(Constants.idKey)
        text = aDecoder.decodeObjectForKey(Constants.textKey) as! String
        threadId = aDecoder.decodeIntegerForKey(Constants.threadIdKey)
        user = aDecoder.decodeObjectForKey(Constants.userKey) as! User
        mentions = aDecoder.decodeObjectForKey(Constants.mentionsKey) as! [Mention]
        links = aDecoder.decodeObjectForKey(Constants.linksKey) as! [Link]
        attributedText = aDecoder.decodeObjectForKey(Constants.attributedTextKey) as! NSAttributedString
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(canonicalURL, forKey: Constants.canonicalURLKey)
        aCoder.encodeInteger(id, forKey: Constants.idKey)
        aCoder.encodeObject(text, forKey: Constants.textKey)
        aCoder.encodeInteger(threadId, forKey: Constants.threadIdKey)
        aCoder.encodeObject(user, forKey: Constants.userKey)
        aCoder.encodeObject(mentions, forKey: Constants.mentionsKey)
        aCoder.encodeObject(attributedText, forKey: Constants.attributedTextKey)
    }
}