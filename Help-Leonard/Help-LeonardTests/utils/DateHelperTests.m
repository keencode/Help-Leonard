//
//  DateHelperTests.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/11/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KCDateHelper.h"

@interface DateHelperTests : XCTestCase

@end

@implementation DateHelperTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testDateFromFormattedStringShouldMatchExpectedYear
{
    NSString *dateStr = @"2013-10-11T15:25:35Z";
    NSString *expectedYear = @"2013";
    
    NSDate *date = [KCDateHelper dateFromFormattedString:dateStr];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    dateFormatter.dateFormat = @"YYYY";
    NSString *year = [dateFormatter stringFromDate:date];
    
    XCTAssertEqualObjects(year, expectedYear, @"year should match expectedYear");
}

- (void)testDateFromFormattedStringShouldMatchExpectedMonth
{
    NSString *dateStr = @"2013-10-11T15:25:35Z";
    NSString *expectedMonth = @"10";
    
    NSDate *date = [KCDateHelper dateFromFormattedString:dateStr];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    dateFormatter.dateFormat = @"MM";
    NSString *month = [dateFormatter stringFromDate:date];
    
    XCTAssertEqualObjects(month, expectedMonth, @"month should match expectedMonth");
}

- (void)testDateFromFormattedStringShouldMatchExpectedDay
{
    NSString *dateStr = @"2013-10-11T15:25:35Z";
    NSString *expectedDay = @"11";
    
    NSDate *date = [KCDateHelper dateFromFormattedString:dateStr];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    dateFormatter.dateFormat = @"dd";
    NSString *day = [dateFormatter stringFromDate:date];
    
    XCTAssertEqualObjects(day, expectedDay, @"day should match expectedDay");
}

- (void)testDateFromFormattedStringShouldMatchExpectedHour
{
    NSString *dateStr = @"2013-10-11T15:25:35Z";
    NSString *expectedHour = @"15";
    
    NSDate *date = [KCDateHelper dateFromFormattedString:dateStr];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    dateFormatter.dateFormat = @"HH";
    NSString *hour = [dateFormatter stringFromDate:date];
    
    XCTAssertEqualObjects(hour, expectedHour, @"hour should match expectedHour");
}

- (void)testDateFromFormattedStringShouldMatchExpectedMinutes
{
    NSString *dateStr = @"2013-10-11T15:25:35Z";
    NSString *expectedMins = @"25";
    
    NSDate *date = [KCDateHelper dateFromFormattedString:dateStr];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    dateFormatter.dateFormat = @"mm";
    NSString *minutes = [dateFormatter stringFromDate:date];
    
    XCTAssertEqualObjects(minutes, expectedMins, @"minutes should match expectedMins");
}

- (void)testDateFromFormattedStringShouldMatchExpectedSeconds
{
    NSString *dateStr = @"2013-10-11T15:25:35Z";
    NSString *expectedSecs = @"35";
    
    NSDate *date = [KCDateHelper dateFromFormattedString:dateStr];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    dateFormatter.dateFormat = @"ss";
    NSString *seconds = [dateFormatter stringFromDate:date];
    
    XCTAssertEqualObjects(seconds, expectedSecs, @"seconds should match expectedSecs");
}

- (void)testFormattedStringFromDate
{
    NSString *dateStr = @"2013-10-11T15:25:35Z";
    NSDate *date = [KCDateHelper dateFromFormattedString:dateStr];
    NSString *expectedDateStr = @"October 11, 2013 11:25 AM";
 
    NSString *formattedDateStr = [KCDateHelper formattedStringFromDate:date];
    NSLog(@"formattedDateStr: %@", formattedDateStr);
    
    XCTAssertEqualObjects(formattedDateStr, expectedDateStr, @"formattedDateStr should match expectedDateStr");
}

@end
