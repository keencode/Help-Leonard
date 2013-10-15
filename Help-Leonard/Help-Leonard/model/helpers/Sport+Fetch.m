//
//  Sport+Fetch.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "Sport+Fetch.h"

#define kBatchSize 100

@implementation Sport (Fetch)

+ (NSArray *)IDsFromJSON:(NSArray *)json
{
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:[json count]];
    
    for (NSDictionary *infoDict in json) {
        NSNumber *tempID = [infoDict objectForKey:@"id"];
        [ids addObject:tempID];
    }
    
    return ids;
}

+ (NSArray *)fetchSportsWithIDs:(NSArray *)ids inContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid IN %@", ids];
    return [Sport MR_findAllWithPredicate:predicate inContext:context];
}

+ (NSArray *)localSportsFromJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context
{
    NSArray *ids = [Sport IDsFromJSON:json];
    return [Sport fetchSportsWithIDs:ids inContext:context];
}

+ (NSArray *)fetchSportsInAlphabeticalOrder
{
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *request = [Sport MR_requestAllInContext:defaultContext];
    [request setFetchBatchSize:kBatchSize];
    return [Sport MR_findAllSortedBy:@"name" ascending:YES inContext:defaultContext];
}

- (NSArray *)sortedLeagues
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                     ascending:YES
                                                                      selector:@selector(caseInsensitiveCompare:)];
    return [self.leagues sortedArrayUsingDescriptors:@[sortDescriptor]];
}

@end
