//
//  NSAttributedString+HeightCalculation.m
//  Jupp
//
//  Created by dasdom on 07.09.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

#import "NSAttributedString+HeightCalculation.h"
#import <CoreText/CoreText.h>

@implementation NSAttributedString (HeightCalculation)

- (CGFloat)heightForWidth:(CGFloat)inWidth
{
    CGFloat H = 0;
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString( (CFMutableAttributedStringRef) self);
    
    CGRect box = CGRectMake(0,0, inWidth, CGFLOAT_MAX);
    
    CFIndex startIndex = 0;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, box);
    
    // Create a frame for this column and draw it.
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), path, NULL);
    
    // Start the next frame at the first character not visible in this frame.
    //CFRange frameRange = CTFrameGetVisibleStringRange(frame);
    //startIndex += frameRange.length;
    
    CFArrayRef lineArray = CTFrameGetLines(frame);
    CFIndex j = 0, lineCount = CFArrayGetCount(lineArray);
    CGFloat h, ascent, descent, leading;
    
    for (j=0; j < lineCount; j++)
    {
        CTLineRef currentLine = (CTLineRef)CFArrayGetValueAtIndex(lineArray, j);
        CTLineGetTypographicBounds(currentLine, &ascent, &descent, &leading);
        h = ascent + descent + leading;
        H+=h;
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    
    return H;
}

@end
