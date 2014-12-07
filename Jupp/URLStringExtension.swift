//
//  URLStringExtension.swift
//  Jupp
//
//  Created by dasdom on 06.12.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation

extension String {
    
    func isURL() -> Bool {
        let url = NSURL(string: self)
        return url != nil
    }
    
}