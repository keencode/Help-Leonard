//
//  League+Network.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/13/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "League+Network.h"

@implementation League (Network)

- (void)updateWithInfo:(NSDictionary *)info
{
    self.uid = (NSNumber *)[info objectForKey:@"id"];
    self.name = (NSString *)[info objectForKey:@"name"];
}

@end
