//
//  CoreDataHelperTests.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/15/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataTestHelper.h"
#import "KCCoreDataHelper.h"
#import "Headline.h"

@interface CoreDataHelperTests : XCTestCase
{
    NSManagedObjectContext *managedObjectContext;
}

@end

@implementation CoreDataHelperTests

- (void)setUp
{
    [super setUp];
    
    CoreDataTestHelper *coreDataHelper = [[CoreDataTestHelper alloc] init];
    managedObjectContext = coreDataHelper.managedObjectContext;
}

- (void)tearDown
{
    managedObjectContext = nil;
    
    [super tearDown];
}

#pragma mark - objectIDsForManagedObjects

- (void)testObjectIDsForManagedObjectsShouldReturnNonNilObject
{
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    Headline *headline2 = [Headline MR_createInContext:managedObjectContext];
    NSArray *managedObjects = @[headline1, headline2];
    
    id objectIDs = [KCCoreDataHelper objectIDsForManagedObjects:managedObjects];
    
    XCTAssertNotNil(objectIDs, @"objectIDs should not be nil");
}

- (void)testObjectIDsForManagedObjectsShouldReturnAnArray
{
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    Headline *headline2 = [Headline MR_createInContext:managedObjectContext];
    NSArray *managedObjects = @[headline1, headline2];
    
    id objectIDs = [KCCoreDataHelper objectIDsForManagedObjects:managedObjects];
    
    XCTAssertTrue([objectIDs isKindOfClass:[NSArray class]], @"objectIDs should an NSArray");
}

- (void)testObjectIDsForManagedObjectsShouldReturnCorrectCount
{
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    Headline *headline2 = [Headline MR_createInContext:managedObjectContext];
    NSArray *managedObjects = @[headline1, headline2];
    NSUInteger expectedCount = [managedObjects count];
    
    id objectIDs = [KCCoreDataHelper objectIDsForManagedObjects:managedObjects];
    
    XCTAssertEqual([objectIDs count], expectedCount, @"objectIDs count should equal expectedCount");
}

- (void)testObjectIDsForManagedObjectsShouldContainExpectedObjectID
{
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    NSArray *managedObjects = @[headline1];
    NSManagedObjectID *expectedObjectID = headline1.objectID;
    
    id objectIDs = [KCCoreDataHelper objectIDsForManagedObjects:managedObjects];
    
    XCTAssertTrue([objectIDs containsObject:expectedObjectID], @"objectIDs should contain expectedObjectID");
}

#pragma mark - managedObjectsForObjectIDs

- (void)testManagedObjectsForObjectIDsShouldReturnNonNilObject
{
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    Headline *headline2 = [Headline MR_createInContext:managedObjectContext];
    NSArray *objectIDs = @[headline1.objectID, headline2.objectID];
    
    id managedObjects = [KCCoreDataHelper managedObjectsForObjectIDs:objectIDs inContext:managedObjectContext];
    
    XCTAssertNotNil(managedObjects, @"managedObjects should not be nil");
}

- (void)testManagedObjectsForObjectIDsShouldReturnAnArray
{
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    Headline *headline2 = [Headline MR_createInContext:managedObjectContext];
    NSArray *objectIDs = @[headline1.objectID, headline2.objectID];
    
    id managedObjects = [KCCoreDataHelper managedObjectsForObjectIDs:objectIDs inContext:managedObjectContext];
    
    XCTAssertTrue([managedObjects isKindOfClass:[NSArray class]], @"managedObjects should an NSArray");
}

- (void)testManagedObjectsForObjectIDsShouldReturnCorrectCount
{
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    Headline *headline2 = [Headline MR_createInContext:managedObjectContext];
    NSArray *objectIDs = @[headline1.objectID, headline2.objectID];
    NSUInteger expectedCount = [objectIDs count];
    
    id managedObjects = [KCCoreDataHelper managedObjectsForObjectIDs:objectIDs inContext:managedObjectContext];
    
    XCTAssertEqual([managedObjects count], expectedCount, @"managedObjects count should equal expectedCount");
}

- (void)testManagedObjectsForObjectIDsShouldContainExpectedObjectID
{
    Headline *headline1 = [Headline MR_createInContext:managedObjectContext];
    NSArray *objectIDs = @[headline1.objectID];
    
    id managedObjects = [KCCoreDataHelper managedObjectsForObjectIDs:objectIDs inContext:managedObjectContext];
    
    XCTAssertTrue([managedObjects containsObject:headline1], @"managedObjects should contain headline1");
}

@end
