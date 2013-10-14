//
//  KCTeamsListViewController.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "League.h"

@interface KCTeamsListViewController : UITableViewController

@property (nonatomic, strong) NSString *sportName;
@property (nonatomic, strong) League *league;
@property (nonatomic, strong) NSArray *teams;

@end
