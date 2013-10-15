//
//  SportFetchTests.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Sport+Fetch.h"
#import "Sport+Network.h"
#import "FixtureHelper.h"
#import "League.h"

@interface SportFetchTests : XCTestCase
{
    NSManagedObjectContext *managedObjectContext;
    NSArray *sportsJSON;
}

@end

@implementation SportFetchTests

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
    
    [MagicalRecord setDefaultModelFromClass:[Sport class]];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    
    FixtureHelper *fixtureHelper = [[FixtureHelper alloc] init];
    NSData *testData = [fixtureHelper validDataFromSportsFixture];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    sportsJSON = [jsonData objectForKey:@"sports"];
}

- (void)tearDown
{
    managedObjectContext = nil;
    sportsJSON = nil;
    
    [super tearDown];
}

- (void)testIDsFromJSONShouldReturnExpectedCount
{
    NSUInteger expectedIDsCount = [sportsJSON count];
    
    NSArray *idsFromJSON = [Sport IDsFromJSON:sportsJSON];
    
    XCTAssertEqual([idsFromJSON count], expectedIDsCount, @"idsFromJSON count should equal expectedIDsCount");
}

- (void)testIDsFromJSONShouldReturnExpectedID
{
    NSString *expectedFirstID = [[sportsJSON objectAtIndex:0] objectForKey:@"id"];
    
    NSArray *idsFromJSON = [Sport IDsFromJSON:sportsJSON];
    NSString *firstID = [idsFromJSON objectAtIndex:0];
    
    XCTAssertEqualObjects(firstID, expectedFirstID, @"firstID should match expectedFirstID");
}

- (void)testFetchSportsWithIDsShouldReturnExpectedCount
{
    NSArray *ids = [Sport IDsFromJSON:sportsJSON];
    Sport *sport1 = [Sport MR_createInContext:managedObjectContext];
    sport1.uid = (NSNumber *)[ids objectAtIndex:0];
    Sport *sport2 = [Sport MR_createInContext:managedObjectContext];
    sport2.uid = (NSNumber *)[ids objectAtIndex:1];
    Sport *sport3 = [Sport MR_createInContext:managedObjectContext];
    sport3.uid = (NSNumber *)[ids objectAtIndex:2];
    NSUInteger expectedSportsCount = 3;
    
    NSArray *localSports = [Sport fetchSportsWithIDs:ids inContext:managedObjectContext];
    
    XCTAssertEqual([localSports count], expectedSportsCount, @"localSports count should equal expectedSportsCount");
}

- (void)testFetchSportsWithIDsShouldReturnExpectedHeadlines
{
    NSArray *ids = [Sport IDsFromJSON:sportsJSON];
    
    Sport *sport1 = [Sport MR_createInContext:managedObjectContext];
    sport1.uid = (NSNumber *)[ids objectAtIndex:0];
    
    NSArray *localSports = [Sport fetchSportsWithIDs:ids inContext:managedObjectContext];
    
    XCTAssertTrue([localSports containsObject:sport1], @"localSports should contain sport1");
}

- (void)testLocalSportsFromJSONShouldReturnExpectedCount
{
    NSArray *ids = [Sport IDsFromJSON:sportsJSON];
    Sport *sport1 = [Sport MR_createInContext:managedObjectContext];
    sport1.uid = (NSNumber *)[ids objectAtIndex:0];
    Sport *sport2 = [Sport MR_createInContext:managedObjectContext];
    sport2.uid = (NSNumber *)[ids objectAtIndex:1];
    Sport *sport3 = [Sport MR_createInContext:managedObjectContext];
    sport3.uid = (NSNumber *)[ids objectAtIndex:2];
    NSUInteger expectedSportsCount = 3;
    
    NSArray *localSports = [Sport localSportsFromJSON:sportsJSON
                                               inContext:managedObjectContext];
    
    XCTAssertEqual([localSports count], expectedSportsCount, @"localSports count should equal expectedSportsCount");
}

- (void)testFetchLocalSportsShouldReturnExpectedCount
{
    [Sport parseSportsJSON:sportsJSON inContext:managedObjectContext];
    NSUInteger expectedSportsCount = [sportsJSON count];
    
    NSArray *localSports = [Sport fetchSportsInAlphabeticalOrder];
    
    XCTAssertEqual([localSports count], expectedSportsCount, @"localSports count should equal expectedSportsCount");
}

- (void)testFetchLocalSportsShouldReturnNamesInAlphabeticalOrder
{
    [Sport parseSportsJSON:sportsJSON inContext:managedObjectContext];
    
    NSArray *localSports = [Sport fetchSportsInAlphabeticalOrder];
    Sport *firstSport = [localSports objectAtIndex:0];
    Sport *secondSport = [localSports objectAtIndex:2];
    
    XCTAssertTrue([firstSport.name compare:secondSport.name] == NSOrderedAscending, @"firstSport name should come before secondSport name");
}

- (void)testSortedLeaguesShouldReturnArraySortedInAlphabeticalOrder
{
    [Sport parseSportsJSON:sportsJSON inContext:managedObjectContext];
    
    NSArray *localSports = [Sport fetchSportsInAlphabeticalOrder];
    Sport *sport = [localSports objectAtIndex:1];
    NSArray *sortedLeagues = [sport sortedLeagues];
    League *league1 = [sortedLeagues objectAtIndex:0];
    League *league2 = [sortedLeagues objectAtIndex:1];
    
    XCTAssertTrue([league1.name compare:league2.name] == NSOrderedAscending, @"league1 name should come before league2 name");
}

@end
