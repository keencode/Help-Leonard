//
//  Sport+Fetch.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "Sport.h"

@interface Sport (Fetch)

+ (NSArray *)IDsFromJSON:(NSArray *)json;
+ (NSArray *)fetchSportsWithIDs:(NSArray *)ids inContext:(NSManagedObjectContext *)context;
+ (NSArray *)localSportsFromJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context;
+ (NSArray *)fetchSportsInAlphabeticalOrder;

- (NSArray *)sortedLeagues;

@end
