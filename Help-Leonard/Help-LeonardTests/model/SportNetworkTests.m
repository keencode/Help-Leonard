//
//  SportNetworkTests.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FixtureHelper.h"
#import "Sport+Network.h"

@interface SportNetworkTests : XCTestCase
{
    NSManagedObjectContext *managedObjectContext;
    FixtureHelper *fixtureHelper;
}

@end

@implementation SportNetworkTests

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
    
    fixtureHelper = [[FixtureHelper alloc] init];
}

- (void)tearDown
{
    managedObjectContext = nil;
    fixtureHelper = nil;
    
    [super tearDown];
}

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

//- (void)testUpdateWithInfoShouldAssignTheCorrectDescription
//{
//    NSData *testData = [fixtureHelper validDataFromHeadlinesFixture];
//    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
//                                                             options:NSJSONReadingMutableLeaves
//                                                               error:nil];
//    NSArray *headlinesJSON = [jsonData objectForKey:@"headlines"];
//    NSDictionary *headlineInfo = [headlinesJSON objectAtIndex:1];
//    NSString *expectedDescription = [headlineInfo objectForKey:@"description"];
//    
//    Headline *headline = [Headline MR_createInContext:managedObjectContext];
//    [headline updateWithInfo:headlineInfo];
//    
//    XCTAssertEqualObjects(headline.ddescription, expectedDescription, @"The ddescription property should match expectedDescription");
//}
//
//- (void)testUpdateWithInfoShouldAssignTheCorrectPublishedDate
//{
//    NSData *testData = [fixtureHelper validDataFromHeadlinesFixture];
//    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
//                                                             options:NSJSONReadingMutableLeaves
//                                                               error:nil];
//    NSArray *headlinesJSON = [jsonData objectForKey:@"headlines"];
//    NSDictionary *headlineInfo = [headlinesJSON objectAtIndex:1];
//    NSDate *expectedPublishedDate = [KCDateHelper dateFromFormattedString:[headlineInfo objectForKey:@"published"]];
//    
//    Headline *headline = [Headline MR_createInContext:managedObjectContext];
//    [headline updateWithInfo:headlineInfo];
//    
//    XCTAssertEqualObjects(headline.published, expectedPublishedDate, @"The published property should match expectedPublishedDate");
//}
//
//- (void)testUpdateWithInfoShouldAssignTheCorrectLastModifiedDate
//{
//    NSData *testData = [fixtureHelper validDataFromHeadlinesFixture];
//    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
//                                                             options:NSJSONReadingMutableLeaves
//                                                               error:nil];
//    NSArray *headlinesJSON = [jsonData objectForKey:@"headlines"];
//    NSDictionary *headlineInfo = [headlinesJSON objectAtIndex:1];
//    NSDate *expectedLastModifiedDate = [KCDateHelper dateFromFormattedString:[headlineInfo objectForKey:@"lastModified"]];
//    
//    Headline *headline = [Headline MR_createInContext:managedObjectContext];
//    [headline updateWithInfo:headlineInfo];
//    
//    XCTAssertEqualObjects(headline.lastModified, expectedLastModifiedDate, @"The lastModified property should match expectedLastModifiedDate");
//}
//
//- (void)testParseJSONShouldCreateCorrectNumberOfHeadlines
//{
//    NSData *testData = [fixtureHelper validDataFromHeadlinesFixture];
//    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
//                                                             options:NSJSONReadingMutableLeaves
//                                                               error:nil];
//    NSArray *headlinesJSON = [jsonData objectForKey:@"headlines"];
//    NSUInteger expectedHeadlinesCount = [headlinesJSON count];
//    
//    NSArray *parsedHeadlines = [Headline parseHeadlinesJSON:headlinesJSON inContext:managedObjectContext];
//    
//    XCTAssertEqual([parsedHeadlines count], expectedHeadlinesCount, @"parsedHeadlines count should equal expectedHeadlinesCount");
//}

@end
