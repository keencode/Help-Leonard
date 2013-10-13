//
//  Headline+Network.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/11/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "Headline.h"

@interface Headline (Network)

+ (void)remoteHeadlinesOnSuccess:(void (^)(NSArray *headlines))successBlock
                       onFailure:(void (^)(NSError *error))failureBlock;

+ (void)processJSONResponse:(NSDictionary *)json
                  onSuccess:(void (^)(NSArray *headlines))successBlock
                  onFailure:(void (^)(NSError *error))failureBlock;

+ (BOOL)JSONIsValid:(id)json;

+ (NSArray *)parseHeadlinesJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context;

- (void)updateWithInfo:(NSDictionary *)info;

@end
