//
//  Team+Network.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "Team.h"

@interface Team (Network)

+ (void)remoteTeamsForSportName:(NSString *)sportName
                     leagueName:(NSString *)leagueName
                      onSuccess:(void (^)(NSArray *headlines))successBlock
                      onFailure:(void (^)(NSError *error))failureBlock;

+ (NSString *)apiURLForSportName:(NSString *)sportName
                      leagueName:(NSString *)leagueName;

+ (void)processJSONResponse:(NSDictionary *)json
                  onSuccess:(void (^)(NSArray *headlines))successBlock
                  onFailure:(void (^)(NSError *error))failureBlock;

+ (BOOL)JSONIsValid:(id)json;

+ (NSArray *)teamsJSONFromResponse:(NSDictionary *)json;

+ (NSArray *)parseTeamsJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context;

- (void)updateWithInfo:(NSDictionary *)info;

@end
