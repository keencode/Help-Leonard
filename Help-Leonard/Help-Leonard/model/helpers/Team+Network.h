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
                      onSuccess:(void (^)(NSArray *teams))successBlock
                      onFailure:(void (^)(NSError *error))failureBlock;

+ (void)remoteNewsForTeamURL:(NSString *)url
                   onSuccess:(void (^)(NSArray *headlines))successBlock
                   onFailure:(void (^)(NSError *error))failureBlock;

+ (NSString *)apiURLForSportName:(NSString *)sportName
                      leagueName:(NSString *)leagueName;

+ (NSString *)newsURLWithAPIKey:(NSString *)newsURL;

+ (void)processJSONResponse:(NSDictionary *)json
                  onSuccess:(void (^)(NSArray *teams))successBlock
                  onFailure:(void (^)(NSError *error))failureBlock;

+ (void)processTeamHeadlinesJSONResponse:(NSDictionary *)json
                               onSuccess:(void (^)(NSArray *headlines))successBlock
                               onFailure:(void (^)(NSError *error))failureBlock;

+ (BOOL)JSONIsValid:(id)json;

+ (NSArray *)teamsJSONFromResponse:(NSDictionary *)json;

+ (NSArray *)parseTeamsJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context;

- (void)updateWithInfo:(NSDictionary *)info;

- (void)addFavoriteOnSuccess:(void (^)(BOOL success))successBlock
                   onFailure:(void (^)(NSError *error))failureBlock;

- (void)removeFavoriteOnSuccess:(void (^)(BOOL success))successBlock
                      onFailure:(void (^)(NSError *error))failureBlock;

@end
