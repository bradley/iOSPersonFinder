//
//  PFAppDelegate.h
//  PersonFinder
//
//  Created by Bradley Griffith on 6/1/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
