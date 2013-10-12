//
//  Headline.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/11/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Headline : NSManagedObject

@property (nonatomic, retain) NSString * ddescription;
@property (nonatomic, retain) NSString * headline;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * published;
@property (nonatomic, retain) NSDate * lastModified;

@end
