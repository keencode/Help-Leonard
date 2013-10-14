//
//  KCTeamNewsViewController.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"

@interface KCTeamNewsViewController : UITableViewController

@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) NSArray *headlines;

@end
