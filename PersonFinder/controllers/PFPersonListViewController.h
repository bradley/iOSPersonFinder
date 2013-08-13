//
//  PFPersonListViewController.h
//  PersonFinder
//
//  Created by Bradley Griffith on 6/1/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFPersonListViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)NSMutableArray *personList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (NSDictionary *)personAtIndexPath:(NSIndexPath *)indexPath;
@end