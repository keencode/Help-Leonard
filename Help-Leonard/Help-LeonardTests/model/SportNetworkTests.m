//
//  SportNetworkTests.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataHelper.h"
#import "FixtureHelper.h"
#import "Sport+Network.h"

@interface SportNetworkTests : XCTestCase
{
    NSManagedObjectContext *managedObjectContext;
    FixtureHelper *fixtureHelper;
}

@end

@implementation SportNetworkTests

- (void)setUp
{
    [super setUp];
    
    CoreDataHelper *coreDataHelper = [[CoreDataHelper alloc] init];
    managedObjectContext = coreDataHelper.managedObjectContext;
    
    fixtureHelper = [[FixtureHelper alloc] init];
}

- (void)tearDown
{
    managedObjectContext = nil;
    fixtureHelper = nil;
    
    [super tearDown];
}

#pragma mark - JSONIsValid

- (void)testJSONIsValidShouldReturnTrueForValidJSON
{
    NSData *testData = [fixtureHelper validDataFromSportsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    
    BOOL isJSONValid = [Sport JSONIsValid:json];
    
    XCTAssertTrue(isJSONValid, @"isJSONValid should be true");
}

- (void)testJSONIsValidShouldReturnFalseForInvalidJSON
{
    NSData *testData = [fixtureHelper invalidDataFromSportsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    
    BOOL isJSONValid = [Sport JSONIsValid:json];
    
    XCTAssertFalse(isJSONValid, @"isJSONValid should be false");
}

#pragma mark - updateWithInfo

- (void)testUpdateWithInfoShouldAssignCorrectName
{
    NSData *testData = [fixtureHelper validDataFromSportsFixture];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    NSArray *sportsJSON = [jsonData objectForKey:@"sports"];
    NSDictionary *sportInfo = [sportsJSON objectAtIndex:1];
    NSString *expectedName = [sportInfo objectForKey:@"name"];
    
    Sport *sport = [Sport MR_createInContext:managedObjectContext];
    [sport updateWithInfo:sportInfo];
    
    XCTAssertEqualObjects(sport.name, expectedName, @"The name property should match expectedName");
}

#pragma mark - parseSportsJSON

- (void)testParseSportsJSONShouldAssignTheCorrectNumberOfLeagues
{
    NSData *testData = [fixtureHelper validDataFromSportsFixture];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    NSArray *sportsJSON = [jsonData objectForKey:@"sports"];
    
    NSUInteger sportIndex = 1;
    NSDictionary *sportInfo = [sportsJSON objectAtIndex:sportIndex];
    NSArray *leagues = [sportInfo objectForKey:@"leagues"];
    NSUInteger expectedLeaguesCount = [leagues count];
    
    NSArray *sports = [Sport parseSportsJSON:sportsJSON inContext:managedObjectContext];
    Sport *sport = [sports objectAtIndex:sportIndex];
    
    XCTAssertEqual([sport.leagues count], expectedLeaguesCount, @"The leagues count should match expectedLeaguesCount");
}

@end
