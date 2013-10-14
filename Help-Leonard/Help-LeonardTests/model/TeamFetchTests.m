//
//  TeamFetchTests.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Team+Fetch.h"
#import "Team+Network.h"
#import "FixtureHelper.h"

@interface TeamFetchTests : XCTestCase
{
    NSManagedObjectContext *managedObjectContext;
    NSArray *teamsJSON;
}

@end

@implementation TeamFetchTests

- (NSString *)dbStore
{
    NSString *bundleID = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    return [NSString stringWithFormat:@"%@.sqlite", bundleID];
}

- (void)cleanAndResetupDB
{
    NSString *dbStore = [self dbStore];
    NSError *error = nil;
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:dbStore];
    [MagicalRecord cleanUp];
    
    if ([[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error]){
        //        [self setupDB];
    }
    else{
        NSLog(@"An error has occurred while deleting %@", dbStore);
        NSLog(@"Error description: %@", error.description);
    }
}

- (void)setUp
{
    [super setUp];
    
    [self cleanAndResetupDB];
    
    [MagicalRecord setDefaultModelFromClass:[Team class]];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    
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

- (void)testFetchTeamsWithIDsShouldReturnExpectedHeadlines
{
    NSArray *ids = [Team IDsFromJSON:teamsJSON];
    
    Team *team1 = [Team MR_createInContext:managedObjectContext];
    team1.uid = (NSString *)[ids objectAtIndex:0];
    
    NSArray *localTeams = [Team fetchTeamsWithIDs:ids inContext:managedObjectContext];
    
    XCTAssertTrue([localTeams containsObject:team1], @"localTeams should contain team1");
}

- (void)testLocalTeamsFromJSONShouldReturnExpectedCount
{
    NSArray *ids = [Team IDsFromJSON:teamsJSON];
    Team *team1 = [Team MR_createInContext:managedObjectContext];
    team1.uid = (NSString *)[ids objectAtIndex:0];
    Team *team2 = [Team MR_createInContext:managedObjectContext];
    team2.uid = (NSString *)[ids objectAtIndex:1];
    Team *team3 = [Team MR_createInContext:managedObjectContext];
    team3.uid = (NSString *)[ids objectAtIndex:2];
    NSUInteger expectedTeamsCount = 3;
    
    NSArray *localTeams = [Team localTeamsFromJSON:teamsJSON inContext:managedObjectContext];
    
    XCTAssertEqual([localTeams count], expectedTeamsCount, @"localTeams count should equal expectedTeamsCount");
}

- (void)testFetchTeamsFromJSONShouldReturnExpectedCount
{
    [Team parseTeamsJSON:teamsJSON inContext:managedObjectContext];
    NSUInteger expectedTeamsCount = [teamsJSON count];
    
    NSArray *ids = [Team IDsFromJSON:teamsJSON];
    NSArray *localTeams = [Team fetchTeamsWithIDs:ids inContext:managedObjectContext];
    
    XCTAssertEqual([localTeams count], expectedTeamsCount, @"localTeams count should equal expectedTeamsCount");
}

- (void)testSortedTeamsWithIDsShouldReturnTeamsInAlphabeticalOrder
{
    NSArray *teamIDs = [Team IDsFromJSON:teamsJSON];
    
    [Team parseTeamsJSON:teamsJSON inContext:managedObjectContext];
    NSArray *localTeams = [Team sortedTeamsWithIDs:teamIDs];
    Team *firstTeam = [localTeams objectAtIndex:0];
    Team *secondTeam = [localTeams objectAtIndex:1];
    
    XCTAssertTrue([firstTeam.name compare:secondTeam.name] == NSOrderedAscending, @"firstTeam name should come before secondTeam name");
}

@end