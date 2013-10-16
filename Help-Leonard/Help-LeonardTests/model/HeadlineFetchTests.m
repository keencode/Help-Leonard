//
//  HeadlineFetchTests.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/11/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataTestHelper.h"
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

- (void)setUp
{
    [super setUp];
    
    CoreDataTestHelper *coreDataHelper = [[CoreDataTestHelper alloc] init];
    managedObjectContext = coreDataHelper.managedObjectContext;
    
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

#pragma mark - IDsFromJSON

- (void)testIDsFromJSONShouldReturnANonNilObject
{
    id idsFromJSON = [Headline IDsFromJSON:headlinesJSON];
    
    XCTAssertNotNil(idsFromJSON, @"idsFromJSON should NOT be nil");
}

- (void)testIDsFromJSONShouldReturnAnArray
{
    id idsFromJSON = [Headline IDsFromJSON:headlinesJSON];
    
    XCTAssertTrue([idsFromJSON isKindOfClass:[NSArray class]], @"idsFromJSON should be an NSArray");
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

#pragma mark - localHeadlinesFromJSON

- (void)testLocalHeadlinesFromJSONShouldReturnANonNilObject
{
    NSArray *ids = [Headline IDsFromJSON:headlinesJSON];
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    headline1.uid = [ids objectAtIndex:0];
    Headline *headline2 = [Headline MR_createInContext:managedObjectContext];
    headline2.uid = [ids objectAtIndex:1];
    
    id headlines = [Headline localHeadlinesFromJSON:headlinesJSON inContext:managedObjectContext];
    
    XCTAssertNotNil(headlines, @"headlines should NOT be nil");
}

- (void)testLocalHeadlinesFromJSONShouldReturnAnArray
{
    NSArray *ids = [Headline IDsFromJSON:headlinesJSON];
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    headline1.uid = [ids objectAtIndex:0];
    Headline *headline2 = [Headline MR_createInContext:managedObjectContext];
    headline2.uid = [ids objectAtIndex:1];
    
    id headlines = [Headline localHeadlinesFromJSON:headlinesJSON inContext:managedObjectContext];
    
    XCTAssertTrue([headlines isKindOfClass:[NSArray class]], @"headlines should be an NSArray");
}

- (void)testLocalHeadlinesFromJSONShouldReturnExpectedCount
{
    NSArray *ids = [Headline IDsFromJSON:headlinesJSON];
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    headline1.uid = [ids objectAtIndex:0];
    Headline *headline2 = [Headline MR_createInContext:managedObjectContext];
    headline2.uid = [ids objectAtIndex:1];
    Headline *headline3 = [Headline MR_createInContext:managedObjectContext];
    headline3.uid = [ids objectAtIndex:2];
    NSUInteger expectedHeadlinesCount = 3;
    
    NSArray *headlines = [Headline localHeadlinesFromJSON:headlinesJSON inContext:managedObjectContext];
    
    XCTAssertEqual([headlines count], expectedHeadlinesCount, @"headlines count should equal expectedHeadlinesCount");
}

- (void)testLocalHeadlinesFromJSONShouldContainExpectedHeadline
{
    NSArray *ids = [Headline IDsFromJSON:headlinesJSON];
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    headline1.uid = [ids objectAtIndex:0];
    Headline *headline2 = [Headline MR_createInContext:managedObjectContext];
    headline2.uid = [ids objectAtIndex:1];
    Headline *headline3 = [Headline MR_createInContext:managedObjectContext];
    headline3.uid = [ids objectAtIndex:2];
    
    NSArray *headlines = [Headline localHeadlinesFromJSON:headlinesJSON inContext:managedObjectContext];
    
    XCTAssertTrue([headlines containsObject:headline1], @"headlines should contain headline1");
}

#pragma mark - fetchRecentHeadlines

- (void)testFetchRecentHeadlinesShouldReturnANonNilObject
{
    [Headline parseHeadlinesJSON:headlinesJSON inContext:managedObjectContext];

    id recentHeadlines = [Headline fetchRecentHeadlines];
    
    XCTAssertNotNil(recentHeadlines, @"recentHeadlines should NOT be nil");
}

- (void)testFetchRecentHeadlinesShouldReturnAnArray
{
    [Headline parseHeadlinesJSON:headlinesJSON inContext:managedObjectContext];
    
    id recentHeadlines = [Headline fetchRecentHeadlines];
    
    XCTAssertTrue([recentHeadlines isKindOfClass:[NSArray class]], @"recentHeadlines should be an NSArray");
}

- (void)testFetchRecentHeadlinesShouldReturnExpectedCount
{
    [Headline parseHeadlinesJSON:headlinesJSON inContext:managedObjectContext];
    NSUInteger expectedHeadlinesCount = [headlinesJSON count];
    
    NSArray *recentHeadlines = [Headline fetchRecentHeadlines];
    
    XCTAssertEqual([recentHeadlines count], expectedHeadlinesCount, @"recentHeadlines count should equal expectedHeadlinesCount");
}

- (void)testFetchRecentHeadlinesShouldReturnHeadlinesSortedInReverseChonologicalOrder
{
    [Headline parseHeadlinesJSON:headlinesJSON inContext:managedObjectContext];
    
    NSArray *recentHeadlines = [Headline fetchRecentHeadlines];
    Headline *firstHeadline = [recentHeadlines objectAtIndex:0];
    Headline *secondHeadline = [recentHeadlines objectAtIndex:1];
    
    XCTAssertTrue(([firstHeadline.published compare:secondHeadline.published] == NSOrderedDescending), @"firstHeadline publish date should be more recent that that of secondHeadline");
}

@end
