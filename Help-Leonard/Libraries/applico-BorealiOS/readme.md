The BorealiOS Networking Framework is the set of classes that we use for doing URL requests in our iOS projects.
We found that the existing libraries had a few issues that this library resolves.

1. They do way more than we need or were more complicated in use than we liked.
2. They don't have built in support authentication of web requests.
3. Wanted to support both the delegate and callback block paradigms.
4. They didn't provide centralized management of the requests.
5. Needed custom timeout interval

99% of our projects are doing non-complicated web requests involving JSON or binary data, thus keeping it all simple is advantageous

The ANF (Applico Networking Framework) is built entirely on top of NSURLConnection and is ARC compliant. For use in a non-ARC project please mark all files as `-fobjc-arc`.

Features of the Applico Networking Framework
============================================

1. Small and easy to integrate. There are only 5 source code files at its core.
2. Authentication Protocol allows for development of custom authentication objects.
3. Centralized WebServiceManager gives two ways of starting web requests:	asynchronously and synchronously
4. Centralized WebServiceManager gives easy way to cancel a web request.
5. Subclass WebServiceRequest to get custom creation and response handling for all of your web requests.
6. Each WebServiceRequest supports callbacks via a delegate or a block.
7. Keychain integration for saving and restoring authorization objects.
8. Supports refreshing Auth Tokens and resumbitting a request after refreshing the Auth Token.
9. Supports multiple authentication services, allowing for signing for different sites for separate requests at the same time.
10. Supports setting exact timeout interval. Prior to iOS6 the NSURLConnections timeout interval has an undocumented minimum of 4 minutes for POST operations. Remove this limitation.
11. Thread Safe

Documentation
=============
Documentation for BorealiOS can be found at [the documentation page](http://applico.github.com/BorealiOS/documentation/ "BorealiOS Documenation").

The project page is found here: [BorealiOS Project Page](http://applico.github.com/BorealiOS/ "BorealiOS Project Page").

We also have a discussion group, applico_borealios@googlegroups.com.

Installation
============
Download the required files and add them to your xCode project. Make sure that the two .m files are added to the project's target. That's it.
The five required files are:

* WebServiceAuthProtocol.h
* WebServiceManager.h
* WebServiceManager.m
* WebServiceRequest.h
* WebServiceRequest.m

In your project you also need to link against the "Security.framework"


Examples
========

Downloading an Image
--------------------
```objc
		NSString *url = @"http://www.server.com/imagepath";

		WebServiceCallbackBlock progressBlock = ^(id data,NSURLResponse *response,NSError *error) {
			//inform user about progress
		};
		
		WebServiceCallbackBlock completionBlock = ^(id data,NSURLResponse *response,NSError *error) {
			if (error) {
				//handle error
			} else {
				//display image
			}
		};
		
		WebServiceRequest *req = [[WebServiceRequest alloc] initWithURLRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]]
																																	progress:progressBlock
																																completion:completionBlock];
		[[WebServiceManager sharedManager] startAsync:req];
```

Performing an Authenticated Request
-----------------------------------
```objc
		NSString *url = @"http://www.server.com/imagepath";
		NSString *serviceIdentifier = @"myAuthService";

		WebServiceCallbackBlock progressBlock = ^(id data,NSURLResponse *response,NSError *error) {
			//inform user about progress
		};
		
		WebServiceCallbackBlock completionBlock = ^(id data,NSURLResponse *response,NSError *error) {
			if (error) {
				//handle error
			} else {
				//display image
			}
		};
		
		WebServiceRequest *req = [[WebServiceRequest alloc] initWithURLRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]]
																																	progress:progressBlock
																																completion:completionBlock];
		[[WebServiceManager sharedManager] startAsync:req authorizeForService:serviceIdentifier];
```

License
=======
This software is released under the MIT License.
The MIT License (MIT)
Copyright (c) 2013 Applico Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
