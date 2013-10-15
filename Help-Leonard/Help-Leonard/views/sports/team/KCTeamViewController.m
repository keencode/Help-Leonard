//
//  KCTeamViewController.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/14/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "KCTeamViewController.h"
#import "KCTeamDetailsViewController.h"
#import "KCTeamNewsViewController.h"
#import "Team+Network.h"

#define kFavoriteCellSectionIndex 1
#define kFavoriteCellRowIndex 0

@interface KCTeamViewController ()

@end

@implementation KCTeamViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.team.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == kFavoriteCellSectionIndex && indexPath.row == kFavoriteCellRowIndex) {
        [self updateFavoriteCell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kFavoriteCellSectionIndex && indexPath.row == kFavoriteCellRowIndex) {
        if ([self.team.favorite boolValue]) {
            [self removeFavorite];
        } else {
            [self addFavorite];
        }
    }
}

- (void)updateFavoriteCell
{
    if (![self.team.favorite boolValue]) {
        self.favoriteCell.textLabel.text = @"Add to Favorites";
    } else {
        self.favoriteCell.textLabel.text = @"Remove from Favorites";
    }
}

- (void)addFavorite
{
    __block id weakSelf = self;
    
   [self.team addFavoriteOnSuccess:^(BOOL success) {
       if (success) {
           [weakSelf updateFavoriteCell];
       } else {
           //
       }
   } onFailure:^(NSError *error) {
       //
   }];
}

- (void)removeFavorite
{
    __block id weakSelf = self;
    
    [self.team removeFavoriteOnSuccess:^(BOOL success) {
        if (success) {
            [weakSelf updateFavoriteCell];
        } else {
            //
        }
    } onFailure:^(NSError *error) {
        //
    }];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTeamDetails"]) {
        KCTeamDetailsViewController *destViewController = segue.destinationViewController;
        destViewController.team = self.team;
    }
    else if ([segue.identifier isEqualToString:@"showTeamNews"]) {
        KCTeamNewsViewController *destViewController = segue.destinationViewController;
        destViewController.team = self.team;
    }
}

@end
