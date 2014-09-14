//
//  StringDrawingOptions.m
//  Jupp
//
//  Created by dasdom on 06.09.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

#import "StringDrawingOptions.h"

@implementation StringDrawingOptions

+ (NSStringDrawingOptions)combine:(NSStringDrawingOptions)option1 with:(NSStringDrawingOptions)option2
{
    return option1 | option2;
}

@end
