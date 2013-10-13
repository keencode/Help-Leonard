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
            NSLog(@"error: %@", error);
        } else {
            id json = [NSJSONSerialization JSONObjectWithData:data
                                                      options:NSJSONReadingMutableLeaves
                                                        error:&error];
            if (!error) {
                [Sport processJSONResponse:json onSuccess:successBlock onFailure:failureBlock];
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
                    NSArray *sports = [Sport localSportsInAlphabeticalOrder];
                    successBlock(sports);
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
    
    NSMutableArray *sports = [NSMutableArray arrayWithCapacity:[json count]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == $SPORT_ID"];
    
    for (NSDictionary *sportInfo in json) {
        NSNumber *tempID = (NSNumber *)[sportInfo objectForKey:@"id"];
        NSDictionary *variable = @{@"SPORT_ID" : tempID};
        NSPredicate *localPredicate = [predicate predicateWithSubstitutionVariables:variable];
        Sport *sport = nil;
        
        NSArray *results = [localSports filteredArrayUsingPredicate:localPredicate];
        if ([results count] > 0) {
            sport = [results objectAtIndex:0];
        } else {
            sport = [Sport MR_createInContext:context];
            sport.uid = (NSNumber *)[sportInfo objectForKey:@"id"];
        }
        
        [sport updateWithInfo:sportInfo];
        
        NSArray *leaguesInfo = [sportInfo objectForKey:@"leagues"];
        for (NSDictionary *leagueInfo in leaguesInfo) {
            League *league = [League MR_createInContext:context];
            [league updateWithInfo:leagueInfo];
            league.sport = sport;
        }
        
        [sports addObject:sport];
    }
    
    return [NSArray arrayWithArray:sports];
}

- (void)updateWithInfo:(NSDictionary *)info
{
    self.name = (NSString *)[info objectForKey:@"name"];
}

@end
