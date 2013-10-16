//
//  CoreDataHelper.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/15/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "CoreDataHelper.h"
#import "Headline.h"

@implementation CoreDataHelper

- (id)init
{
    self = [super init];
    if (self) {
        [self cleanAndResetDB];
        [self setupDB];
    }
    
    return self;
}

- (void)setupDB
{
    [MagicalRecord setDefaultModelFromClass:[Headline class]];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    self.managedObjectContext = [NSManagedObjectContext MR_defaultContext];
}

- (void)cleanAndResetDB
{
    NSString *dbStore = [self dbStore];
    NSError *error = nil;
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:dbStore];
    [MagicalRecord cleanUp];
    
    if ([[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error]){
        //
    } else {
        NSLog(@"An error has occurred while deleting %@", dbStore);
        NSLog(@"Error description: %@", error.description);
    }
}

- (NSString *)dbStore
{
    NSString *bundleID = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    return [NSString stringWithFormat:@"%@.sqlite", bundleID];
}

@end
