//
//  UserBuilder.swift
//  GlobalADN
//
//  Created by dasdom on 20.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation

protocol CanBuildUser {
    func userFromDictionary(dictionary: NSDictionary) -> User?
}

class UserBuilder : CanBuildUser {
    func userFromDictionary(dictionary: NSDictionary) -> User? {
        var user = User()
        
        var avatarURLString: String?
        if let avatarDictionary = dictionary["avatar_image"] as? NSDictionary {
            avatarURLString = avatarDictionary["url"] as? String
        }
        let id = dictionary["id"] as? String
        let name = dictionary["name"] as? String
        let username = dictionary["username"] as? String
        
//        println("\(avatarURLString) && \(id) && \(name) && \(username)")
        if avatarURLString != nil && id != nil && username != nil {
            user.avatarURL = NSURL(string: avatarURLString!)
            user.id = id!.toInt()!
            user.username = username!
            if name != nil {
                user.name = name!
            }
        } else {
            return nil
        }
        
        return user
    }
}