//
//  NSString+stringStyleUtilities.h
//  PersonFinder
//
//  Created by Bradley Griffith on 6/3/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (stringStyleUtilities)

// Returns NSAttributedString with a styled substring within a given string.
- (NSAttributedString *)styleSubstring:(NSString *)subString
                              withSize:(CGFloat)size andFont:(UIFont *)font;

@end
