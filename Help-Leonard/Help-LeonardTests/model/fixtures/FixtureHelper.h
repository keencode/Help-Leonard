//
//  FixtureHelper.h
//  TweetClass
//
//  Created by Yee Peng Chia on 9/22/13.
//  Copyright (c) 2013 serkoart LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FixtureHelper : NSObject

- (NSData *)validDataFromHeadlinesFixture;
- (NSData *)invalidDataFromHeadlinesFixture;
- (NSData *)errorDataFromHeadlinesFixture;

- (NSData *)validDataFromSportsFixture;
- (NSData *)invalidDataFromSportsFixture;

- (NSData *)validDataFromTeamsFixture;
- (NSData *)invalidDataFromTeamsFixture;

@end
