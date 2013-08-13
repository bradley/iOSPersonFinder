//
//  PFMenuViewController.m
//  PersonFinder
//
//  Created by Bradley Griffith on 6/3/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import "PFMenuViewController.h"
#import "PFDeviceContacts.h"
#import "PFFacebookWithSDK.h"
#import "PFFacebookWithSocialFramework.h"

#import "PFContactListViewController.h"
#import "PFFacebookFriendListViewController.h"

#import "SVProgressHUD.h"
#import <Accounts/Accounts.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>

@interface PFMenuViewController ()
@property (nonatomic, strong)ACAccountStore *accountStore;
@property (nonatomic, strong)NSArray *people;
@end

@implementation PFMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupAccountStore];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAccountStoreChanged:)
                                                 name:ACAccountStoreDidChangeNotification
                                               object:nil];
}

- (void)setupAccountStore {
    _accountStore = [[ACAccountStore alloc] init];
}

- (void)onAccountStoreChanged:(NSNotification *)notification {
    // When account store changes, the user could have added or removed an account.
    [self setupAccountStore];
    
    // There is a chance that we have a presented view controller when this
    // change takes place. In this situation we need to dismiss the presented view controller.
    if (self.navigationController.visibleViewController != [self.navigationController.viewControllers objectAtIndex:0]){
        // Leave friend list unless we are using the SDK and not the Social Framework.
        if (![[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:@"FBAccessTokenInformationKey"]){
            [self.navigationController popToRootViewControllerAnimated:YES];
            [SVProgressHUD showErrorWithStatus:@"Changes were made to the Facebook account linked with your device."];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToFacebookFriendList"]) {
        PFFacebookFriendListViewController *destViewController = segue.destinationViewController;
        
        destViewController.personList = [NSMutableArray arrayWithArray:_people];
    }
    else if ([segue.identifier isEqualToString:@"segueToContactList"]) {
        PFContactListViewController *destViewController = segue.destinationViewController;
        
        destViewController.personList = [NSMutableArray arrayWithArray:_people];
    }
}


- (IBAction)showContacts:(id)sender {
    [self establishAccessToDeviceContacts];
}

- (IBAction)showFacebookFriends:(id)sender {
    
    ACAccountType *facebookAccountType  = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSArray *accounts = [_accountStore accountsWithAccountType:facebookAccountType];
    
    if ([[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:@"FBAccessTokenInformationKey"]){
        // Only give SDK connection priority over Social Framework connection if
        // the user has previously signed in using this method.
        [self establishFacebookConnectionUsingSDK];
    }
    else if ([accounts count] > 0) {
        [self establishFacebookConnectionUsingSocialFramework];
    }
    else {
        [self establishFacebookConnectionUsingSDK];
    }
}

#pragma mark - use device contacts build people array

- (void)establishAccessToDeviceContacts {
    NSLog(@"Attempting to access contacts on this device.");
    PFDeviceContacts *deviceContactsAccess = [[PFDeviceContacts alloc] init];
    
    [deviceContactsAccess accessDeviceContacts:^{
        [self useDeviceToGetContacts];
    } failure:^(NSString *errorMessage) {
        [SVProgressHUD showErrorWithStatus:errorMessage];
    }];
}

- (void)useDeviceToGetContacts {
    PFDeviceContacts *deviceContactsAccess = [[PFDeviceContacts alloc] init];
    
    [deviceContactsAccess findContactsWithSuccess:^(NSArray *contacts) {
        _people = contacts;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"segueToContactList" sender:self];
        });
    }];
}

#pragma mark - use facebook sdk connection to build people array

- (void)establishFacebookConnectionUsingSDK {
    [SVProgressHUD show];
    
    NSLog(@"Attempting to connect to Facebook using SDK.");
    PFFacebookWithSDK *sdkConnection = [[PFFacebookWithSDK alloc] init];
    
    [sdkConnection connectToFacebook:^{
        if (FBSession.activeSession.state == FBSessionStateOpen) {
            // Sometimes we have a cached authorization token that can't be used immediately.
            // Hence, we ensure that our state is open before requesting friends.
            // Facebook SDK will call this twice (failing once) if it needs to refresh the token.
            
            [self useSDKToFindFacebookFriends];
        }
        else {
            [SVProgressHUD dismiss];
        }
    } failure:^(NSString *errorMessage) {
        [SVProgressHUD showErrorWithStatus:@"Failed to connect to Facebook using SDK."];
    }];
}

- (void)useSDKToFindFacebookFriends {
    PFFacebookWithSDK *sdkConnection = [[PFFacebookWithSDK alloc] init];
    
    [sdkConnection findFriends:^(NSArray *friends) {
        _people = friends;
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        [self performSegueWithIdentifier:@"segueToFacebookFriendList" sender:self];
    } failure:^(NSString *errorMessage) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", errorMessage]];
    }];
}

#pragma mark - use social framework connection with facebook to build people array

- (void)establishFacebookConnectionUsingSocialFramework {
    [SVProgressHUD show];
    NSLog(@"Attempt to connect to Facebook using Facebook account in Social Framework.");
    PFFacebookWithSocialFramework *frameworkConnection = [[PFFacebookWithSocialFramework alloc] init];
    
    [frameworkConnection connectToFacebook:^{
        
        ACAccountType *facebookAccountType  = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        ACAccount *fbAccount = [[self.accountStore accountsWithAccountType:facebookAccountType] lastObject];
        
        [self useSocialFrameworkToFindFacebookFriendsFor:fbAccount];
        
    } failure:^(NSString *errorMessage) {
        [SVProgressHUD showErrorWithStatus:@"Failed to connect to Facebook using account stored on this device."];
    }];
}


- (void)useSocialFrameworkToFindFacebookFriendsFor:(ACAccount *)account {
    
    PFFacebookWithSocialFramework *frameworkConnection = [[PFFacebookWithSocialFramework alloc] init];
    
    [frameworkConnection findFriendsForAccount:account success:^(NSArray *friends) {
        _people = friends;
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self performSegueWithIdentifier:@"segueToFacebookFriendList" sender:self];
        });
    } failure:^(NSString *errorMessage) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", errorMessage]];
    }];
}

@end
