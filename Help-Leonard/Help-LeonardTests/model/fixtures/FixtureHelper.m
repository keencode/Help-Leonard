//
//  FixtureHelper.m
//  TweetClass
//
//  Created by Yee Peng Chia on 9/22/13.
//  Copyright (c) 2013 serkoart LLC. All rights reserved.
//

#import "FixtureHelper.h"

@implementation FixtureHelper

- (id)dataFromFixtureWithName:(NSString *)fileName
{
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:@"json"];
    return [NSData dataWithContentsOfFile:filePath];
}

- (NSData *)validDataFromHeadlinesFixture
{
    return [self dataFromFixtureWithName:@"headlines"];
}

- (NSData *)invalidDataFromHeadlinesFixture
{
    return [self dataFromFixtureWithName:@"headlines_invalid"];
}

- (NSData *)errorDataFromHeadlinesFixture
{
    return [self dataFromFixtureWithName:@"headlines_error"];
}

- (NSData *)validDataFromSportsFixture
{
    return [self dataFromFixtureWithName:@"sports"];
}

- (NSData *)invalidDataFromSportsFixture
{
    return [self dataFromFixtureWithName:@"sports_invalid"];
}

@end
