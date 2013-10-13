//
//  Sport.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class League;

@interface Sport : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSSet *leagues;
@end

@interface Sport (CoreDataGeneratedAccessors)

- (void)addLeaguesObject:(League *)value;
- (void)removeLeaguesObject:(League *)value;
- (void)addLeagues:(NSSet *)values;
- (void)removeLeagues:(NSSet *)values;

@end
