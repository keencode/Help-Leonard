//
//  Team.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/14/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class League;

@interface Team : NSManagedObject

@property (nonatomic, retain) NSString * abbreviation;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * newsURL;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * notesURL;
@property (nonatomic, retain) NSNumber * teamID;
@property (nonatomic, retain) NSString * teamsURL;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * mobileURL;
@property (nonatomic, retain) League *league;

@end
