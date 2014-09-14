//
//  User.swift
//  GlobalADN
//
//  Created by dasdom on 20.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation

class User : NSCoding {
    var avatarURL = NSURL()
    var id = 0
    var name = ""
    var username = ""
    
    struct Constants {
        static let avatarURLKey = "avatarURLKey"
        static let idKey = "idKey"
        static let nameKey = "nameKey"
        static let usernameKey = "usernameKey"
    }
    
    init() {
        
    }
    
    required init(coder aDecoder: NSCoder) {
        avatarURL = aDecoder.decodeObjectForKey(Constants.avatarURLKey) as NSURL
        id = aDecoder.decodeIntegerForKey(Constants.idKey)
        name = aDecoder.decodeObjectForKey(Constants.nameKey) as String
        username = aDecoder.decodeObjectForKey(Constants.usernameKey) as String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(avatarURL, forKey: Constants.avatarURLKey)
        aCoder.encodeInteger(id, forKey: Constants.idKey)
        aCoder.encodeObject(name, forKey: Constants.nameKey)
        aCoder.encodeObject(username, forKey: Constants.usernameKey)
    }
}