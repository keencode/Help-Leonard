//
//  LeagueFetchTests.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataTestHelper.h"
#import "FixtureHelper.h"
#import "League+Fetch.h"

@interface LeagueFetchTests : XCTestCase
{
    NSManagedObjectContext *managedObjectContext;
    NSArray *sportsJSON;
}

@end

@implementation LeagueFetchTests

- (void)setUp
{
    [super setUp];
    
    CoreDataTestHelper *coreDataHelper = [[CoreDataTestHelper alloc] init];
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

#pragma mark - abbreviationsFromJSON

- (void)testAbbreviationsFromJSONShouldReturnANonNilObject
{
    id abbreviationsFromJSON = [League abbreviationsFromJSON:sportsJSON];
    
    XCTAssertNotNil(abbreviationsFromJSON, @"abbreviationsFromJSON should NOT be nil");
}

- (void)testAbbreviationsFromJSONShouldReturnAnArray
{
    id abbreviationsFromJSON = [League abbreviationsFromJSON:sportsJSON];
    
    XCTAssertTrue([abbreviationsFromJSON isKindOfClass:[NSArray class]], @"abbreviationsFromJSON should be an NSArray");
}

- (void)testAbbreviationsFromJSONShouldReturnExpectedCount
{
    NSUInteger expectedLeaguesCount = 0;
    
    for (NSDictionary *sportInfo in sportsJSON) {
        NSArray *leagues = [sportInfo objectForKey:@"leagues"];
        expectedLeaguesCount += [leagues count];
    }
    
    NSArray *abbreviationsFromJSON = [League abbreviationsFromJSON:sportsJSON];
    
    XCTAssertEqual([abbreviationsFromJSON count], expectedLeaguesCount, @"abbreviationsFromJSON count should equal expectedLeaguesCount");
}

@end
