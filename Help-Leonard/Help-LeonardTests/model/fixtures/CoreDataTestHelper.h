//
//  CoreDataHelper.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/15/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataTestHelper : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)setupDB;
- (void)cleanAndResetDB;
- (NSString *)dbStore;

@end
