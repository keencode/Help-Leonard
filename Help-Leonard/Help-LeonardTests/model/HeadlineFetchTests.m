//
//  HeadlineFetchTests.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/11/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FixtureHelper.h"
#import "Headline+Network.h"
#import "Headline+Fetch.h"

@interface HeadlineFetchTests : XCTestCase
{
    NSManagedObjectContext *managedObjectContext;
    NSArray *headlinesJSON;
}

@end

@implementation HeadlineFetchTests

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
    
    FixtureHelper *fixtureHelper = [[FixtureHelper alloc] init];
    NSData *testData = [fixtureHelper validDataFromHeadlinesFixture];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:testData
                                                             options:NSJSONReadingMutableLeaves
                                                               error:nil];
    headlinesJSON = [jsonData objectForKey:@"headlines"];
}

- (void)tearDown
{
    managedObjectContext = nil;
    headlinesJSON = nil;
    
    [super tearDown];
}

- (void)testIDsFromJSONShouldReturnExpectedCount
{
    NSUInteger expectedIDsCount = [headlinesJSON count];
    
    NSArray *idsFromJSON = [Headline IDsFromJSON:headlinesJSON];
    
    XCTAssertEqual([idsFromJSON count], expectedIDsCount, @"idsFromJSON count should equal expectedIDsCount");
}

- (void)testIDsFromJSONShouldReturnExpectedID
{
    NSString *expectedFirstID = [[headlinesJSON objectAtIndex:0] objectForKey:@"id"];
    
    NSArray *idsFromJSON = [Headline IDsFromJSON:headlinesJSON];
    NSString *firstID = [idsFromJSON objectAtIndex:0];
    
    XCTAssertEqualObjects(firstID, expectedFirstID, @"firstID should match expectedFirstID");
}

- (void)testFetchHeadlinesWithIDsShouldReturnExpectedCount
{
    NSArray *ids = [Headline IDsFromJSON:headlinesJSON];
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    headline1.uid = (NSNumber *)[ids objectAtIndex:0];
    Headline *headline2 = [Headline MR_createInContext:managedObjectContext];
    headline2.uid = (NSNumber *)[ids objectAtIndex:1];
    Headline *headline3 = [Headline MR_createInContext:managedObjectContext];
    headline3.uid = (NSNumber *)[ids objectAtIndex:2];
    NSUInteger expectedHeadlinesCount = 3;
    
    NSArray *localHeadlines = [Headline fetchHeadlinesWithIDs:ids inContext:managedObjectContext];
    
    XCTAssertEqual([localHeadlines count], expectedHeadlinesCount, @"localHeadlines count should equal expectedHeadlinesCount");
}

- (void)testFetchHeadlinesWithIDsShouldReturnExpectedHeadlines
{
    NSArray *ids = [Headline IDsFromJSON:headlinesJSON];
    
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    headline1.uid = (NSNumber *)[ids objectAtIndex:0];
    
    NSArray *localHeadlines = [Headline fetchHeadlinesWithIDs:ids inContext:managedObjectContext];
    
    XCTAssertTrue([localHeadlines containsObject:headline1], @"localHeadlines should contain headline1");
}

- (void)testLocalHeadlinesFromJSONShouldReturnExpectedCount
{
    NSArray *ids = [Headline IDsFromJSON:headlinesJSON];
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    headline1.uid = (NSNumber *)[ids objectAtIndex:0];
    Headline *headline2 = [Headline MR_createInContext:managedObjectContext];
    headline2.uid = (NSNumber *)[ids objectAtIndex:1];
    Headline *headline3 = [Headline MR_createInContext:managedObjectContext];
    headline3.uid = (NSNumber *)[ids objectAtIndex:2];
    NSUInteger expectedHeadlinesCount = 3;
    
    NSArray *localHeadlines = [Headline localHeadlinesFromJSON:headlinesJSON
                                                     inContext:managedObjectContext];
    
    XCTAssertEqual([localHeadlines count], expectedHeadlinesCount, @"localHeadlines count should equal expectedHeadlinesCount");
}

- (void)testFetchRecentHeadlinesShouldReturnExpectedCount
{
    [Headline parseHeadlinesJSON:headlinesJSON inContext:managedObjectContext];
    NSUInteger expectedHeadlinesCount = [headlinesJSON count];
    
    NSArray *recentHeadlines = [Headline fetchRecentHeadlines];
    
    XCTAssertEqual([recentHeadlines count], expectedHeadlinesCount, @"localHeadlines count should equal expectedHeadlinesCount");
}

@end
