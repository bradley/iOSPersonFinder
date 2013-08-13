//
//  PFContactListViewController.m
//  PersonFinder
//
//  Created by Bradley Griffith on 6/3/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import "PFContactListViewController.h"
#import "PFPersonCell.h"
#import "UIImage+scale.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>

@interface PFContactListViewController () {
    BOOL retina;
}
@property (nonatomic, strong)NSMutableDictionary *imageCache;
@end

@implementation PFContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    retina = NO;
    if([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        retina = [[UIScreen mainScreen] scale] == 2.0 ? YES : NO;
}

- (NSMutableDictionary *)imageCache {
    if (!_imageCache) {
        _imageCache = [NSMutableDictionary dictionary];
    }
    return _imageCache;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFPersonCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *person = [super personAtIndexPath:indexPath];
    
    cell.personImageView.contentMode = UIViewContentModeCenter;
    cell.personImageView.layer.masksToBounds = YES;
    cell.personImageView.layer.cornerRadius = 3.0;    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    UIImage *personImage = [imageCache imageFromMemoryCacheForKey:person[@"id"]];
    UIImage *defaultPhoto = [UIImage imageNamed:@"default_avatar.png"];
    if (personImage) {
        cell.personImageView.image = personImage;
    }
    else {
        [self asynchSetImageForUser:person atIndex:indexPath];
        cell.personImageView.image = defaultPhoto;
    }
    return cell;
}

- (void)asynchSetImageForUser:(NSDictionary *)contact atIndex:(NSIndexPath *)indexPath {
    
    dispatch_queue_t queue = dispatch_queue_create("yakamoto.UserContacts", NULL);
    dispatch_queue_t main = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBookRef, [contact[@"id"] intValue]);
        
        NSData *imgData = (__bridge_transfer NSData *) ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        
        UIImage *image = [UIImage imageWithData:imgData];
        
        if (retina) {
            // Scale for retina.
            UIImage *scaledImage = [image scaleToSize:CGSizeMake(80.0f, 80.0f)];
            image = [UIImage imageWithCGImage:[scaledImage CGImage] scale:2.0 orientation:UIImageOrientationUp];
        }
        else {
            image = [image scaleToSize:CGSizeMake(80.0f, 80.0f)];
        }
        
        if (image) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:contact[@"id"] toDisk:NO];
        }
        
        dispatch_sync(main, ^{
            NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
            if ([visiblePaths containsObject:indexPath]) {
                NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
                [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation: UITableViewRowAnimationFade];
                // because we cached the image, cellForRow... will see it and run fast
            }
        });
        CFRelease(addressBookRef);
    });
}


@end
