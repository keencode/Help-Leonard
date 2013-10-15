//
//  KCGlobals.h
//  Help-Leonard
//
//  Created by Yee Peng Chia on 10/12/13.
//  Copyright (c) 2013 Keen Code. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kESPNAPIKey = @"zab45mrzk9jgpxazg4xya4tp";

static NSString * const KCNetworkErrorDomain = @"network.error.keencode.com";

static NSString * const kUserInfoDescriptionKey = @"description";

typedef enum {
    KCInvalidStatusCode,
    KCInvalidJSON,
    KCAddFavoriteFailure,
    KCRemoveFavoriteFailure
} KCNetworkErrorCode;

@interface KCGlobals : NSObject

@end
