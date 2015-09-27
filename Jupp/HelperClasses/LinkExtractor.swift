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
        
        repeat {
            currentlyScannedString = stringToScan
            let scanner = NSScanner(string: currentlyScannedString!)
            scanner.charactersToBeSkipped = NSCharacterSet(charactersInString: "[]()")
            
            var string: NSString? = nil
            scannerDidScan = scanner.scanUpToString("[", intoString: &string)
            stringToScan = string! as String
            let location = scanner.scanLocation-1
            
            var link: String? = nil
            var range: NSRange? = nil
            scannerDidScan = scanner.scanUpToString("](", intoString: &string)
            if scannerDidScan {
                link = (string! as String)
                range = NSRange(location: location, length: link!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                stringToScan += string! as String
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
            if (currentlyScannedString!).characters.count > scanner.scanLocation {
                endIndex++
            }
            let index = currentlyScannedString!.startIndex.advancedBy(endIndex)
            
            let remainingString: String? = currentlyScannedString!.substringFromIndex(index)
//            println("remainingString: \(remainingString)")
            stringToScan += remainingString!
            
            print("stringToScan \(stringToScan)")
            
//            var linkEntity = LinkEntity(linkText: link!, linkURLString: urlString!, linkRange: range!)
            let linkDictionary = ["url": urlString!, "pos": "\(range!.location)", "len": "\(range!.length)"]
            print("linkDictionary \(linkDictionary)")
            
            linkArray.append(linkDictionary)
        } while scannerDidScan
        
        let stringToReturn = stringToScan.substringFromIndex(stringToScan.startIndex.advancedBy(1))
//        println("string: \(stringToReturn) linkArray \(linkArray)")
        
        // Remove the space at the beginning.
        return (stringToReturn, linkArray)
    }
}
