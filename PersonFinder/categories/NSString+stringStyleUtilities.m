//
//  NSString+stringStyleUtilities.m
//  PersonFinder
//
//  Created by Bradley Griffith on 6/3/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import "NSString+stringStyleUtilities.h"

@implementation NSString (stringStyleUtilities)

- (NSAttributedString *)styleSubstring:(NSString *)subString
                              withSize:(CGFloat)size andFont:(UIFont *)font {
    NSMutableAttributedString *styledString = [[NSMutableAttributedString alloc] initWithString:self];
    
    if (subString.length > 0 && self.length > 0) {
        
        CGFloat highlightSize = size ?: 17.0;
        UIFont *highlightFont = font ?: [UIFont boldSystemFontOfSize:highlightSize];
        
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                highlightFont, NSFontAttributeName, nil];
        NSRange range = [self rangeOfString:subString
                                    options:(NSCaseInsensitiveSearch+NSDiacriticInsensitiveSearch)];
        
        
        [styledString addAttributes:attrs range:range];
    }
    
    return styledString;
}

@end
