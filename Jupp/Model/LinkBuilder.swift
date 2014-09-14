//
//  LinkBuilder.swift
//  Jupp
//
//  Created by dasdom on 07.09.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation

protocol CanBuildLink {
    func linkFromDictionary(dictionary: NSDictionary) -> Link?
}

class LinkBuilder : CanBuildLink {
    func linkFromDictionary(dictionary: NSDictionary) -> Link? {
        let link = Link()
        
        let length = dictionary["len"] as? Int
        let position = dictionary["pos"] as? Int
        let text = dictionary["text"] as? String
        let url = dictionary["url"] as? String
        
        if length != nil && position != nil && text != nil && url != nil {
            link.length = length!
            link.position = position!
            link.text = text!
            link.url = url!
        } else {
            return nil
        }
        
        return link
    }
}