//
//  PFFacebookWithSocialFramework.h
//  PersonFinder
//
//  Created by Bradley Griffith on 6/3/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

typedef void (^connectedBlock)();
typedef void (^foundFriendsBlock)(NSArray *friends);
typedef void (^failedWithError)(NSString *errorMessage);

@interface PFFacebookWithSocialFramework : NSObject

- (void)connectToFacebook:(connectedBlock)success
                  failure:(failedWithError)failure;

- (void)findFriendsForAccount:(ACAccount *)facebookAccount
                      success:(foundFriendsBlock)success
                      failure:(failedWithError)failure;

- (void)renewCredentials;

@end