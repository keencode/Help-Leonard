//
//  WebServiceRequest.h
//
//  Copyright (c) 2013 Applico Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebServiceRequest;
/**
 * @brief Delegate object for a WebServiceRequest.
 */
@protocol WebServiceDelegate <NSObject>
@required
/**
 * @brief Called upon successful completion of the request 
 * @param request the request that completed
 * @param data the data resulting from the successful request
 */
-(void)requestSucceeded:(WebServiceRequest*)request withData:(id)data;

/**
 * @brief Called upon error condition with the request
 * @param request the request that had an error
 * @param error the error
 */
-(void)requestFailed:(WebServiceRequest*)request withError:(NSError*)error;
@optional
 /** 
	* @brief Called with Progress for the request
	* @param request the request on which progress is being reported
	* @param response the NSURLresponse
	* @param data the data returned so far
	*/
-(void)request:(WebServiceRequest*)request responded:(NSURLResponse*)response withData:(id)data;
@end

typedef void (^WebServiceCallbackBlock)(id data,NSURLResponse *response,NSError *error); /**< Defination of the callback block used for reporting progress, completion or error */


/**
 * @brief The base WebServiceRequest class. Used for submission to the WebServiceManager. Implements the callback logic upon success or error of the network operation.
 */
@interface WebServiceRequest : NSObject

#pragma mark methods that should be overloaded for a subclass
-(NSMutableURLRequest*)urlrequest; /**< Returns the URL needed by the WebServiceManager for starting the request. Must be mutable if OAuth2 signing is to be utilized */

#pragma mark methods that can be overloaded
/**
 *@brief Upon completion of a webservice request the WebServiceManager will call this method in the webservicerequest. 
 * The base class method will call the appropriate delegate method or callback block. This method can be overloaded to 
 * perform special handling that all of the web requests for the app may need, like JSON decoding or handling expired auth
 * tokens.
 *@param response The NSURLResponse for the request
 *@param responseData The data returned by the request, may be nil in the case of an error
 *@param error Any error generated in performing the request
 *@param isAsync whether the request was started asynchronously. Useful for restarting requests
 */
-(void)handleWebServiceResponse:(NSURLResponse*)response data:(NSData*)responseData error:(NSError*)error asyncFlag:(BOOL)isAsync;
/**
 *@brief Upon getting progress for a webservice request the WebServiceManager will call this method in the webservicerequest.
 * The base class method will call the appropriate delegate method or callback block. This method can be overloaded to
 * perform special handling.
 *@param response The NSURLResponse for the request
 *@param responseData The data returned by the request, may be nil in the case of an error
 *@param error Any error generated in performing the request
 */
-(void)handleWebServiceProgress:(NSURLResponse*)response data:(NSData*)responseData error:(NSError*)error;


#pragma mark base methods and properties
/**
	* @brief Inits with the specified delegate.
	* This init method is designed to be used by subclasses.
	* @param delegate the callback delegate
	* @return initialized object
	*/
-(id)initWithDelegate:(id<WebServiceDelegate>)delegate;

/**
	* @brief Inits with the specified completion block.
	* This init method is designed to be used by subclasses.
	* @param completionBlock the completion callback block
	* @return initialized object
	*/
-(id)initWithCompletion:(WebServiceCallbackBlock)completionBlock;

/**
 * @brief Inits with the specified progress and completion block.
 * This init method is designed to be used by subclasses.
 * @param progressBlock the progress callback block
 * @param completionBlock the completion callback block
 * @return initialized object
 */
-(id)initWithProgress:(WebServiceCallbackBlock)progressBlock completion:(WebServiceCallbackBlock)completionBlock;

/**
 * @brief Inits with the specified request and delegate.
 * This method is designed for standalone webservice requests.
 * @param request the url request to be executed. Must be mutable if auth signing is to be used
 * @param delegate the callback delegate
 * @return initialized object
 */
-(id)initWithURLRequest:(NSMutableURLRequest*)request delegate:(id<WebServiceDelegate>)delegate;

/**
 * @brief Inits with the specified request and completion block.
 * This method is designed for standalone webservice requests.
 * @param request the url request to be executed. Must be mutable if auth signing is to be used
 * @param completionBlock the completion callback block
 * @return initialized object
 */
-(id)initWithURLRequest:(NSMutableURLRequest*)request completion:(WebServiceCallbackBlock)completionBlock;
/**
 * @brief Inits with the specified request, progress and completion block.
 * This method is designed for standalone webservice requests.
 * @param request the url request to be executed. Must be mutable if auth signing is to be used
 * @param progressBlock the progress callback block
 * @param completionBlock the completion callback block
 * @return initialized object
 */
-(id)initWithURLRequest:(NSMutableURLRequest*)request progress:(WebServiceCallbackBlock)progressBlock completion:(WebServiceCallbackBlock)completionBlock;

@property (nonatomic,weak,readonly) id<WebServiceDelegate> delegate;/**< delegate object. readonly because we won't want to allow for changing or having both delegate and blocks. set via init */
@property (nonatomic,strong,readonly) WebServiceCallbackBlock completionCallback;/**< completion block. readonly because we won't want to allow for changing or having both delegate and blocks. set via init */
@property (nonatomic,strong,readonly) WebServiceCallbackBlock progressCallback;/**< progress block. readonly because we won't want to allow for changing or having both delegate and blocks. set via init */

@property (nonatomic,strong) NSNumber *requestIdentifier; /**< This property is used by the WebServiceManager, do not change or set or override */

@end
