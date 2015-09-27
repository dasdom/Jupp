//
//  LinkExtractorTests.swift
//  Jupp
//
//  Created by dasdom on 11.06.14.
//  Copyright (c) 2014 dasdom. All rights reserved.
//

import XCTest
import Jupp

class LinkExtractorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testOneMarkdownLinkIsExtracted() {
        let text = "My blog can be found at [dasdev.de](http://dasdev.de). Check it out."
        let linkExtractor = LinkExtractor()
        let (postTest, linkEntities) = linkExtractor.extractLinks(text)
        XCTAssertEqual(linkEntities.count, 1, "Should find one link")
        XCTAssertEqual(postTest, "My blog can be found at dasdev.de. Check it out.")
        
        var linkEntity = linkEntities[0]
        print("linkEntity \(linkEntity)")
//        XCTAssertEqualObjects(linkEntity["url"]!, "dasdev.de")
        XCTAssertEqual(linkEntity["url"]!, "http://dasdev.de")
        XCTAssertEqual(linkEntity["pos"]!, "24")
        XCTAssertEqual(linkEntity["len"]!, "9")
    }
    
    func testSecondMarkdownLinkIsExtracted() {
        let text = "My blog [dasdev.de](http://dasdev.de). My wifes [blog](http://vegan-und-lecker.de)"
        let linkExtractor = LinkExtractor()
        let (postTest, linkEntities) = linkExtractor.extractLinks(text)
        XCTAssertEqual(linkEntities.count, 2)
        XCTAssertEqual(postTest, "My blog dasdev.de. My wifes blog")
        
        let linkEntity = linkEntities[1]
        XCTAssertEqual(linkEntity["url"]!, "http://vegan-und-lecker.de")
        XCTAssertEqual(linkEntity["pos"]!, "28")
        XCTAssertEqual(linkEntity["len"]!, "4")
    }
    
    func testNoLinkIsExtracted() {
        let text = "This is my blog: dasdev.de"
        let linkExtractor = LinkExtractor()
        let (postTest, linkEntities) = linkExtractor.extractLinks(text)
        
        XCTAssertEqual(linkEntities.count, 0, "Should find no links")
        XCTAssertEqual(postTest, "This is my blog: dasdev.de")
    }
    
//    func testBracesNotBelongingToALinkAreIgnored() {
//        let text = "My [blog] can be found at [dasdev.de](http://dasdev.de). Check it out."
//        let linkExtractor = LinkExtractor()
//        let (postTest, linkEntities) = linkExtractor.extractLinks(text)
//        XCTAssertEqual(linkEntities.count, 1, "Should find one link")
//        XCTAssertEqualObjects(postTest, "My [blog] can be found at dasdev.de. Check it out.")
//        
//        var linkEntity = linkEntities[0]
//        XCTAssertEqualObjects(linkEntity.linkText, "dasdev.de")
//        XCTAssertEqualObjects(linkEntity.linkURLString, "http://dasdev.de")
//        XCTAssertEqual(linkEntity.linkRange.location, 27)
//        XCTAssertEqual(linkEntity.linkRange.length, 9)
//    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
