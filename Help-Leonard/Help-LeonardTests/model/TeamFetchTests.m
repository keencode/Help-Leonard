//
//  TeamFetchTests.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataTestHelper.h"
#import "FixtureHelper.h"
#import "Team+Fetch.h"
#import "Team+Network.h"

@interface TeamFetchTests : XCTestCase
{
    NSManagedObjectContext *managedObjectContext;
    NSArray *teamsJSON;
}

@end

@implementation TeamFetchTests

- (void)setUp
{
    [super setUp];
    
    CoreDataTestHelper *coreDataHelper = [[CoreDataTestHelper alloc] init];
    managedObjectContext = coreDataHelper.managedObjectContext;
    
    FixtureHelper *fixtureHelper = [[FixtureHelper alloc] init];
    NSData *testData = [fixtureHelper validDataFromTeamsFixture];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    
    NSDictionary *sportInfo = [[jsonData objectForKey:@"sports"] objectAtIndex:0];
    if (sportInfo) {
        NSDictionary *leagueInfo = [[sportInfo objectForKey:@"leagues"] objectAtIndex:0];
        
        if (leagueInfo) {
            if ([leagueInfo objectForKey:@"teams"]) {
                teamsJSON = [leagueInfo objectForKey:@"teams"];
            }
        }
    }
}

- (void)tearDown
{
    managedObjectContext = nil;
    teamsJSON = nil;
    
    [super tearDown];
}

#pragma mark - IDsFromJSON

- (void)testIDsFromJSONhouldReturnANonNilObject
{
    id idsFromJSON = [Team IDsFromJSON:teamsJSON];
    
    XCTAssertNotNil(idsFromJSON, @"idsFromJSON should NOT be nil");
}

- (void)testIDsFromJSONShouldReturnAnArray
{
    id idsFromJSON = [Team IDsFromJSON:teamsJSON];
    
    XCTAssertTrue([idsFromJSON isKindOfClass:[NSArray class]], @"idsFromJSON should be an NSArray");
}

- (void)testIDsFromJSONShouldReturnExpectedCount
{
    NSUInteger expectedIDsCount = [teamsJSON count];
    
    NSArray *idsFromJSON = [Team IDsFromJSON:teamsJSON];
    
    XCTAssertEqual([idsFromJSON count], expectedIDsCount, @"idsFromJSON count should equal expectedIDsCount");
}

- (void)testIDsFromJSONShouldReturnExpectedID
{
    NSString *expectedFirstID = [[teamsJSON objectAtIndex:0] objectForKey:@"uid"];
    
    NSArray *idsFromJSON = [Team IDsFromJSON:teamsJSON];
    NSString *firstID = [idsFromJSON objectAtIndex:0];
    
    XCTAssertEqualObjects(firstID, expectedFirstID, @"firstID should match expectedFirstID");
}

#pragma mark - localTeamsFromJSON

- (void)testLocalTeamsFromJSONShouldReturnANonNilObject
{
    id teams = [Team localTeamsFromJSON:teamsJSON inContext:managedObjectContext];
    
    XCTAssertNotNil(teams, @"teams should NOT be nil");
}

- (void)testLocalTeamsFromJSONShouldReturnAnArray
{
    id teams = [Team localTeamsFromJSON:teamsJSON inContext:managedObjectContext];
    
    XCTAssertTrue([teams isKindOfClass:[NSArray class]], @"teams should be an NSArray");
}

- (void)testLocalTeamsFromJSONShouldReturnExpectedTeam
{
    NSArray *ids = [Team IDsFromJSON:teamsJSON];
    Team *team1 = [Team MR_createInContext:managedObjectContext];
    team1.uid = [ids objectAtIndex:0];
    
    NSArray *teams = [Team localTeamsFromJSON:teamsJSON inContext:managedObjectContext];
    
    XCTAssertTrue([teams containsObject:team1], @"teams should contain team1");
}

- (void)testLocalTeamsFromJSONShouldReturnExpectedCount
{
    NSArray *ids = [Team IDsFromJSON:teamsJSON];
    Team *team1 = [Team MR_createInContext:managedObjectContext];
    team1.uid = [ids objectAtIndex:0];
    Team *team2 = [Team MR_createInContext:managedObjectContext];
    team2.uid = [ids objectAtIndex:1];
    Team *team3 = [Team MR_createInContext:managedObjectContext];
    team3.uid = [ids objectAtIndex:2];
    NSUInteger expectedTeamsCount = 3;
    
    NSArray *teams = [Team localTeamsFromJSON:teamsJSON inContext:managedObjectContext];
    
    XCTAssertEqual([teams count], expectedTeamsCount, @"teams count should equal expectedTeamsCount");
}

#pragma mark - sortedTeamsWithIDs

- (void)testSortedTeamsWithIDsShouldReturnTeamsInAlphabeticalOrder
{
    [Team parseTeamsJSON:teamsJSON inContext:managedObjectContext];
    
    NSArray *teamIDs = [Team IDsFromJSON:teamsJSON];
    NSArray *sortedTeams = [Team sortedTeamsWithIDs:teamIDs];
    Team *firstTeam = [sortedTeams objectAtIndex:0];
    Team *secondTeam = [sortedTeams objectAtIndex:1];
    
    XCTAssertTrue([firstTeam.name compare:secondTeam.name] == NSOrderedAscending, @"firstTeam name should come before secondTeam name");
}

#pragma mark - fetchFavoriteTeamsWithDelegate

- (void)testFetchFavoriteTeamsShouldReturnAValidFetchedResultsController
{
    [Team parseTeamsJSON:teamsJSON inContext:managedObjectContext];
    id fetchedResultsController = [Team fetchFavoriteTeamsWithDelegate:nil];
    
    XCTAssertTrue([fetchedResultsController isKindOfClass:[NSFetchedResultsController class]], @"favorites should be of NSFetchedResultsController type");
}

- (void)testFetchFavoriteTeamsShouldReturnCorrectNumberOfTeamsMarkedFavorite
{
    [Team parseTeamsJSON:teamsJSON inContext:managedObjectContext];    
    NSArray *teamIDs = [Team IDsFromJSON:teamsJSON];
    NSArray *teams =  [Team sortedTeamsWithIDs:teamIDs];
    Team *firstTeam = [teams objectAtIndex:0];
    firstTeam.favorite = [NSNumber numberWithBool:YES];
    NSUInteger expectedCount = 1;
    
    NSFetchedResultsController *fetchedResultsController = [Team fetchFavoriteTeamsWithDelegate:nil];
    id sectionInfo = [fetchedResultsController.sections objectAtIndex:0];
    
    XCTAssertEqual([sectionInfo numberOfObjects], expectedCount, @"sectionInfo count should equal expectedCount");
}

- (void)testFetchFavoriteTeamsShouldReturnArrayOfTeamObjects
{
    [Team parseTeamsJSON:teamsJSON inContext:managedObjectContext];
    NSUInteger sectionIndex = 0;
    NSUInteger rowIndex = 0;
    NSArray *teamIDs = [Team IDsFromJSON:teamsJSON];
    NSArray *teams =  [Team sortedTeamsWithIDs:teamIDs];
    Team *firstTeam = [teams objectAtIndex:rowIndex];
    firstTeam.favorite = [NSNumber numberWithBool:YES];
    
    NSFetchedResultsController *fetchedResultsController = [Team fetchFavoriteTeamsWithDelegate:nil];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    id team = [fetchedResultsController objectAtIndexPath:indexPath];
    
    XCTAssertTrue([team isKindOfClass:[Team class]], @"team should be of Team type");
}

- (void)testFetchFavoriteTeamsShouldReturnSectionContainingExpectedTeam
{
    [Team parseTeamsJSON:teamsJSON inContext:managedObjectContext];
    NSUInteger rowIndex = 0;
    NSArray *teamIDs = [Team IDsFromJSON:teamsJSON];
    NSArray *teams =  [Team sortedTeamsWithIDs:teamIDs];
    Team *firstTeam = [teams objectAtIndex:rowIndex];
    firstTeam.favorite = [NSNumber numberWithBool:YES];
    
    NSFetchedResultsController *fetchedResultsController = [Team fetchFavoriteTeamsWithDelegate:nil];
    id <NSFetchedResultsSectionInfo> sectionInfo = [fetchedResultsController.sections objectAtIndex:0];
    
    XCTAssertTrue([sectionInfo.objects containsObject:firstTeam], @"sectionInfo should contain firstTeam");
}

@end
