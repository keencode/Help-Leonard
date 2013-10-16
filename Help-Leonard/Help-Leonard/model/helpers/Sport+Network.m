//
//  Sport+Network.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "Sport+Network.h"
#import "WebServiceManager.h"
#import "KCGlobals.h"
#import "Sport+Fetch.h"
#import "League+Fetch.h"
#import "League+Network.h"

@implementation Sport (Network)

+ (void)remoteSportsOnSuccess:(void (^)(NSArray *))successBlock onFailure:(void (^)(NSError *))failureBlock
{
    NSString *url = [NSString stringWithFormat:@"http://api.espn.com/v1/sports?apikey=%@", kESPNAPIKey];
    
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
                    [Sport processJSONResponse:json onSuccess:successBlock onFailure:failureBlock];
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

+ (void)processJSONResponse:(NSDictionary *)json
                  onSuccess:(void (^)(NSArray *headlines))successBlock
                  onFailure:(void (^)(NSError *error))failureBlock
{
    if ([Sport JSONIsValid:json]) {
        NSArray *sportsJSON = [json objectForKey:@"sports"];
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.keencode.helpleonard.backgroundQueue", 0);
        dispatch_async(backgroundQueue, ^{
            NSManagedObjectContext *backgroundContext = [NSManagedObjectContext MR_contextForCurrentThread];
            [Sport parseSportsJSON:sportsJSON inContext:backgroundContext];
            
            [backgroundContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *sports = [Sport fetchSortedSports];
                    successBlock(sports);
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
        
        if ([dict objectForKey:@"sports"]) {
            return YES;
        }
        
        return NO;
    }
    
    return NO;
}

+ (NSArray *)parseSportsJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context
{
    NSArray *localSports = [Sport localSportsFromJSON:json inContext:context];
    NSArray *localLeagues = [League localLeaguesFromJSON:json inContext:context];
    
    NSMutableArray *sports = [NSMutableArray arrayWithCapacity:[json count]];
    
    NSPredicate *sportPredicate = [NSPredicate predicateWithFormat:@"uid == $SPORT_ID"];
    NSPredicate *leaguePredicate = [NSPredicate predicateWithFormat:@"abbreviation == $LEAGUE_ABBREV"];
    
    for (NSDictionary *sportInfo in json) {
        NSNumber *sportID = [sportInfo objectForKey:@"id"];
        NSDictionary *sportVar = @{@"SPORT_ID" : sportID};
        NSPredicate *localSportPredicate = [sportPredicate predicateWithSubstitutionVariables:sportVar];
        NSArray *results = [localSports filteredArrayUsingPredicate:localSportPredicate];
        Sport *sport = nil;
        
        if ([results count] > 0) {
            sport = [results objectAtIndex:0];
        } else {
            sport = [Sport MR_createInContext:context];
            sport.uid = sportID;
        }
        
        [sport updateWithInfo:sportInfo];
        
        NSArray *leaguesInfo = [sportInfo objectForKey:@"leagues"];
        for (NSDictionary *leagueInfo in leaguesInfo) {
            NSString *leagueAbbrev = [leagueInfo objectForKey:@"abbreviation"];
            NSDictionary *sportVar = @{@"LEAGUE_ABBREV" : leagueAbbrev};
            NSPredicate *localLeaguePredicate = [leaguePredicate predicateWithSubstitutionVariables:sportVar];
            NSArray *results = [localLeagues filteredArrayUsingPredicate:localLeaguePredicate];
            League *league = nil;

            if ([results count] > 0) {
                league = [results objectAtIndex:0];
            } else {
                league = [League MR_createInContext:context];
                league.abbreviation = leagueAbbrev;
            }

            [league updateWithInfo:leagueInfo];
            league.sport = sport;
        }
        
        [sports addObject:sport];
    }
    
    return [NSArray arrayWithArray:sports];
}

- (void)updateWithInfo:(NSDictionary *)info
{
    self.name = [info objectForKey:@"name"];
}

@end
