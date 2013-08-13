//
//  PFPersonCell.h
//  PersonFinder
//
//  Created by Bradley Griffith on 6/3/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFPersonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *personName;
@property (weak, nonatomic) IBOutlet UIImageView *personImageView;
@property (weak, nonatomic) IBOutlet UILabel *selectionCheckMark;

@end
