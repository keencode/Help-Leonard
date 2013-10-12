//
//  Headline+Fetch.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/11/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "Headline+Fetch.h"

#define kBatchSize 10

@implementation Headline (Fetch)

+ (NSArray *)IDsFromJSON:(NSArray *)json
{
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:[json count]];
    
    for (NSDictionary *infoDict in json) {
        NSNumber *tempID = (NSNumber *)[infoDict objectForKey:@"id"];
        [ids addObject:tempID];
    }
    
    return ids;
}

+ (NSArray *)fetchHeadlinesWithIDs:(NSArray *)ids inContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid IN %@", ids];
    return [Headline MR_findAllWithPredicate:predicate inContext:context];
}

+ (NSArray *)localHeadlinesFromJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context
{
    NSArray *ids = [Headline IDsFromJSON:json];
    return [Headline fetchHeadlinesWithIDs:ids inContext:context];
}

+ (NSArray *)fetchRecentHeadlines
{
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *request = [Headline MR_requestAllInContext:defaultContext];
    [request setFetchBatchSize:kBatchSize];
    return [Headline MR_findAllSortedBy:@"published" ascending:NO inContext:defaultContext];
}

@end
