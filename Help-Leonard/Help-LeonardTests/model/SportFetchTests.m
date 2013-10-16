//
//  SportFetchTests.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataHelper.h"
#import "FixtureHelper.h"
#import "Sport+Fetch.h"
#import "Sport+Network.h"
#import "League.h"

@interface SportFetchTests : XCTestCase
{
    NSManagedObjectContext *managedObjectContext;
    NSArray *sportsJSON;
}

@end

@implementation SportFetchTests

- (void)setUp
{
    [super setUp];
    
    CoreDataHelper *coreDataHelper = [[CoreDataHelper alloc] init];
    managedObjectContext = coreDataHelper.managedObjectContext;
    
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

#pragma mark - IDsFromJSON

- (void)testIDsFromJSONShouldReturnANonNilObject
{
    id idsFromJSON = [Sport IDsFromJSON:sportsJSON];
    
    XCTAssertNotNil(idsFromJSON, @"idsFromJSON should NOT be nil");
}

- (void)testIDsFromJSONShouldReturnAnArray
{
    id idsFromJSON = [Sport IDsFromJSON:sportsJSON];
    
    XCTAssertTrue([idsFromJSON isKindOfClass:[NSArray class]], @"idsFromJSON should be an NSArray");
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

#pragma mark - localSportsFromJSON

- (void)testLocalSportsWithIDsShouldReturnANonNilObject
{
    NSArray *ids = [Sport IDsFromJSON:sportsJSON];
    Sport *sport1 = [Sport MR_createInContext:managedObjectContext];
    sport1.uid = [ids objectAtIndex:0];

    id sports = [Sport localSportsFromJSON:sportsJSON inContext:managedObjectContext];
    
    XCTAssertNotNil(sports, @"sports should NOT be nil");
}

- (void)testLocalSportsWithIDsShouldReturnAnArray
{
    NSArray *ids = [Sport IDsFromJSON:sportsJSON];
    Sport *sport1 = [Sport MR_createInContext:managedObjectContext];
    sport1.uid = [ids objectAtIndex:0];

    id sports = [Sport localSportsFromJSON:sportsJSON inContext:managedObjectContext];
    
    XCTAssertTrue([sports isKindOfClass:[NSArray class]], @"sports should be an NSArray");
}

- (void)testLocalSportsFromJSONShouldReturnExpectedCount
{
    NSArray *ids = [Sport IDsFromJSON:sportsJSON];
    Sport *sport1 = [Sport MR_createInContext:managedObjectContext];
    sport1.uid = [ids objectAtIndex:0];
    Sport *sport2 = [Sport MR_createInContext:managedObjectContext];
    sport2.uid = [ids objectAtIndex:1];
    Sport *sport3 = [Sport MR_createInContext:managedObjectContext];
    sport3.uid = [ids objectAtIndex:2];
    NSUInteger expectedSportsCount = 3;
    
    NSArray *sports = [Sport localSportsFromJSON:sportsJSON inContext:managedObjectContext];
    
    XCTAssertEqual([sports count], expectedSportsCount, @"sports count should equal expectedSportsCount");
}

#pragma mark - fetchSortedSports

- (void)testFetchSortedSportsShouldReturnANonNilObject
{
    [Sport parseSportsJSON:sportsJSON inContext:managedObjectContext];
    
    id sports = [Sport fetchSortedSports];

    XCTAssertNotNil(sports, @"sports should NOT be nil");
}

- (void)testFetchSortedSportsWithIDsShouldReturnAnArray
{
    [Sport parseSportsJSON:sportsJSON inContext:managedObjectContext];
    
    id sports = [Sport fetchSortedSports];
    
    XCTAssertTrue([sports isKindOfClass:[NSArray class]], @"sports should be an NSArray");
}

- (void)testFetchSortedSportsShouldReturnExpectedCount
{
    [Sport parseSportsJSON:sportsJSON inContext:managedObjectContext];
    NSUInteger expectedSportsCount = [sportsJSON count];
    
    NSArray *sports = [Sport fetchSortedSports];
    
    XCTAssertEqual([sports count], expectedSportsCount, @"sports count should equal expectedSportsCount");
}

- (void)testFetchSortedSportsShouldReturnNamesInAlphabeticalOrder
{
    [Sport parseSportsJSON:sportsJSON inContext:managedObjectContext];
    
    NSArray *sports = [Sport fetchSortedSports];
    Sport *firstSport = [sports objectAtIndex:0];
    Sport *secondSport = [sports objectAtIndex:2];
    
    XCTAssertTrue([firstSport.name compare:secondSport.name] == NSOrderedAscending, @"firstSport name should come before secondSport name");
}

#pragma mark - sortedLeagues

- (void)testSortedLeaguesShouldReturnArraySortedInAlphabeticalOrder
{
    [Sport parseSportsJSON:sportsJSON inContext:managedObjectContext];
    
    NSArray *sports = [Sport fetchSortedSports];
    Sport *sport = [sports objectAtIndex:1];
    NSArray *sortedLeagues = [sport sortedLeagues];
    League *league1 = [sortedLeagues objectAtIndex:0];
    League *league2 = [sortedLeagues objectAtIndex:1];
    
    XCTAssertTrue([league1.name compare:league2.name] == NSOrderedAscending, @"league1 name should come before league2 name");
}

@end
