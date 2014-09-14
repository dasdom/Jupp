//
//  MetaBuilder.swift
//  GlobalADN
//
//  Created by dasdom on 06.07.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation

struct MetaBuilder {
    func metaFromDictionary(dictionary: NSDictionary) -> Meta? {
        var meta: Meta?
        
        let code = dictionary["code"] as? Int
        let maxId = dictionary["max_id"] as? String
        let minId = dictionary["min_id"] as? String
        let more = dictionary["more"] as? Int
        
        println("\(code) && \(maxId) && \(minId) && \(more)")
        if code != nil && maxId != nil && minId != nil && more != nil {
            meta = Meta(code: code!, maxId: maxId!.toInt()!, minId: minId!.toInt()!, more: more! == 1)
        }
        
        return meta
    }
}