//
//  LinkExtractor.swift
//  Jupp
//
//  Created by dasdom on 11.06.14.
//  Copyright (c) 2014 dasdom. All rights reserved.
//

import Foundation

public class LinkExtractor {
    
    public init() {
        
    }
    
    public func extractLinks(fromString: String) -> (postString: String, linkArray: Array<Dictionary<String, String>>) {

        var linkArray = Array<Dictionary<String, String>>()
        
        // Add a space at the beginning to catch also links starting at zero
        var stringToScan = " \(fromString)"
        var currentlyScannedString: String?
        var scannerDidScan = true
        
        do {
            currentlyScannedString = stringToScan
            let scanner = NSScanner(string: currentlyScannedString!)
            scanner.charactersToBeSkipped = NSCharacterSet(charactersInString: "[]()")
            
            var string: NSString? = nil
            scannerDidScan = scanner.scanUpToString("[", intoString: &string)
            stringToScan = string! as! String
            var location = scanner.scanLocation-1
            
            var link: String? = nil
            var range: NSRange? = nil
            scannerDidScan = scanner.scanUpToString("](", intoString: &string)
            if scannerDidScan {
                link = (string! as! String)
                range = NSRange(location: location, length: link!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                stringToScan += string! as! String
            } else {
                continue
            }
        
            var urlString: String? = nil
            scannerDidScan = scanner.scanUpToString(")", intoString: &string)
            if scannerDidScan {
                urlString = (string as! String)
            } else {
                continue
            }
//            println("currentlyScannedString count: \(countElements(currentlyScannedString!))")
            
            var endIndex = scanner.scanLocation
            if count(currentlyScannedString!) > scanner.scanLocation {
                endIndex++
            }
            let index = advance(currentlyScannedString!.startIndex, endIndex)
            
            var remainingString: String? = currentlyScannedString!.substringFromIndex(index)
//            println("remainingString: \(remainingString)")
            stringToScan += remainingString!
            
            println("stringToScan \(stringToScan)")
            
//            var linkEntity = LinkEntity(linkText: link!, linkURLString: urlString!, linkRange: range!)
            let linkDictionary = ["url": urlString!, "pos": "\(range!.location)", "len": "\(range!.length)"]
            println("linkDictionary \(linkDictionary)")
            
            linkArray.append(linkDictionary)
        } while scannerDidScan
        
        let stringToReturn = stringToScan.substringFromIndex(advance(stringToScan.startIndex, 1))
//        println("string: \(stringToReturn) linkArray \(linkArray)")
        
        // Remove the space at the beginning.
        return (stringToReturn, linkArray)
    }
}
