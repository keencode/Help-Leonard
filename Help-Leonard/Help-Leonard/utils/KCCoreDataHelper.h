//
//  KCCoreDataHelper.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/15/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCCoreDataHelper : NSObject

+ (NSArray *)objectIDsForManagedObjects:(NSArray *)managedObjects;

+ (NSArray *)managedObjectsForObjectIDs:(NSArray *)objectIDs inContext:(NSManagedObjectContext *)context;

@end
