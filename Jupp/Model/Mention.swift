//
//  Mention.swift
//  GlobalADN
//
//  Created by dasdom on 05.07.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation

class Mention : NSCoding {
    var id = 0
    var length = 0
    var position = 0
    var name = ""
    var isLeading = false

    struct Constants {
        static let idKey = "idKey"
        static let lengthKey = "lengthKey"
        static let positionKey = "positionKey"
        static let nameKey = "nameKey"
        static let isLeadingKey = "isLeadingKey"
    }
    
    init() {
        
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeIntegerForKey(Constants.idKey)
        length = aDecoder.decodeIntegerForKey(Constants.lengthKey)
        position = aDecoder.decodeIntegerForKey(Constants.positionKey)
        name = aDecoder.decodeObjectForKey(Constants.nameKey) as String
        isLeading = aDecoder.decodeBoolForKey(Constants.isLeadingKey)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(id, forKey: Constants.idKey)
        aCoder.encodeInteger(length, forKey: Constants.lengthKey)
        aCoder.encodeInteger(position, forKey: Constants.positionKey)
        aCoder.encodeObject(name, forKey: Constants.nameKey)
        aCoder.encodeBool(isLeading, forKey: Constants.isLeadingKey)
    }
}