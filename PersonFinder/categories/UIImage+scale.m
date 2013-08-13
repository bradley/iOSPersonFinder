//
//  UIImage+scale.m
//  PersonFinder
//
//  Created by Bradley Griffith on 6/5/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import "UIImage+scale.h"

@implementation UIImage (scale)

-(UIImage*)scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end