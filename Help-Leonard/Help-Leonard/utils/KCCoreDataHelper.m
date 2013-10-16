//
//  KCCoreDataHelper.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/15/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "KCCoreDataHelper.h"

@implementation KCCoreDataHelper

+ (NSArray *)objectIDsForManagedObjects:(NSArray *)managedObjects
{
    NSMutableArray *objectIDs = [NSMutableArray arrayWithCapacity:[managedObjects count]];
    
    [managedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSManagedObject *managedObject = (NSManagedObject *)obj;
        [objectIDs addObject:managedObject.objectID];
    }];
    
    return objectIDs;
}

+ (NSArray *)managedObjectsForObjectIDs:(NSArray *)objectIDs inContext:(NSManagedObjectContext *)context
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[objectIDs count]];
    
    [objectIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSManagedObject *managedObject = [context objectWithID:obj];
        [objects addObject:managedObject];
    }];

    return [NSArray arrayWithArray:objects];
}

@end
