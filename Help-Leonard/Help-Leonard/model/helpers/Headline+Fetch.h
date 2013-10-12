//
//  Headline+Fetch.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/11/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "Headline.h"

@interface Headline (Fetch)

+ (NSArray *)IDsFromJSON:(NSArray *)json;
+ (NSArray *)fetchHeadlinesWithIDs:(NSArray *)ids inContext:(NSManagedObjectContext *)context;
+ (NSArray *)localHeadlinesFromJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context;
+ (NSArray *)fetchRecentHeadlines;

@end
