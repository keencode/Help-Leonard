//
//  League+Fetch.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "League+Fetch.h"

@implementation League (Fetch)

+ (NSArray *)abbreviationsFromJSON:(NSArray *)json
{
    NSMutableArray *abbreviations = [NSMutableArray array];
    
    for (NSDictionary *sportInfo in json) {
        NSArray *leagues = [sportInfo objectForKey:@"leagues"];
        
        for (NSDictionary *leagueInfo in leagues) {
            NSNumber *abbrev = [leagueInfo objectForKey:@"abbreviation"];
            [abbreviations addObject:abbrev];
        }
    }
    
    return abbreviations;
}

+ (NSArray *)fetchLeaguesWithAbbreviations:(NSArray *)abbreviations inContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"abbreviation IN %@", abbreviations];
    return [League MR_findAllWithPredicate:predicate inContext:context];
}

+ (NSArray *)localLeaguesFromJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context
{
    NSArray *abbreviations = [League abbreviationsFromJSON:json];
    return [League fetchLeaguesWithAbbreviations:abbreviations inContext:context];
}

@end
