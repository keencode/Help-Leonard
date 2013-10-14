//
//  HeadlineNetworkHelperTests.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/11/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Headline+Network.h"
#import "FixtureHelper.h"
#import "KCDateHelper.h"

@interface HeadlineNetworkTests : XCTestCase
{
    NSManagedObjectContext *managedObjectContext;
    FixtureHelper *fixtureHelper;
}

@end

@implementation HeadlineNetworkTests

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
    
    [MagicalRecord setDefaultModelFromClass:[Headline class]];
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
    NSData *testData = [fixtureHelper validDataFromHeadlinesFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    
    BOOL isJSONValid = [Headline JSONIsValid:json];
    
    XCTAssertTrue(isJSONValid, @"isJSONValid should be true");
}

- (void)testJSONIsValidShouldReturnFalseForInvalidJSON
{
    NSData *testData = [fixtureHelper invalidDataFromHeadlinesFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    
    BOOL isJSONValid = [Headline JSONIsValid:json];
    
    XCTAssertFalse(isJSONValid, @"isJSONValid should be false");
}

- (void)testJSONIsValidShouldReturnFalseForErrorJSON
{
    NSData *testData = [fixtureHelper errorDataFromHeadlinesFixture];
    id json = [NSJSONSerialization JSONObjectWithData:testData options:NSJSONReadingMutableLeaves error:nil];
    
    BOOL isJSONValid = [Headline JSONIsValid:json];
    
    XCTAssertFalse(isJSONValid, @"isJSONValid should be false");
}

- (void)testUpdateWithInfoShouldAssignCorrectTitle
{
    NSData *testData = [fixtureHelper validDataFromHeadlinesFixture];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    NSArray *headlinesJSON = [jsonData objectForKey:@"headlines"];
    NSDictionary *headlineInfo = [headlinesJSON objectAtIndex:1];
    NSString *expectedTitle = [headlineInfo objectForKey:@"title"];
    
    Headline *headline = [Headline MR_createInContext:managedObjectContext];
    [headline updateWithInfo:headlineInfo];
    
    XCTAssertEqualObjects(headline.title, expectedTitle, @"The title property should match expectedTitle");
}

- (void)testUpdateWithInfoShouldAssignTheCorrectHeadline
{
    NSData *testData = [fixtureHelper validDataFromHeadlinesFixture];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    NSArray *headlinesJSON = [jsonData objectForKey:@"headlines"];
    NSDictionary *headlineInfo = [headlinesJSON objectAtIndex:1];
    NSString *expectedHeadline = [headlineInfo objectForKey:@"headline"];
    
    Headline *headline = [Headline MR_createInContext:managedObjectContext];
    [headline updateWithInfo:headlineInfo];
    
    XCTAssertEqualObjects(headline.headline, expectedHeadline, @"The headline property should match expectedHeadline");
}

- (void)testUpdateWithInfoShouldAssignTheCorrectDescription
{
    NSData *testData = [fixtureHelper validDataFromHeadlinesFixture];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    NSArray *headlinesJSON = [jsonData objectForKey:@"headlines"];
    NSDictionary *headlineInfo = [headlinesJSON objectAtIndex:1];
    NSString *expectedDescription = [headlineInfo objectForKey:@"description"];
    
    Headline *headline = [Headline MR_createInContext:managedObjectContext];
    [headline updateWithInfo:headlineInfo];
    
    XCTAssertEqualObjects(headline.ddescription, expectedDescription, @"The ddescription property should match expectedDescription");
}

- (void)testUpdateWithInfoShouldAssignTheCorrectPublishedDate
{
    NSData *testData = [fixtureHelper validDataFromHeadlinesFixture];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    NSArray *headlinesJSON = [jsonData objectForKey:@"headlines"];
    NSDictionary *headlineInfo = [headlinesJSON objectAtIndex:1];
    NSDate *expectedPublishedDate = [KCDateHelper dateFromFormattedString:[headlineInfo objectForKey:@"published"]];
    
    Headline *headline = [Headline MR_createInContext:managedObjectContext];
    [headline updateWithInfo:headlineInfo];
    
    XCTAssertEqualObjects(headline.published, expectedPublishedDate, @"The published property should match expectedPublishedDate");
}

- (void)testUpdateWithInfoShouldAssignTheCorrectLastModifiedDate
{
    NSData *testData = [fixtureHelper validDataFromHeadlinesFixture];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    NSArray *headlinesJSON = [jsonData objectForKey:@"headlines"];
    NSDictionary *headlineInfo = [headlinesJSON objectAtIndex:1];
    NSDate *expectedLastModifiedDate = [KCDateHelper dateFromFormattedString:[headlineInfo objectForKey:@"lastModified"]];
    
    Headline *headline = [Headline MR_createInContext:managedObjectContext];
    [headline updateWithInfo:headlineInfo];
    
    XCTAssertEqualObjects(headline.lastModified, expectedLastModifiedDate, @"The lastModified property should match expectedLastModifiedDate");
}

- (void)testUpdateWithInfoShouldAssignTheCorrectMobileURL
{
    NSData *testData = [fixtureHelper validDataFromHeadlinesFixture];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    NSArray *headlinesJSON = [jsonData objectForKey:@"headlines"];
    NSDictionary *headlineInfo = [headlinesJSON objectAtIndex:1];
    NSDate *expectedURL = [[[headlineInfo objectForKey:@"links"] objectForKey:@"mobile"] objectForKey:@"href"];
    
    Headline *headline = [Headline MR_createInContext:managedObjectContext];
    [headline updateWithInfo:headlineInfo];
    
    XCTAssertEqualObjects(headline.mobileURL, expectedURL, @"The mobileURL property should match expectedURL");
}

- (void)testParseJSONShouldCreateCorrectNumberOfHeadlines
{
    NSData *testData = [fixtureHelper validDataFromHeadlinesFixture];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    NSArray *headlinesJSON = [jsonData objectForKey:@"headlines"];
    NSUInteger expectedHeadlinesCount = [headlinesJSON count];

    NSArray *parsedHeadlines = [Headline parseHeadlinesJSON:headlinesJSON inContext:managedObjectContext];
    
    XCTAssertEqual([parsedHeadlines count], expectedHeadlinesCount, @"parsedHeadlines count should equal expectedHeadlinesCount");
}

@end
