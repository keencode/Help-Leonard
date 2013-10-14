//
//  KCHeadlinesViewController.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/11/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "KCHeadlinesViewController.h"
#import "Headline+Fetch.h"
#import "Headline+Network.h"
#import "KCDateHelper.h"
#import "KCHeadlineDetailViewController.h"

@interface KCHeadlinesViewController ()

@end

@implementation KCHeadlinesViewController

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

    self.headlines = [Headline fetchRecentHeadlines];
    
    [Headline remoteHeadlinesOnSuccess:^(NSArray *headlines) {
        self.headlines = headlines;
        [self.tableView reloadData];
    } onFailure:^(NSError *error) {
        //
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.headlines count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HeadlineCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Headline *headline = [self.headlines objectAtIndex:indexPath.row];
    cell.textLabel.text = headline.headline;
    cell.detailTextLabel.text = [KCDateHelper formattedStringFromDate:headline.published];
    return cell;
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
    if ([segue.identifier isEqualToString:@"showHeadlineDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        KCHeadlineDetailViewController *destViewController = segue.destinationViewController;
        destViewController.headline = [self.headlines objectAtIndex:indexPath.section];
    }
}

@end
