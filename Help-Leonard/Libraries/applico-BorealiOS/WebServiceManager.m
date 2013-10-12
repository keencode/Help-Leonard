//
//  WebServiceManager.m
//
//  Copyright (c) 2013 Applico Inc. All rights reserved.
//
//

#import "WebServiceManager.h"
#import "WebServiceRequest.h"
#include <libkern/OSAtomic.h> //needed for keychain saving
#import <Security/Security.h> //needed for keychain saving

#define MAX_CONNECTIONS 10 /**< This is the hard cap max, to keep someone from really boinking the iDevice. Change as needed */
#define DEFAULT_TIMEOUT_INTERVAL 300.0f


/**
 * @brief Custom NSURLConnection class.
 *
 * To make the magic sauce work, we provide a custom implementation of NSURLConnection.
 * This gives us some extra capabilities. For each active connection we can keep track of the following:
 * - The WebServiceRequest that is responsible for the connection and has the call back handlers
 * - Data returned by the connection
 * - Custom Timeout Timer. This is important because prior to iOS6, the minimum timeout time
 *		for POST operations is 4 minutes and the default value is 10 minutes.
 * - Flags for whether the connection was timed out by our timer, or cancelled manually by the user
 * - The NSURLResponse for the request, for passing back to the callback object.
 *
 * By using starting instances of AURLConnection, in the NSURLConnectionDelegate and
 *		NSURLConnectionDataDelegate callbacks, we really get AURLConnection objects, 
 *    not NSURLConnection objects. This is the magic of the WebServiceManager.
 *
 * This class is located in the .m file because there is no need for the general user 
 *		of this library to worry or care about it. They should never see these objects, nor 
 *    should they need to modify one.
 ********************************************/
#pragma mark - AURLConnection Interface
@interface AURLConnection : NSURLConnection
@property (nonatomic,strong) WebServiceRequest *request; /**< The request that generated the URLRequest for this connection */
@property (nonatomic,strong) NSMutableData *data; /**< Returned data */
@property (nonatomic,strong) NSTimer *timer; /**< Custom timer for custom timeouts */
@property (nonatomic,assign) BOOL hasTimedOut; /**< Used by the WebServiceManager for determining if the custon timeout timer occured */
@property (nonatomic,assign) BOOL wasCanceledManually; /**< Used by the WebServiceManager for flagging when a request was manually cancelled. This is important because it could be cancelled by the user, but still have some data coming in the response before the cancel operation actually occurs */
@property (nonatomic,strong) NSURLResponse *response; /**< The response as returned by the delegate methods */

-(void)clearTimer; /**< Clears the timeout timer for the particular request. */
-(void)resetTimer; /**< Resets the timeout timer for the particular request to the timeout interval and starts it.*/

@end

#pragma mark - WebServiceManager Interface Extension
typedef void (^WebOperationBlock)();

/**
 * @brief Private extension to the WebServiceManager class. These variables do not need to be part of the public interface.
 */
@interface WebServiceManager()
@property (atomic,assign) int32_t connectionCounter; /**< Used to give each WebServiceRequest submitted to the manager a unique identifier. It is unlikely that an app will hit 2^31 requests in any given session, so signedness shouldn't matter */
@property (nonatomic,strong) NSMutableDictionary *connections; /**< Used to manage active connections */
@property (nonatomic,strong) NSMutableArray *pendingRequests; /**< Used to manage pending requests */
@property (nonatomic,strong) NSMutableDictionary *pendingRequestsAuthInfo; /**< Keeps track of auth information for pending requests */
@property (nonatomic,strong) NSMutableDictionary *authTokenInfo; /**< Contains a mapping of service to auth information */

/** 
 * @brief Gets an object adhering to the WebServiceAuthProtocol from the keychain
 */
-(id<WebServiceAuthProtocol>)keychainEntryForService:(NSString*)service authClass:(Class<WebServiceAuthProtocol>)authClass;

/**
 * @brief Generates a keychain dictionary for a service and auth class
 */
-(NSMutableDictionary*)keychainDictionaryForService:(NSString*)serviceName authClass:(Class<WebServiceAuthProtocol>)authClass;

/**
 * @brief Private method for starting a request
 */
-(void)startRequest:(WebServiceRequest*)wRequest urlRequest:(NSMutableURLRequest*)urlRequest async:(BOOL)asyncFlag service:(NSString*)service opBlock:(WebOperationBlock)operationBloc;
/**
 * @brief Handles removing an object from the connection caches
 * Will also will start the next pending request, if there are any.
 */
-(void)cleanConnection:(AURLConnection*)conn;
@end


#pragma mark - AURLConnection Implementation
@implementation AURLConnection

@synthesize request = _request;
@synthesize data = _data;
@synthesize timer = _timer;
@synthesize hasTimedOut = _hasTimedOut;
@synthesize wasCanceledManually = _wasCanceledManually;
@synthesize response = _response;


-(id)initWithWebRequest:(WebServiceRequest*)request urlRequest:(NSURLRequest*)urlRequest delegate:(id)delegate
{
	self = [super initWithRequest:urlRequest delegate:delegate startImmediately:NO];
	if (self) {
		_request = request;
		_hasTimedOut = NO;
		_wasCanceledManually = NO;
	}
	return self;
}

-(void)clearTimer {
	if (_timer) {
		[_timer invalidate];
		_timer = nil;
	}
}

-(void)timedOut {
	_hasTimedOut = YES;
	[self cancel];
		//in this case we want to override the error message with our own
		//this is because the self timer generated the cancel that got us in here
	NSError *newError = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:NSURLErrorTimedOut userInfo:nil];
	//we force the failure of the connection on the timeout.
	//this is why we need to have the custom self.hasTimedOut flag. It lets the Manager know why its failing.
	[[WebServiceManager sharedManager] connection:self didFailWithError:newError];
}

//Override the cancel method so that we can invalidate the timer.
-(void)cancel {
	if (_timer) {
		[_timer invalidate];
		_timer = nil;
	}
	[super cancel];
}

//override the start method so we can start the timeout timer
-(void)start {
	[self resetTimer];
	[super start];
}

-(void)resetTimer {
	if (_timer) {
		[_timer invalidate];
		_timer = nil;
	}
	_timer = [NSTimer scheduledTimerWithTimeInterval:[WebServiceManager sharedManager].timeoutInterval target:self selector:@selector(timedOut) userInfo:nil repeats:NO];
}

@end

#pragma mark - WebServiceManager Implementation

@implementation WebServiceManager
@synthesize connectionCounter = _connectionCounter;
@synthesize connections = _connections;
@synthesize maxAllowedConnections = _maxAllowedConnections;
@synthesize pendingRequests = _pendingRequests;
@synthesize timeoutInterval = _timeoutInterval;

/**
 * @brief We override the default setter for this property to ensure that the app doesn't set this too high
 */
-(void)setMaxAllowedConnections:(NSUInteger)maxAllowedConnections {
	_maxAllowedConnections = maxAllowedConnections < MAX_CONNECTIONS ? maxAllowedConnections : MAX_CONNECTIONS;
}

/*
 * Just calls the async with service and makes the service nil.
 */
-(void)startAsync:(WebServiceRequest*)request
{
	[self startAsync:request authorizeForService:nil];
}

/*
 * Just calls the sync with service and makes the service nil.
 */
-(void)startSync:(WebServiceRequest*)request
{
	[self startSync:request authorizeForService:nil];
}

/*
 * Here's where it gets fun.
 * The code for this method is performed in an @synchronized block so that 
 * handling of requests on/off the pending request queue is all synchronized.
 */
-(void)startAsync:(WebServiceRequest*)request authorizeForService:(NSString*)service
{
	@synchronized(self) {
		//check to see if this request has already been submitted. If it has, we do nothing
		if (request.requestIdentifier != nil) {
			//this guy has already been submitted
			//check to see if he is active or pending
			//if he is, don't do anything, otherwise we can redo the request
			AURLConnection *aconnection = [self.connections objectForKey:request.requestIdentifier];
			if (aconnection || [self.pendingRequests containsObject:request]) {
				//he's in processing, return
				return;
			}
		}
		
		//Assign an identifier to this method
		request.requestIdentifier = [NSNumber numberWithInteger:OSAtomicIncrement32(&_connectionCounter)];
		
		//Now check to see if he's allowed to start
		if (self.connections.count == self.maxAllowedConnections) {
			//Not allowed, add to queue
			[self.pendingRequests addObject:request];
			if (service) {
				[self.pendingRequestsAuthInfo setObject:service forKey:request.requestIdentifier];
			}
		} else {
			//Let's get this puppy rolling
			//We generate the URLRequest and setup the operation block that will actually start it.
			//Doing it in a block like this allows us to perform this code from a couple of different spots
			//Yay for OOP
			NSMutableURLRequest *urlRequest = [request urlrequest];
			WebOperationBlock operationBloc = ^{
				NSURLConnection *connection;
				connection = [[AURLConnection alloc] initWithWebRequest:request urlRequest:urlRequest delegate:self];
				
				[self.connections setObject:connection forKey:request.requestIdentifier];
				[connection start];
			};
			
			//then more OOP to use a shared method for actually starting the request
			[self startRequest:request urlRequest:urlRequest async:YES service:service opBlock:operationBloc];
		}
	}
}

-(void)startSync:(WebServiceRequest*)request authorizeForService:(NSString*)service
{
	//Let's get this puppy rolling
	//We generate the URLRequest and setup the operation block that will actually start it.
	//Doing it in a block like this allows us to perform this code from a couple of different spots
	NSMutableURLRequest *urlRequest = [request urlrequest];
	WebOperationBlock operationBloc = ^{
		
		NSError *error = nil;
		NSURLResponse *response = nil;
		NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
		[request handleWebServiceResponse:response data:responseData error:error asyncFlag:NO];
	};

	//then more OOP to use a shared method for actually starting the request
	[self startRequest:request urlRequest:urlRequest async:NO service:service opBlock:operationBloc];
}

-(void)startRequest:(WebServiceRequest*)wRequest urlRequest:(NSMutableURLRequest*)urlRequest async:(BOOL)asyncFlag service:(NSString*)service opBlock:(WebOperationBlock)operationBloc {
	if (service) {
		id<WebServiceAuthProtocol> tokenInfo = [self tokenForService:service];
		//If an auth service is specified, attempt to do the signing
		//and if necessary reauth the service
		if (tokenInfo == nil) {
			//there is no auth object for this service, throw an error
			[wRequest handleWebServiceResponse:nil data:nil error:[NSError errorWithDomain:@"com.webservicemanager.error" code:NO_AUTH_ERROR_CODE userInfo:NO_AUTH_OBJECT_FOR_SERVICE_DICT(service)] asyncFlag:asyncFlag];
		} else if ([tokenInfo signRequestIfNecesary:urlRequest]) {
			//couldn't sign because the token was expired, refresh the token
			[tokenInfo updateAccessToken:^(id data,NSURLResponse *response,NSError* error) {
				if (error == nil) {
					if ([tokenInfo signRequestIfNecesary:urlRequest]) {
						//still having a problem signing, throw error
						[wRequest handleWebServiceResponse:nil data:nil error:[tokenInfo reauthError] asyncFlag:YES];
					} else {
						operationBloc();
					}
				} else {
					[wRequest handleWebServiceResponse:nil data:nil error:error asyncFlag:YES];
				}
			} async:asyncFlag];
		} else {
			//the request was signed, start the request
			operationBloc();
		}
	} else {
		operationBloc();
	}
}

/*
 * Cancelling needs to occur in an @syncronized to prevent an issue where in a request could get progress
 * or complete while the cancel code is occuring. We don't want to try to remove the objects
 * from the management containers in multiple places
 */
-(BOOL)cancel:(WebServiceRequest*)request {
	BOOL ret = NO;
	@synchronized(self) {
		AURLConnection *connection = [self.connections objectForKey:request.requestIdentifier];
		if ([self.pendingRequests containsObject:request]){
			[self.pendingRequests removeObject:request];
			ret = YES;
		}	else if (connection) {
			connection.wasCanceledManually = YES;
			[connection cancel];
			//call the general cleanup method to get the next object off the queue
			[self cleanConnection:connection];
			ret = YES;
		}
	}
	return ret;
}

/*
 * Cancelling needs to occur in an @syncronized to prevent an issue where in a request could get progress
 * or complete while the cancel code is occuring. We don't want to try to remove the objects
 * from the management containers in multiple places
 */
-(void)cancelAllRequests {
	@synchronized(self) {
		//first remove all queued requests
		[self.pendingRequests removeAllObjects];
		
		//then kill all the connections
		NSDictionary *dict = [NSDictionary dictionaryWithDictionary:self.connections];
		[self.connections removeAllObjects];
		[dict enumerateKeysAndObjectsUsingBlock:^(NSNumber *key,AURLConnection *conn,BOOL *stop) {
			conn.wasCanceledManually = YES;
			[conn cancel];
		}];
	}
}

#pragma mark - NSURLConnection Delegate Methods

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
	AURLConnection *conn = (AURLConnection*)connection;
  conn.response = response;
	conn.data = [[NSMutableData alloc] init];
	[conn resetTimer];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
	AURLConnection *conn = (AURLConnection*)connection;
	[conn.data appendData:data];
	[conn resetTimer];
	if (conn.wasCanceledManually == NO) {
		[conn.request handleWebServiceProgress:conn.response data:conn.data error:nil];
	}
}

/*
 This method should only be called from inside an @synchronized block
 */
-(void)cleanConnection:(AURLConnection*)conn {
		[self.connections removeObjectForKey:conn.request.requestIdentifier];
		if (self.pendingRequests.count > 0) {
			WebServiceRequest *req = (WebServiceRequest*)[self.pendingRequests objectAtIndex:0];
			[self.pendingRequests removeObject:req];
			NSString *service = [self.pendingRequestsAuthInfo objectForKey:req.requestIdentifier];
			if (service) {
				[self.pendingRequestsAuthInfo removeObjectForKey:req.requestIdentifier];
			}
			[self startAsync:req authorizeForService:service];
		}
}

-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
	AURLConnection *conn = (AURLConnection*)connection;
	if (conn.wasCanceledManually == NO) {
		[conn clearTimer];
		//only do the error handling if the error was not caused by a manual cancelation
		@synchronized(self) {
			//call the general cleanup method to get the next object off the queue
			[self cleanConnection:conn];
		}
		//don't want callbacks in the @synchronized code
		[conn.request handleWebServiceResponse:nil data:nil	error:error asyncFlag:YES];
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
	AURLConnection *conn = (AURLConnection*)connection;
	[conn clearTimer];
	@synchronized(self) {
		//call the general cleanup method to get the next object off the queue
		[self cleanConnection:conn];
	}
	//don't want callbacks in the @synchronized code
	if (conn.wasCanceledManually == NO) {
		[conn.request handleWebServiceResponse:conn.response data:conn.data error:nil asyncFlag:YES];
	}
}

//enable connection filtering
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
  BOOL ret = [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
  return ret;
}

//handle poor https credentials
//for now assume that if the host is part of the TrustedHosts array that it is good
//the Trusted Hosts array is part of the apps info.plist
//if your https connections aren't working, add an array to info.plist called TrustedHosts and
//put your domain into it
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSArray *trustedHosts = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"TrustedHosts"];
	if (trustedHosts && trustedHosts.count > 0) {
		if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
			if ([trustedHosts containsObject:challenge.protectionSpace.host]) {
				[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
			}
		}
		[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
	}
}

//nothing special here
-(WebServiceRequest*)downloadDataForUrl:(NSURL*)url delegate:(id<WebServiceDelegate>) delegate {
  WebServiceRequest *request = [[WebServiceRequest alloc] initWithURLRequest:[NSURLRequest requestWithURL:url] delegate:delegate];
  [self startAsync:request];
  return request;
}

//nothing special here
-(WebServiceRequest*)downloadDataForUrl:(NSURL*)url progress:(WebServiceCallbackBlock)progressBlock completion:(WebServiceCallbackBlock)completionBlock {
  WebServiceRequest *request = [[WebServiceRequest alloc] initWithURLRequest:[NSURLRequest requestWithURL:url] progress:progressBlock completion:completionBlock];
  [self startAsync:request];
  return request;
}

#pragma mark - Auth Methods

-(id<WebServiceAuthProtocol>)tokenForService:(NSString *)service {
	return [self.authTokenInfo objectForKey:service];
}

-(BOOL)isAuthenticatedForService:(NSString *)service {
	id<WebServiceAuthProtocol> tokenInfo = [self tokenForService:service];
	return (tokenInfo != nil && [tokenInfo isAuthenticated]);
}

-(NSArray*)currentAuthServices {
	return [self.authTokenInfo allValues];
}

-(BOOL)restoreAuthTokenForService:(NSString *)service authClass:(Class<WebServiceAuthProtocol>)authClass {
	id<WebServiceAuthProtocol> tokenInfo = [self keychainEntryForService:service authClass:authClass];
	if (tokenInfo) {
		[self.authTokenInfo setObject:tokenInfo forKey:service];
	}
	return tokenInfo != nil;
}

-(void)clearAuthInformation:(BOOL)includeKeychain {
	if (includeKeychain) {
		[[self.authTokenInfo allValues] enumerateObjectsUsingBlock:^(id<WebServiceAuthProtocol> obj,NSUInteger idx,BOOL *stop) {
			[self keychainDeleteForService:obj.serviceIdentifier authClass:[obj class]];
		}];
	}
	[self.authTokenInfo removeAllObjects];
}


-(void)setAuthObject:(id<WebServiceAuthProtocol>)obj forService:(NSString *)service {
	[self.authTokenInfo setObject:obj forKey:service];
}

#pragma mark - Keychain Token Saving

-(id<WebServiceAuthProtocol>)keychainEntryForService:(NSString*)service authClass:(Class<WebServiceAuthProtocol>)authClass
{
	//start by getting the dictionary for this service
	NSMutableDictionary *searchDictionary = [self keychainDictionaryForService:service authClass:authClass];
	
  //add search attributes
  [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	
  //add search return types
  [searchDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	
	//get the item
  CFTypeRef result = NULL;
	id<WebServiceAuthProtocol> ret = nil;
  OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary,&result);
	if (status == noErr) {
		NSData *resultData = nil;
		resultData = (__bridge NSData*)result;
		ret = [NSKeyedUnarchiver unarchiveObjectWithData:resultData];
	}
  return ret;
}

-(BOOL)keychainSave:(id<WebServiceAuthProtocol>)tokenInfo {
	//turn the obejct into data and setup for saving
	NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:tokenInfo];
	NSMutableDictionary *dict = [self keychainDictionaryForService:tokenInfo.serviceIdentifier authClass:[tokenInfo class]];
	//see if it already exists
	id<WebServiceAuthProtocol> existingToken = [self keychainEntryForService:tokenInfo.serviceIdentifier authClass:[tokenInfo class]];
	OSStatus status;
	if (existingToken) {
		//if so, update
		NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
		[updateDictionary setObject:saveData forKey:(__bridge id)kSecValueData];
		
		status = SecItemUpdate((__bridge CFDictionaryRef)dict,
																		(__bridge CFDictionaryRef)updateDictionary);
	} else {
		//otherwise, save
		[dict setObject:saveData forKey:(__bridge id)kSecValueData];
		status = SecItemAdd((__bridge CFDictionaryRef)dict, NULL);
	}
	
  if (status == errSecSuccess) {
    return YES;
  }
  return NO;
}

-(void)keychainDeleteForService:(NSString*)service authClass:(Class<WebServiceAuthProtocol>)authClass {
  NSMutableDictionary *searchDictionary = [self keychainDictionaryForService:service authClass:authClass];
  SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
}


/**
 * @brief creates a generic dictionary for doing keychain queries
 * All keychain access goes through a dictionary. Said dictionary always needs the following
 *  -kSecClass, what type of keychain entry is this. We're using generic password
 *  -kSecAttrGeneric this identifies our entry in this apps keychain
 *  -kSecAttrAccount does the same as above
 *  -kSecAttrService the service name we're storing for, ie com.apple.testApp
 */
-(NSMutableDictionary*)keychainDictionaryForService:(NSString*)serviceName authClass:(Class<WebServiceAuthProtocol>)authClass {
	// This keychain item is a generic password.
	NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
	
  [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	
  NSData *encodedIdentifier = [[authClass authTypeIdentifier] dataUsingEncoding:NSUTF8StringEncoding];
  [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
  [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
  [searchDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];
	
  return searchDictionary;
}
#pragma mark - override lifecycle methods


static WebServiceManager *sharedInstance = nil;

// We don't want to allocate a new instance, so return the current one.
// if this method ever gets deprecated, we'll need to override alloc
// currently alloc calls allocWithZone
+ (id)allocWithZone:(NSZone*)zone {
	return [self sharedManager];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
	return self;
}


// Get the shared instance and create it if necessary.
+ (WebServiceManager *)sharedManager {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		//need to call super allocWithZone because we're overriding our method...
		sharedInstance = [[super allocWithZone:NULL] init];
	});
	return sharedInstance;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
	self = [super init];
	
	if (self) {
		// Work your initialising magic here as you normally would
		_connectionCounter = 0;
		_connections = [NSMutableDictionary dictionaryWithCapacity:5];
		_pendingRequests = [NSMutableArray arrayWithCapacity:5];
		_pendingRequestsAuthInfo = [NSMutableDictionary dictionaryWithCapacity:5];
		_maxAllowedConnections = MAX_CONNECTIONS;
		_timeoutInterval = DEFAULT_TIMEOUT_INTERVAL;
		_authTokenInfo = [NSMutableDictionary dictionaryWithCapacity:1];
	}
	
	return self;
}


@end
