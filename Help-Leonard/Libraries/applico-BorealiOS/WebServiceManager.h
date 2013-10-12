//
//  WebServiceManager.h
//
//  Copyright (c) 2013 Applico Inc. All rights reserved.
//
//

#import "WebServiceRequest.h"
#import "WebServiceAuthProtocol.h"

#define NO_AUTH_OBJECT_FOR_SERVICE_DICT(__SERVICE__) [NSDictionary dictionaryWithObject:__SERVICE__ forKey:@"SuppliedService"]
#define NO_AUTH_ERROR_CODE 10011101

#define MIME_TYPE_JSON @"application/json" /**< Text for JSON content type */
#define MIME_TYPE_HTML @"text/html" /**< Text for html content type */


/**
 * @brief Class for managing web service requests
 * This class has a sharedManager singleton object. Trying to allocate your own should 
 * get you the shared object.
 *
 * WebServiceRequests are submitted to this class via one of the start methods. 
 *
 * As the requests complete the class will call success/failure methods of the request
 *  so that it can handle the responses and then notify the rest of the application.
 */
@interface WebServiceManager : NSObject <NSURLConnectionDataDelegate,NSURLConnectionDelegate>

/**
 *@brief Returns the Webservice Manager's shared instance.
 *There is a single shared instance of the webservice manager. 
 *All web service requests are made through it.
 *@return The shared instance
 */
+ (WebServiceManager*)sharedManager;

@property (nonatomic,assign) NSUInteger maxAllowedConnections; /**< Maximum number of simultaneous connections allowed.*/
@property (nonatomic,assign) NSTimeInterval timeoutInterval; /**< Time out interval. Allows for a custom time-out on webrequests.*/

/**
 *@brief Starts a webservice request syncronously
 *@param request the webservice request to be started.
 */
-(void)startSync:(WebServiceRequest*)request;

/**
 *@brief Starts a webservice request asyncronously
 *@param request the webservice request to be started.
 */
-(void)startAsync:(WebServiceRequest*)request;

/**
 *@brief Starts a webservice request syncronously. If possible it will authorize the request with the current OAuth2 Token
 *Will refresh the token if necessary
 *@param request the webservice request to be started.
 *@param service the name of the service which should sign the request
 */
-(void)startSync:(WebServiceRequest*)request authorizeForService:(NSString*)service;

/**
 *@brief Starts a webservice request asyncronously. If possible it will authorize the request with the current OAuth2 Token
 *Will refresh the token if necessary
 *@param request the webservice request to be started.
 *@param service the name of the service which should sign the request
 */
-(void)startAsync:(WebServiceRequest*)request authorizeForService:(NSString*)service;

/**
 *@brief cancels a web request
 *@param request the request to be cancelled
 *@return Whether the cancel was successful
 */
-(BOOL)cancel:(WebServiceRequest*)request;

/**
 *@brief cancels all active web requests
 */
-(void)cancelAllRequests;

/**
 *@brief Provides a quick method for downloading data from a url. Does callbacks with a delegate
 *Starts the request asyncronously
 *@param url the url for which the download is to be performed
 *@param delegate the webservice delegate for callback
 *@return the request that has already been started.
 */
-(WebServiceRequest*)downloadDataForUrl:(NSURL*)url delegate:(id<WebServiceDelegate>) delegate;

/**
 *@brief Provides a quick method for downloading data from a url. Does callbacks with blocks
 *Starts the request asyncronously
 *@param url the url for which the download is to be performed
 *@param progressBlock the progress callback block
 *@param completionBlock the completion callback block
 *@return the request that has already been started.
 */
-(WebServiceRequest*)downloadDataForUrl:(NSURL*)url progress:(WebServiceCallbackBlock)progressBlock completion:(WebServiceCallbackBlock)completionBlock;


#pragma mark - Authorization Service Methods

/**
 * @brief returns an actively managed auth object for the specified service.
 * Does not restore an item from the keychain
 * @param service the service for which the token is named
 * @return the service object, or nil if there is no active object for that service.
 */
-(id<WebServiceAuthProtocol>)tokenForService:(NSString*)service;

/**
 * @brief returns whether there is an authenticated object for the service.
 * @return YES if there is a authorized signing entity, NO if not or if there is no entity
 */
-(BOOL)isAuthenticatedForService:(NSString*)service;

/**
 * @brief Returns an array of all curent OAuth2Token objects 
 * @return current auth services
 */
-(NSArray*)currentAuthServices;

/**
 * @brief Clears out current token info. Specifying yes will also clear the keychain
 * @param includeKeychain whether to also clean out keychain information for the tokens currently in memory.
 */
-(void)clearAuthInformation:(BOOL)includeKeychain;

/**
 * @brief sets the auth object for a service
 *
 * After setting the object can be used for authorizing web requests submitted for the service
 * It is assumed that the object will have done its own authorization prior to it being used
 *		by the WebServiceManager. The manager only knows how to refresh a token.
 *
 * @param obj the auth object for the specified service
 * @param service the name for the auth service
 */
-(void)setAuthObject:(id<WebServiceAuthProtocol>)obj forService:(NSString*)service;

/**
 *@brief restores token information for the given service
 *@param service the service for which the token should be restored
 *@param authClass the class object for the auth service. Call [Auth Class] to obtain this.
 *@return NO signifies that either the restore failed or that there was no token information to restore. YES indicates that the restore succeeded.
 */
-(BOOL)restoreAuthTokenForService:(NSString*)service authClass:(Class<WebServiceAuthProtocol>)authClass;

/**
 *@brief tells the webservice manager to save this auth service to the keychain
 *@param tokenInfo the auth object to be saved
 */
-(BOOL)keychainSave:(id<WebServiceAuthProtocol>)tokenInfo;

/**
 *@brief removes the service from the keychain
 *@param service the service to be removed from the keychain
 *@param authClass the class object for the auth service. Call [Auth Class] to obtain this.
 */
-(void)keychainDeleteForService:(NSString*)service authClass:(Class<WebServiceAuthProtocol>)authClass;

@end




