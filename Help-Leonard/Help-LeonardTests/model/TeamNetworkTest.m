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

    id teamsJSON = [Team teamsJSONFromResponse:json];
    
    XCTAssertTrue([teamsJSON isKindOfClass:[NSArray class]], @"teams should be of NSArray type");
}

- (void)testUpdateWithInfoShouldAssignCorrectName
{
    NSData *testData = [fixtureHelper validDataFromTeamsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    NSArray *teamsJSON = [Team teamsJSONFromResponse:json];
    NSDictionary *teamInfo = [teamsJSON objectAtIndex:0];
    NSString *expectedName = [teamInfo objectForKey:@"name"];
    
    Team *team = [Team MR_createInContext:managedObjectContext];
    team.uid = [teamInfo objectForKey:@"uid"];
    [team updateWithInfo:teamInfo];
    
    XCTAssertEqualObjects(team.name, expectedName, @"team name property should match expectedName");
}

- (void)testUpdateWithInfoShouldAssignCorrectLocation
{
    NSData *testData = [fixtureHelper validDataFromTeamsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    NSArray *teamsJSON = [Team teamsJSONFromResponse:json];
    NSDictionary *teamInfo = [teamsJSON objectAtIndex:0];
    NSString *expectedLocation = [teamInfo objectForKey:@"location"];
    
    Team *team = [Team MR_createInContext:managedObjectContext];
    team.uid = [teamInfo objectForKey:@"uid"];
    [team updateWithInfo:teamInfo];
    
    XCTAssertEqualObjects(team.location, expectedLocation, @"team location property should match expectedLocation");
}

- (void)testUpdateWithInfoShouldAssignCorrectAbbreviation
{
    NSData *testData = [fixtureHelper validDataFromTeamsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    NSArray *teamsJSON = [Team teamsJSONFromResponse:json];
    NSDictionary *teamInfo = [teamsJSON objectAtIndex:0];
    NSString *expectedAbbreviation = [teamInfo objectForKey:@"abbreviation"];
    
    Team *team = [Team MR_createInContext:managedObjectContext];
    team.uid = [teamInfo objectForKey:@"uid"];
    [team updateWithInfo:teamInfo];
    
    XCTAssertEqualObjects(team.abbreviation, expectedAbbreviation, @"team abbreviation property should match expectedAbbreviation");
}

- (void)testUpdateWithInfoShouldAssignCorrectNickname
{
    NSData *testData = [fixtureHelper validDataFromTeamsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    NSArray *teamsJSON = [Team teamsJSONFromResponse:json];
    NSDictionary *teamInfo = [teamsJSON objectAtIndex:0];
    NSString *expectedNickname = [teamInfo objectForKey:@"nickname"];
    
    Team *team = [Team MR_createInContext:managedObjectContext];
    team.uid = [teamInfo objectForKey:@"uid"];
    [team updateWithInfo:teamInfo];
    
    XCTAssertEqualObjects(team.nickname, expectedNickname, @"team nickname property should match expectedNickname");
}

- (void)testUpdateWithInfoShouldAssignCorrectTeamID
{
    NSData *testData = [fixtureHelper validDataFromTeamsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    NSArray *teamsJSON = [Team teamsJSONFromResponse:json];
    NSDictionary *teamInfo = [teamsJSON objectAtIndex:0];
    NSString *expectedTeamID = [teamInfo objectForKey:@"id"];
    
    Team *team = [Team MR_createInContext:managedObjectContext];
    team.uid = [teamInfo objectForKey:@"uid"];
    [team updateWithInfo:teamInfo];
    
    XCTAssertEqualObjects(team.teamID, expectedTeamID, @"team teamID property should match expectedTeamID");
}

- (void)testUpdateWithInfoShouldAssignCorrectTeamsURL
{
    NSData *testData = [fixtureHelper validDataFromTeamsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    NSArray *teamsJSON = [Team teamsJSONFromResponse:json];
    NSDictionary *teamInfo = [teamsJSON objectAtIndex:0];
    NSString *expectedTeamsURL = [[[[teamInfo objectForKey:@"links"] objectForKey:@"api"] objectForKey:@"teams"] objectForKey:@"href"];
    
    Team *team = [Team MR_createInContext:managedObjectContext];
    team.uid = [teamInfo objectForKey:@"uid"];
    [team updateWithInfo:teamInfo];
    
    XCTAssertEqualObjects(team.teamsURL, expectedTeamsURL, @"team teamsURL property should match expectedTeamsURL");
}

- (void)testUpdateWithInfoShouldAssignCorrectNewsURL
{
    NSData *testData = [fixtureHelper validDataFromTeamsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    NSArray *teamsJSON = [Team teamsJSONFromResponse:json];
    NSDictionary *teamInfo = [teamsJSON objectAtIndex:0];
    NSString *expectedNewsURL = [[[[teamInfo objectForKey:@"links"] objectForKey:@"api"] objectForKey:@"news"] objectForKey:@"href"];
    
    Team *team = [Team MR_createInContext:managedObjectContext];
    team.uid = [teamInfo objectForKey:@"uid"];
    [team updateWithInfo:teamInfo];
    
    XCTAssertEqualObjects(team.newsURL, expectedNewsURL, @"team newsURL property should match expectedNewsURL");
}

- (void)testUpdateWithInfoShouldAssignCorrectNotesURL
{
    NSData *testData = [fixtureHelper validDataFromTeamsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    NSArray *teamsJSON = [Team teamsJSONFromResponse:json];
    NSDictionary *teamInfo = [teamsJSON objectAtIndex:0];
    NSString *expectedNotesURL = [[[[teamInfo objectForKey:@"links"] objectForKey:@"api"] objectForKey:@"notes"] objectForKey:@"href"];
    
    Team *team = [Team MR_createInContext:managedObjectContext];
    team.uid = [teamInfo objectForKey:@"uid"];
    [team updateWithInfo:teamInfo];
    
    XCTAssertEqualObjects(team.notesURL, expectedNotesURL, @"team notesURL property should match expectedNotesURL");
}

- (void)testUpdateWithInfoShouldAssignCorrectDetailsURL
{
    NSData *testData = [fixtureHelper validDataFromTeamsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    NSArray *teamsJSON = [Team teamsJSONFromResponse:json];
    NSDictionary *teamInfo = [teamsJSON objectAtIndex:0];
    NSString *expectedMobileURL = [[[[teamInfo objectForKey:@"links"] objectForKey:@"mobile"] objectForKey:@"teams"] objectForKey:@"href"];
    
    Team *team = [Team MR_createInContext:managedObjectContext];
    team.uid = [teamInfo objectForKey:@"uid"];
    [team updateWithInfo:teamInfo];
    
    XCTAssertEqualObjects(team.mobileURL, expectedMobileURL, @"team mobileURL property should match expectedMobileURL");
}

- (void)testParseTeamsJSONReturnsExpectedCount
{
    NSData *testData = [fixtureHelper validDataFromTeamsFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    NSArray *teamsJSON = [Team teamsJSONFromResponse:json];
    NSUInteger expectedTeamsCount = [teamsJSON count];

    NSArray *teams = [Team parseTeamsJSON:teamsJSON inContext:managedObjectContext];

    XCTAssertEqual([teams count], expectedTeamsCount, @"teams count should match expectedTeamsCount");
}

@end
