//
//  KCFavoritesViewController.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/11/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCFavoritesViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSArray *favorites;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
