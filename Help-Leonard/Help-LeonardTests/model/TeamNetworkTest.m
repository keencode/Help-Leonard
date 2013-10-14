//
//  TeamNetworkTest.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Team+Network.h"
#import "FixtureHelper.h"

@interface TeamNetworkTest : XCTestCase
{
    NSManagedObjectContext *managedObjectContext;
    FixtureHelper *fixtureHelper;
}

@end

@implementation TeamNetworkTest

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
    
    fixtureHelper = [[FixtureHelper alloc] init];
}

- (void)tearDown
{
    managedObjectContext = nil;
    fixtureHelper = nil;
    
    [super tearDown];
}

- (void)testAPIURLForSportNameLeagueNameShouldContainExpectedString
{
    NSString *sportName = @"basketball";
    NSString *leagueName = @"nba";
    NSString *expectedSubstr = [NSString stringWithFormat:@"http://api.espn.com/v1/sports/%@/%@/teams", sportName, leagueName];
    
    NSString *urlStr = [Team apiURLForSportName:sportName leagueName:leagueName];
    
    XCTAssertTrue([urlStr rangeOfString:expectedSubstr].length > 0, @"urlStr should contain expectedSubstr");
}

- (void)testJSONIsValidShouldReturnTrueForValidJSON
{
    NSData *testData = [fixtureHelper validDataFromTeamsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    
    BOOL isJSONValid = [Team JSONIsValid:json];
    
    XCTAssertTrue(isJSONValid, @"isJSONValid should be true");
}

- (void)testJSONIsValidShouldReturnFalseForInvalidJSON
{
    NSData *testData = [fixtureHelper invalidDataFromTeamsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    
    BOOL isJSONValid = [Team JSONIsValid:json];
    
    XCTAssertFalse(isJSONValid, @"isJSONValid should be false");
}

- (void)testTeamsJSONFromResponseShouldReturnAnArray
{
    NSData *testData = [fixtureHelper validDataFromTeamsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];

    id teams = [Team teamsJSONFromResponse:json];
    
    XCTAssertTrue([teams isKindOfClass:[NSArray class]], @"teams should be of NSArray type");
}

@end
