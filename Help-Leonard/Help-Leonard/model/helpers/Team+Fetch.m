//
//  Team+Fetch.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "Team+Fetch.h"

#define kBatchSize 100

@implementation Team (Fetch)

+ (NSArray *)IDsFromJSON:(NSArray *)json
{
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:[json count]];
    
    for (NSDictionary *infoDict in json) {
        NSNumber *tempID = (NSNumber *)[infoDict objectForKey:@"uid"];
        [ids addObject:tempID];
    }
    
    return ids;
}

+ (NSArray *)fetchTeamsWithIDs:(NSArray *)ids inContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid IN %@", ids];
    return [Team MR_findAllWithPredicate:predicate inContext:context];
}

+ (NSArray *)localTeamsFromJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context
{
    NSArray *ids = [Team IDsFromJSON:json];
    return [Team fetchTeamsWithIDs:ids inContext:context];
}

+ (NSArray *)sortedTeamsWithIDs:(NSArray *)ids
{
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *request = [Team MR_requestAllInContext:defaultContext];
    [request setFetchBatchSize:kBatchSize];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid IN %@", ids];
    return [Team MR_findAllSortedBy:@"name" ascending:YES withPredicate:predicate inContext:defaultContext];
}

@end
