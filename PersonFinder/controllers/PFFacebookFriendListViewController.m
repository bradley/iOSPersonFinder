//
//  PFFacebookFriendListViewController.m
//  PersonFinder
//
//  Created by Bradley Griffith on 6/3/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import "PFFacebookFriendListViewController.h"
#import "PFPersonCell.h"
#import "UIImageView+AFNetworking.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

@interface PFFacebookFriendListViewController (){
    BOOL retina;
}
@end

@implementation PFFacebookFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    retina = NO;
    if([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        retina = [[UIScreen mainScreen] scale] == 2.0 ? YES : NO;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFPersonCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *person = [super personAtIndexPath:indexPath];
    
    cell.personImageView.contentMode = UIViewContentModeCenter;
    cell.personImageView.layer.masksToBounds = YES;
    cell.personImageView.layer.cornerRadius = 3.0;
    NSUInteger imageSize = retina ? 80 : 40;
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%i&height=%i", person[@"id"], imageSize, imageSize];
    [cell.personImageView setImageWithURL:[NSURL URLWithString:urlString]
                         placeholderImage:[UIImage imageNamed:@"default_avatar.png"]
                                  options:SDWebImageRefreshCached
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                    if (retina) {
                                        // Scale for retina.
                                        image = [UIImage imageWithCGImage:[image CGImage] scale:2.0 orientation:UIImageOrientationUp];
                                        cell.personImageView.image = image;
                                    }
                                    if (image && cacheType == SDImageCacheTypeNone) {
                                        // Fade in if new uncached image.
                                        cell.personImageView.alpha = 0.0;
                                        [UIView animateWithDuration:0.4
                                                         animations:^{
                                                             cell.personImageView.alpha = 1.0;
                                                         }];
                                    }
     }];

    return cell;
}

@end
