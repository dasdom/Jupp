//
//  Link.swift
//  Jupp
//
//  Created by dasdom on 07.09.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation

class Link {
    var length = 0
    var position = 0
    var text = ""
    var url = ""
    
    struct Constants {
        static let lengthKey = "lengthKey"
        static let positionKey = "positionKey"
        static let textKey = "textKey"
        static let urlKey = "urlKey"
    }
    
    init() {
        
    }
    
    required init(coder aDecoder: NSCoder) {
        length = aDecoder.decodeIntegerForKey(Constants.lengthKey)
        position = aDecoder.decodeIntegerForKey(Constants.positionKey)
        text = aDecoder.decodeObjectForKey(Constants.textKey) as! String
        url = aDecoder.decodeObjectForKey(Constants.urlKey) as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(length, forKey: Constants.lengthKey)
        aCoder.encodeInteger(position, forKey: Constants.positionKey)
        aCoder.encodeObject(text, forKey: Constants.textKey)
        aCoder.encodeObject(url, forKey: Constants.urlKey)
    }
}