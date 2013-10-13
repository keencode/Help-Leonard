//
//  Headline+Network.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/11/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "Headline+Network.h"
#import "Headline+Fetch.h"
#import "KCDateHelper.h"
#import "WebServiceManager.h"
#import "KCGlobals.h"

@implementation Headline (Network)

+ (void)remoteHeadlinesOnSuccess:(void (^)(NSArray *headlines))successBlock
                       onFailure:(void (^)(NSError *error))failureBlock
{
    NSString *url = [NSString stringWithFormat:@"http://api.espn.com/v1/sports/news/headlines?apikey=%@", kESPNAPIKey];
    
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
                [Headline handleJSONResponse:json onSuccess:successBlock onFailure:failureBlock];
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

+ (void)handleJSONResponse:(NSDictionary *)json
                 onSuccess:(void (^)(NSArray *headlines))successBlock
                 onFailure:(void (^)(NSError *error))failureBlock
{
    if ([Headline JSONIsValid:json]) {
        NSArray *headlinesJSON = [json objectForKey:@"headlines"];
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.keencode.helpleonard.backgroundQueue", 0);
        dispatch_async(backgroundQueue, ^{
            NSManagedObjectContext *backgroundContext = [NSManagedObjectContext MR_contextForCurrentThread];
            [Headline parseHeadlinesJSON:headlinesJSON inContext:backgroundContext];
            
            [backgroundContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *ids = [Headline IDsFromJSON:headlinesJSON];
                    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
                    NSArray *headlines = [Headline fetchHeadlinesWithIDs:ids inContext:defaultContext];
                    successBlock(headlines);
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
        
        if ([[dict objectForKey:@"status"] isEqualToString:@"success"]) {
            if ([dict objectForKey:@"headlines"]) {
                return YES;
            }
        }
        
        return NO;
    }
    
    return NO;
}

+ (NSArray *)parseHeadlinesJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context
{
    NSArray *localHeadlines = [Headline localHeadlinesFromJSON:json
                                                     inContext:context];
    
    NSMutableArray *headlines = [NSMutableArray arrayWithCapacity:[json count]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == $HEADLINE_ID"];
    
    for (NSDictionary *info in json) {
        NSNumber *tempID = (NSNumber *)[info objectForKey:@"id"];
        NSDictionary *variable = @{@"HEADLINE_ID" : tempID};
        NSPredicate *localPredicate = [predicate predicateWithSubstitutionVariables:variable];
        Headline *headline = nil;
        
        NSArray *results = [localHeadlines filteredArrayUsingPredicate:localPredicate];
        if ([results count] > 0) {
            headline = [results objectAtIndex:0];
        } else {
            headline = [Headline MR_createInContext:context];
            headline.uid = (NSNumber *)[info objectForKey:@"id"];
        }
        
        [headline updateWithInfo:info];
        [headlines addObject:headline];
    }
    
    return [NSArray arrayWithArray:headlines];
}

- (void)updateWithInfo:(NSDictionary *)info
{
    self.title = (NSString *)[info objectForKey:@"title"];
    self.headline = (NSString *)[info objectForKey:@"headline"];
    self.ddescription = (NSString *)[info objectForKey:@"description"];
    
    NSString *published = (NSString *)[info objectForKey:@"published"];
    self.published = [KCDateHelper dateFromFormattedString:published];
    
    NSString *lastModified = (NSString *)[info objectForKey:@"lastModified"];
    self.lastModified = [KCDateHelper dateFromFormattedString:lastModified];
}

@end
