//
//  MentionBuilder.swift
//  GlobalADN
//
//  Created by dasdom on 05.07.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation

protocol CanBuildMention {
    func mentionFromDictionary(dictionary: NSDictionary) -> Mention?
}

class MentionBuilder : CanBuildMention {
    func mentionFromDictionary(dictionary: NSDictionary) -> Mention? {
        var mention = Mention()
        
        let id = dictionary["id"] as? String
        let name = dictionary["name"] as? String
        let position = dictionary["pos"] as? Int
        let lenght = dictionary["len"] as? Int
        let isLeading = dictionary["is_leading"] as? Int

//        println("\(id) && \(name) && \(position) && \(lenght) && \(isLeading)")
        if id != nil && name != nil && position != nil && lenght != nil {
            mention.id = id!.toInt()!
            mention.name = name!
            mention.position = position!
            mention.length = lenght!
            mention.isLeading = isLeading > 0 ? true : false
        } else {
            return nil
        }
        
//        println("mention: \(mention)")
        return mention
    }
}