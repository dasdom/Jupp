//
//  StringDrawingOptions.h
//  Jupp
//
//  Created by dasdom on 06.09.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StringDrawingOptions : NSObject
+ (NSStringDrawingOptions)combine:(NSStringDrawingOptions)option1 with:(NSStringDrawingOptions)option2;
@end
