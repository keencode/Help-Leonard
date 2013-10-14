//
//  League+Fetch.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "League.h"

@interface League (Fetch)

+ (NSArray *)abbreviationsFromJSON:(NSArray *)json;
+ (NSArray *)fetchLeaguesWithAbbreviations:(NSArray *)abbreviations inContext:(NSManagedObjectContext *)context;
+ (NSArray *)localLeaguesFromJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context;

@end
