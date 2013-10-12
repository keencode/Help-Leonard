//
//  KCDateHelper.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/11/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCDateHelper : NSObject

+ (NSDate *)dateFromFormattedString:(NSString *)str;
+ (NSString *)formattedStringFromDate:(NSDate *)date;

@end
