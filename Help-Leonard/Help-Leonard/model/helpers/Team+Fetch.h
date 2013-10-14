//
//  Team+Fetch.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "Team.h"

@interface Team (Fetch)

+ (NSArray *)IDsFromJSON:(NSArray *)json;
+ (NSArray *)fetchTeamsWithIDs:(NSArray *)ids inContext:(NSManagedObjectContext *)context;
+ (NSArray *)localTeamsFromJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context;
+ (NSArray *)sortedTeamsWithIDs:(NSArray *)ids;

@end
