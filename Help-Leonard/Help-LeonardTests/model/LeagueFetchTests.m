//
//  LeagueFetchTests.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "League+Fetch.h"
#import "FixtureHelper.h"

@interface LeagueFetchTests : XCTestCase
{
    NSManagedObjectContext *managedObjectContext;
    NSArray *sportsJSON;
}

@end

@implementation LeagueFetchTests

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
    
    [MagicalRecord setDefaultModelFromClass:[League class]];
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
