//
//  WebServiceRequest.m
//
//  Copyright (c) 2013 Applico Inc. All rights reserved.
//

#import "WebServiceRequest.h"

/**
 * @brief Private extension to the WebServiceRequest class. These variables do not need to be part of the public interface.
 */
@interface WebServiceRequest()
@property (nonatomic,strong) NSMutableURLRequest *request; /**< Request object storage, used in the base class for when a request is specified in the initializer */
@property (nonatomic,weak) id<WebServiceDelegate> delegate; /**< Actual declaration for the delegate property */
@property (nonatomic,strong) WebServiceCallbackBlock completionCallback; /**< Actual declaration for the completionCallback property */
@property (nonatomic,strong) WebServiceCallbackBlock progressCallback; /**< Actual declaration for the progressCallback property */

@end

@implementation WebServiceRequest

@synthesize requestIdentifier = _requestIdentifier;
@synthesize delegate = _delegate;
@synthesize completionCallback = _completionCallback;
@synthesize progressCallback = _progressCallback;
@synthesize request = _request;

#pragma mark - init methods

/*
 * This is the base initializer, it calls [super init]
 */
-(id)init {
	self = [super init];
	if (self) {
		//the default value is nil
		//just want to make it clear
		//it doesn't get assigned until it is submitted to the WebServiceManager
		_requestIdentifier = nil;
	}
	return self;
}

/*
 * Calls [self init]
 */
-(id)initWithDelegate:(id<WebServiceDelegate>)delegate {
	self = [self init];
	if (self) {
		_delegate = delegate;
		_completionCallback = nil;
    _progressCallback = nil;
	}
	return self;
}


/*
 * Calls [self init]
 */
-(id)initWithProgress:(WebServiceCallbackBlock)progressBlock completion:(WebServiceCallbackBlock)completionBlock {
	self = [self init];
	if (self) {
    _progressCallback = progressBlock;
		_completionCallback = completionBlock;
		_delegate = nil;
	}
	return self;
}

/*
 * Calls initWithProgress:completion:
 */
-(id)initWithCompletion:(WebServiceCallbackBlock)completionBlock {
  return [self initWithProgress:nil completion:completionBlock];
}

/*
 * Calls initWithDelegate
 */
-(id)initWithURLRequest:(NSMutableURLRequest*)request delegate:(id<WebServiceDelegate>)delegate {
	self = [self initWithDelegate:delegate];
	if (self) {
		_request = request;
	}
	return self;
}

/*
 * Calls initWithProgress:completion:
 */
-(id)initWithURLRequest:(NSMutableURLRequest*)request progress:(WebServiceCallbackBlock)progressBlock completion:(WebServiceCallbackBlock)completionBlock {
	self = [self initWithProgress:progressBlock completion:completionBlock];
	if (self) {
		_request = request;
	}
	return self;
}

/*
 * Calls initWithURLRequest:progress:completion:
 */
-(id)initWithURLRequest:(NSMutableURLRequest*)request completion:(WebServiceCallbackBlock)completionBlock {
  return [self initWithURLRequest:request progress:nil completion:completionBlock];
}



-(NSMutableURLRequest*)urlrequest {
	return self.request;
}

-(void)handleWebServiceResponse:(NSURLResponse*)response data:(NSData*)responseData error:(NSError*)error asyncFlag:(BOOL)isAsync
{
	if (_completionCallback) {
		_completionCallback(responseData,response,error);
	}

	if (responseData) {
		if (self.delegate) {
			[self.delegate requestSucceeded:self withData:responseData];
		}
	} else if (error) {
		if (self.delegate) {
			[self.delegate requestFailed:self withError:error];
		}
	}
}

-(void)handleWebServiceProgress:(NSURLResponse*)response data:(NSData*)responseData error:(NSError*)error {
  if (_progressCallback) {
		_progressCallback(responseData,response,error);
	}
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(request:responded:withData:)]) {
    [self.delegate request:self responded:response withData:responseData];
  }
}



@end
