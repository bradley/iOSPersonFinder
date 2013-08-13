//
//  PFDeviceContacts.h
//  PersonFinder
//
//  Created by Bradley Griffith on 6/3/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

typedef void (^accessedBlock)();
typedef void (^foundContactsBlock)(NSArray *contacts);
typedef void (^failedWithError)(NSString *errorMessage);

@interface PFDeviceContacts : NSObject

- (void)accessDeviceContacts:(accessedBlock)success
                     failure:(failedWithError)failure;

- (void)findContactsWithSuccess:(foundContactsBlock)success;

@end
