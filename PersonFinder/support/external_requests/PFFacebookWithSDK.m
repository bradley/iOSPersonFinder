//
//  PFFacebookWithSDK.m
//  PersonFinder
//
//  Created by Bradley Griffith on 6/3/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import "PFFacebookWithSDK.h"
#import <FacebookSDK/FacebookSDK.h>

@interface PFFacebookWithSDK ()
@end

@implementation PFFacebookWithSDK

- (void)connectToFacebook:(connectedBlock)success
                  failure:(failedWithError)failure {
    
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         switch (state) {
             case FBSessionStateOpen:
                 NSLog(@"Facebook session state: FBSessionStateOpen");
                 break;
             case FBSessionStateCreatedTokenLoaded:
                 NSLog(@"Facebook session state: FBSessionStateCreatedTokenLoaded");
                 break;
             case FBSessionStateOpenTokenExtended:
                 NSLog(@"Facebook session state: FBSessionStateOpenTokenExtended");
                 break;
             case FBSessionStateClosedLoginFailed:
                 NSLog(@"Facebook session state: FBSessionStateClosedLoginFailed");
                 [FBSession.activeSession closeAndClearTokenInformation];
                 break;
             default:
                 NSLog(@"Facebook session state: not of one of the open or openable types.");
                 break;
         }
         if (error) {
             failure(@"Failed to Connect to Facebook. Facebook might be having problems right now.");
             NSLog(@"Error occured: %@",error.localizedDescription);
         }
         else {
             success();
         }
     }];
}

- (void)findFriends:(foundFriendsBlock)success
            failure:(failedWithError)failure {
    
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        if (error) {
            NSLog(@"Failed to find Friends. Error: %@", error.localizedDescription);
            failure(@"Failed to find Friends. Facebook might be having problems right now.");
            return;
        }
        
        success([result objectForKey:@"data"]);
    }];
}

@end