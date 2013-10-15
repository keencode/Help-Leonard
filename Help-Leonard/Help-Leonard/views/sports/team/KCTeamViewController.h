//
//  KCTeamViewController.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/14/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"

@interface KCTeamViewController : UITableViewController

@property (nonatomic, strong) Team *team;
@property (nonatomic, weak) IBOutlet UITableViewCell *favoriteCell;

- (void)addFavorite;
- (void)removeFavorite;

@end
