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

@implementation Team (Network)

+ (void)remoteTeamsForSportName:(NSString *)sportName
                     leagueName:(NSString *)leagueName
                      onSuccess:(void (^)(NSArray *headlines))successBlock
                      onFailure:(void (^)(NSError *error))failureBlock
{
    NSString *url = [Team apiURLForSportName:sportName leagueName:leagueName];
    
    WebServiceCallbackBlock progressBlock = ^(id data, NSURLResponse *response, NSError *error) {
        //inform user about progress
    };
    
    WebServiceCallbackBlock completionBlock = ^(id data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            id json = [NSJSONSerialization JSONObjectWithData:data
                                                      options:NSJSONReadingMutableLeaves
                                                        error:&error];
            if (!error) {
                [Team processJSONResponse:json onSuccess:successBlock onFailure:failureBlock];
            } else {
                NSLog(@"error loading fixture: %@", [error userInfo]);
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
                  onSuccess:(void (^)(NSArray *headlines))successBlock
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
        // TODO: Handle invalid JSON error
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
        NSString *uid = (NSString *)[teamInfo objectForKey:@"uid"];
        NSDictionary *variable = @{@"TEAM_ID" : uid};
        NSPredicate *localPredicate = [predicate predicateWithSubstitutionVariables:variable];
        NSArray *results = [localTeams filteredArrayUsingPredicate:localPredicate];
        Team *team = nil;

        if ([results count] > 0) {
            team = [results objectAtIndex:0];
        } else {
            team = [Team MR_createInContext:context];
            team.uid = uid;
        }

        [team updateWithInfo:teamInfo];
        [teams addObject:team];
    }
    
    return [NSArray arrayWithArray:teams];
}

- (void)updateWithInfo:(NSDictionary *)info
{
    self.teamID = (NSNumber *)[info objectForKey:@"id"];
    self.name = (NSString *)[info objectForKey:@"name"];
    self.abbreviation = (NSString *)[info objectForKey:@"abbreviation"];
    self.location = (NSString *)[info objectForKey:@"location"];
    self.nickname = (NSString *)[info objectForKey:@"nickname"];
    self.teamsURL = (NSString *)[[[[info objectForKey:@"links"] objectForKey:@"api"] objectForKey:@"teams"] objectForKey:@"href"];
    self.newsURL = (NSString *)[[[[info objectForKey:@"links"] objectForKey:@"api"] objectForKey:@"news"] objectForKey:@"href"];
    self.notesURL = (NSString *)[[[[info objectForKey:@"links"] objectForKey:@"api"] objectForKey:@"notes"] objectForKey:@"href"];
}

@end
