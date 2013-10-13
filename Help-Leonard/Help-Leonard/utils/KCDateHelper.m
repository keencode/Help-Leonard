//
//  KCDateHelper.m
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/11/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import "KCDateHelper.h"

@implementation KCDateHelper

+ (NSDate *)dateFromFormattedString:(NSString *)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY'-'MM'-'dd'T'HH':'mm':'ss'Z'";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    return [dateFormatter dateFromString:str];
}

+ (NSString *)formattedStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM dd, YYYY hh:mm a";
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    return [dateFormatter stringFromDate:date];
}

@end
