//
//  Team+Network.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "Team+Network.h"
#import "WebServiceManager.h"
#import "KCGlobals.h"
#import "Team+Fetch.h"
#import "Headline+Network.h"

@implementation Team (Network)

+ (void)remoteTeamsForSportName:(NSString *)sportName
                     leagueName:(NSString *)leagueName
                      onSuccess:(void (^)(NSArray *teams))successBlock
                      onFailure:(void (^)(NSError *error))failureBlock
{
    NSString *url = [Team apiURLForSportName:sportName leagueName:leagueName];
    
    WebServiceCallbackBlock progressBlock = ^(id data, NSURLResponse *response, NSError *error) {
        //inform user about progress
    };
    
    WebServiceCallbackBlock completionBlock = ^(id data, NSURLResponse *response, NSError *error) {
        if (error) {
            failureBlock(error);
        } else {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            int responseStatusCode = [httpResponse statusCode];
            
            if (responseStatusCode == 200) {
                id json = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingMutableLeaves
                                                            error:&error];
                if (!error) {
                    [Team processJSONResponse:json onSuccess:successBlock onFailure:failureBlock];
                } else {
                    failureBlock(error);
                }
            } else {
                NSDictionary *userInfo = @{kUserInfoDescriptionKey : @"Invalid Status Code"};
                NSError *error = [NSError errorWithDomain:KCNetworkErrorDomain code:KCInvalidStatusCode userInfo:userInfo];
                failureBlock(error);
            }
        }
    };
    
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [urlReq setHTTPMethod:@"GET"];
    
    WebServiceRequest *req = [[WebServiceRequest alloc] initWithURLRequest:urlReq
                                                                  progress:progressBlock
                                                                completion:completionBlock];
    [[WebServiceManager sharedManager] startAsync:req];
}

+ (NSString *)apiURLForSportName:(NSString *)sportName
                      leagueName:(NSString *)leagueName
{
    return [NSString stringWithFormat:@"http://api.espn.com/v1/sports/%@/%@/teams?apikey=%@", sportName, leagueName, kESPNAPIKey];

}

+ (void)processJSONResponse:(NSDictionary *)json
                  onSuccess:(void (^)(NSArray *teams))successBlock
                  onFailure:(void (^)(NSError *error))failureBlock
{
    if ([Team JSONIsValid:json]) {
        NSArray *teamsJSON = [Team teamsJSONFromResponse:json];
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.keencode.helpleonard.backgroundQueue", 0);
        dispatch_async(backgroundQueue, ^{
            NSManagedObjectContext *backgroundContext = [NSManagedObjectContext MR_contextForCurrentThread];
            [Team parseTeamsJSON:teamsJSON inContext:backgroundContext];
            
            [backgroundContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *ids = [Team IDsFromJSON:teamsJSON];
                    NSArray *sortedTeams = [Team sortedTeamsWithIDs:ids];
                    successBlock(sortedTeams);
                });
            }];
        });
    } else {
        NSDictionary *userInfo = @{kUserInfoDescriptionKey : @"Invalid JSON"};
        NSError *error = [NSError errorWithDomain:KCNetworkErrorDomain code:KCInvalidJSON userInfo:userInfo];
        failureBlock(error);
    }
}

+ (BOOL)JSONIsValid:(id)json
{
    if ([json isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)json;
        
        NSDictionary *sportInfo = [[dict objectForKey:@"sports"] objectAtIndex:0];
        if (sportInfo) {
            NSDictionary *leagueInfo = [[sportInfo objectForKey:@"leagues"] objectAtIndex:0];
            
            if (leagueInfo) {
                if ([leagueInfo objectForKey:@"teams"]) {
                    return YES;
                }
            }
            return NO;
        }
        return NO;
    }
    
    return NO;
}

+ (NSArray *)teamsJSONFromResponse:(NSDictionary *)json
{
    NSDictionary *sportInfo = [[json objectForKey:@"sports"] objectAtIndex:0];
    if (sportInfo) {
        NSDictionary *leagueInfo = [[sportInfo objectForKey:@"leagues"] objectAtIndex:0];
        
        if (leagueInfo) {
            if ([leagueInfo objectForKey:@"teams"]) {
                return (NSArray *)[leagueInfo objectForKey:@"teams"];
            }
        }
    }
    
    return nil;
}

+ (NSArray *)parseTeamsJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context
{
    NSArray *localTeams = [Team localTeamsFromJSON:json inContext:context];

    NSMutableArray *teams = [NSMutableArray arrayWithCapacity:[json count]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == $TEAM_ID"];
    
    for (NSDictionary *teamInfo in json) {
        NSString *uid = [teamInfo objectForKey:@"uid"];
        NSDictionary *variable = @{@"TEAM_ID" : uid};
        NSPredicate *localPredicate = [predicate predicateWithSubstitutionVariables:variable];
        NSArray *results = [localTeams filteredArrayUsingPredicate:localPredicate];
        Team *team = nil;

        if ([results count] > 0) {
            team = [results objectAtIndex:0];
        } else {
            team = [Team MR_createInContext:context];
            team.uid = uid;
            team.favorite = [NSNumber numberWithBool:NO];
        }

        [team updateWithInfo:teamInfo];
        [teams addObject:team];
    }
    
    return [NSArray arrayWithArray:teams];
}

- (void)updateWithInfo:(NSDictionary *)info
{
    self.teamID = [info objectForKey:@"id"];
    self.name = [info objectForKey:@"name"];
    self.abbreviation = [info objectForKey:@"abbreviation"];
    self.location = [info objectForKey:@"location"];
    self.nickname = [info objectForKey:@"nickname"];
    self.teamsURL = [[[[info objectForKey:@"links"] objectForKey:@"api"] objectForKey:@"teams"] objectForKey:@"href"];
    self.newsURL = [[[[info objectForKey:@"links"] objectForKey:@"api"] objectForKey:@"news"] objectForKey:@"href"];
    self.notesURL = [[[[info objectForKey:@"links"] objectForKey:@"api"] objectForKey:@"notes"] objectForKey:@"href"];
    self.mobileURL = [[[[info objectForKey:@"links"] objectForKey:@"mobile"] objectForKey:@"teams"] objectForKey:@"href"];
}

//+ (void)remoteDetailsForTeamURL:(NSString *)url
//                      onSuccess:(void (^)(NSArray *news))successBlock
//                      onFailure:(void (^)(NSError *error))failureBlock
//{
//    
//}

+ (void)remoteNewsForTeamURL:(NSString *)url
                   onSuccess:(void (^)(NSArray *headlines))successBlock
                   onFailure:(void (^)(NSError *error))failureBlock
{
    NSString *newsURL = [Team newsURLWithAPIKey:url];
    
    WebServiceCallbackBlock progressBlock = ^(id data, NSURLResponse *response, NSError *error) {
        //inform user about progress
    };
    
    WebServiceCallbackBlock completionBlock = ^(id data, NSURLResponse *response, NSError *error) {
        if (error) {
            failureBlock(error);
        } else {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            int responseStatusCode = [httpResponse statusCode];
            
            if (responseStatusCode == 200) {
                id json = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingMutableLeaves
                                                            error:&error];
                if (!error) {
                    [Headline processJSONResponse:json onSuccess:successBlock onFailure:failureBlock];
                } else {
                    failureBlock(error);
                }
            } else {
                NSDictionary *userInfo = @{kUserInfoDescriptionKey : @"Invalid Status Code"};
                NSError *error = [NSError errorWithDomain:KCNetworkErrorDomain code:KCInvalidStatusCode userInfo:userInfo];
                failureBlock(error);
            }
        }
    };
    
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:newsURL]];
    [urlReq setHTTPMethod:@"GET"];
    
    WebServiceRequest *req = [[WebServiceRequest alloc] initWithURLRequest:urlReq
                                                                  progress:progressBlock
                                                                completion:completionBlock];
    [[WebServiceManager sharedManager] startAsync:req];
}

+ (NSString *)newsURLWithAPIKey:(NSString *)newsURL
{
    return [NSString stringWithFormat:@"%@?apikey=%@", newsURL, kESPNAPIKey];
}

- (void)addFavoriteOnSuccess:(void (^)(BOOL success))successBlock
                   onFailure:(void (^)(NSError *error))failureBlock
{
    [self.managedObjectContext performBlock:^{
        self.favorite = [NSNumber numberWithBool:YES];
        
        [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (!error) {
                if (success) {
                    successBlock(YES);
                } else {
                    NSDictionary *userInfo = @{kUserInfoDescriptionKey : @"Add Favorite Failed"};
                    NSError *error = [NSError errorWithDomain:KCNetworkErrorDomain code:KCAddFavoriteFailure userInfo:userInfo];
                    failureBlock(error);
                }
            } else {
                failureBlock(error);
            }
        }];
    }];
}

- (void)removeFavoriteOnSuccess:(void (^)(BOOL success))successBlock
                      onFailure:(void (^)(NSError *error))failureBlock
{
    [self.managedObjectContext performBlock:^{
        self.favorite = [NSNumber numberWithBool:NO];

        [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (!error) {
                if (success) {
                    successBlock(YES);
                } else {
                    NSDictionary *userInfo = @{kUserInfoDescriptionKey : @"Remove Favorite Failed"};
                    NSError *error = [NSError errorWithDomain:KCNetworkErrorDomain code:KCRemoveFavoriteFailure userInfo:userInfo];
                    failureBlock(error);
                }
            } else {
                failureBlock(error);
            }
        }];
    }];
}

@end
