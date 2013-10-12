//
//  WebServiceAuthProtocol.h
//
//  Copyright (c) 2013 Applico Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceRequest.h"

/**
 * @brief Classes implementing this protocol can be used to authorize WebServiceRequests.
 *
 * Implementation Notes
 * --------------------
 * All classes adhering to this protocol must implement the NSCoding protocol. This enables
 * encoding/decoding for the saving of auth information to the keychain.
 * 
 * Signing Requests
 * ----------------
 * The method used to sign requests is signRequestIfNecessary. An NSMutableURLRequest is
 * passed into the method so that the object can perform the necessary changes to allow
 * authentication to succeed. Typically this involves adding appropriate headers to the request.
 * It may also involve changing the URL to add query parameters, though in this case the
 * method should check for existing query parameters and when they are present, add to them.
 * 
 *
 * Keychain Saving
 * ---------------
 * All objects implementing this protocol should conform to NSCoding so that they can be archived
 * by the WebServiceManager to the keychain. Typically one would like to cache tokens because in
 * mobile world a token may be valid for several hours to months. Extra requests to re-authorize 
 * can be avoided by saving tokens to the keychain.
 *
 * Because these objects can be saved to the keychain they should be kept to a the minimum size 
 * needed to save authorization data. Tokens, expiration date, username and password are examples 
 * of data that might be kept.
 *
 * Auth information is identified in the application's keychain based on two keys. The first is
 * an auth type string, returned by a class method, which can/should indicate the auth protocol being
 * used, such as OAuth2 or some string to represent proprietary auth mechanism.
 *
 * The second is more customizable, allowing each object to be identified as a service. If only one 
 * signing authority is needed for a particular site, then it could be that site's name, i.e. 'mygreatsite'.
 * If multiple authorities for that site are needed to be saved, a naming scheme would could be something
 * like 'mygreatsite-user1' and 'mygreatsite-user2'.
 *
 * Only one auth object can be stored in the keychain for each combination of AuthType and Service. Additionally
 * only one auth object for a particular service identifier can be used by the WebServiceManager at any given time.
 * The reason for having both keys is down do the oddities of the keychain services.
 */
@protocol WebServiceAuthProtocol <NSObject,NSCoding>
@required
/**
 * @brief signs the request if necessary
 * @param urlRequest the request to be signed
 * @return whether the auth token needs to be refreshed
 */
-(BOOL)signRequestIfNecesary:(NSMutableURLRequest*)urlRequest;

/**
 * @brief tells the WebServiceAuth object to update its access token. 
 *
 *  Though a web request is returned, this method is expected to start the request
 *  through the WebServiceManager.
 *  If there is no valid way to update the token this method should return nil and
 *  call the callback with an appropriate error.
 * @param callback the callback block it should call upon completion
 * @param performAsync whether the reauth call should happen asyncronously. This flag
 *  represents whether the WebServiceRequest that required the signing was started
 *  synchronously or asynchronously.
 * @return The WebServiceRequest that is performing the re-auth.
 */
-(WebServiceRequest*)updateAccessToken:(WebServiceCallbackBlock)callback async:(BOOL)performAsync;

/**
 * @brief This method is used to inform whether the auth object is ready to sign requests
 * @return whether the auth object has been authenticated
 */
-(BOOL)isAuthenticated;

/**
 * @brief generates a reauth error so that the WebServiceManager can kick it up to the application level
 * @return the reauth Error
 */
-(NSError*)reauthError;

/**
 * @brief all objects must have a service identifier. It is used for identifying the 
 *  object to the WebServiceManager. It is also used for saving to the keychain.
 *
 * If connection is to mygreatsite, this might be @"mygreatsite".
 * There will only ever be auth one auth object for a service in active use,
 * though others may be stored in the keychain.
 * If multiple accounts for the same service want to be saved/used,
 * they should be called something like @"mygreatsite-kermit47"
 *
 * @return string representing the service being used.
 */
-(NSString*)serviceIdentifier;

/**
 * @brief all objects must have an auth type identifier. 
 * It identifies the type of authorization being used.
 * This might be something like OAuth2.
 *
 * This is primarily used for keychain saving. The combination of 
 * authTypeIdentifier and serviceIdentifier uniquely identify the auth object in the keychain.
 *
 * @return string representing the auth type
 */
+(NSString*)authTypeIdentifier;

@end
