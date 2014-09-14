//
//  HeightCalculator.swift
//  Jupp
//
//  Created by dasdom on 07.09.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation

//func heightForAttributedString(attributedString: NSAttributedString, forWidth: CGFloat) -> CGFloat {
//    let height = 0
//    
//    let box = CGRectMake(0.0, 0.0, forWidth, CGFloat.max)
//    
//    let startIndex: CFIndex = 0
//    
//    let path = CGPathCreateMutable()
//    CGPathAddRect(path, nil, box)
//    
//    let frame = CTFramesetterCreateFrame(CTFramesetterCreateWithAttributedString(attributedString), CFRangeMake(startIndex, 0), path, nil)
//    
//    let lineArray = CTFrameGetLines(frame)
//    var j: CFIndex = 0
//    let lineCount = CFArrayGetCount(lineArray)
//    
//    var h: CGFloat
//    var ascent: CGFloat
//    var descent: CGFloat
//    var leading: CGFloat
//    
//    for j = 0; j < lineCount; j++ {
//        let currentLine = CFArrayGetValueAtIndex(lineArray, j) as CTLineRef
//        CTLineGetTypographicBounds(currentLine, &ascent, &descent, &leading)
//        
//    }
//    
//}