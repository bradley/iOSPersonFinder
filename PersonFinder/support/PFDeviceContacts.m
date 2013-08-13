//
//  PFDeviceContacts.m
//  PersonFinder
//
//  Created by Bradley Griffith on 6/3/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import "PFDeviceContacts.h"

@implementation PFDeviceContacts

- (void)accessDeviceContacts:(accessedBlock)success failure:(failedWithError)failure {
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            // First time access has been granted, add the contact
            if (granted) {
                success();
            }
            else {
                failure(@"You'll need to grant us access to view your contacts before you can complete this action.");
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        success();
    }
    else {
        // The user has previously denied access
        failure(@"You'll need to grant us access to view your contacts before you can complete this action. You can do so in your device's privacy settings.");
    }
    CFRelease(addressBookRef);
}

- (void)findContactsWithSuccess:(foundContactsBlock)success {
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    CFIndex personCount = ABAddressBookGetPersonCount(addressBookRef);
    
    NSMutableArray *mutableContacts = [[NSMutableArray alloc] init];
    for (int i = 0; i < personCount; i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        [mutableContacts addObject:[self getPersonDictionary:person]];
    }
    success([NSArray arrayWithArray:mutableContacts]);
    CFRelease(allPeople);
    CFRelease(addressBookRef);
}

- (NSDictionary *)getPersonDictionary:(ABRecordRef)person
{
    NSString *personID = [self getIDForPerson:person];
    NSString *name = [self getNameForPerson:person];
    NSString *email = [self getEmailForPerson:person];
    NSString *phoneNumber = [self getPhoneNumberForPerson:person];
    NSDictionary *person_dictionary = [NSDictionary dictionaryWithObjects:@[personID, name, email, phoneNumber]
                                                                  forKeys:@[@"id", @"name", @"email", @"phone_number"]];
    return person_dictionary;
}

- (NSString *)getIDForPerson:(ABRecordRef)person {
    NSNumber *personID = [NSNumber numberWithInteger: ABRecordGetRecordID(person)];
    return [NSString stringWithFormat:@"%@",personID];
}

- (NSString *)getNameForPerson:(ABRecordRef)person {
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *middleName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    NSMutableString *fullName = [NSMutableString stringWithFormat:@"%@", firstName];
    
    if (middleName) {
        [fullName appendString:[NSString stringWithFormat:@" %@", middleName]];
    }
    if (lastName) {
        [fullName appendString:[NSString stringWithFormat:@" %@", lastName]];
    }
    
    return fullName;
}

- (NSString *)getEmailForPerson:(ABRecordRef)person {
    NSString *email = nil;
    ABMultiValueRef emailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (ABMultiValueGetCount(emailAddresses) > 0) {
        email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, 0);
    }
    else {
        email = @"";
    }
    CFRelease(emailAddresses);
    return email;
}

- (NSString *)getPhoneNumberForPerson:(ABRecordRef)person {
    NSString *phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    }
    else {
        phone = @"";
    }
    CFRelease(phoneNumbers);
    return phone;
}

- (NSArray *)sortContacts:(NSArray *)contacts{
    NSMutableArray *mutableContacts = [NSMutableArray arrayWithArray:contacts];
    NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)];
    [mutableContacts sortUsingDescriptors:[NSMutableArray arrayWithObjects:alphaDesc, nil]];
    return [NSArray arrayWithArray:mutableContacts];
}

@end
