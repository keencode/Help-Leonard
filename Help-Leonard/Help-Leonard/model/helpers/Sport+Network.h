//
//  Sport+Network.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "Sport.h"

@interface Sport (Network)

+ (void)remoteSportsOnSuccess:(void (^)(NSArray *headlines))successBlock
                    onFailure:(void (^)(NSError *error))failureBlock;

+ (void)processJSONResponse:(NSDictionary *)json
                  onSuccess:(void (^)(NSArray *headlines))successBlock
                  onFailure:(void (^)(NSError *error))failureBlock;

+ (BOOL)JSONIsValid:(id)json;

+ (NSArray *)parseSportsJSON:(NSArray *)json inContext:(NSManagedObjectContext *)context;

- (void)updateWithInfo:(NSDictionary *)info;

@end
