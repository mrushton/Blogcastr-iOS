//
//  RequestServer.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/10/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "RequestServer.h"
#import "User.h"


static RequestServer *sharedRequestServer = nil;

@implementation RequestServer

@synthesize session;
@synthesize managedObjectContext;

+ (RequestServer *)sharedRequestServer {
	if (sharedRequestServer == nil)
		sharedRequestServer = [[super allocWithZone:NULL] init];

	return sharedRequestServer;
}

+ (id)allocWithZone:(NSZone*)zone {
	return [[self sharedRequestServer] retain];
}

- (id)copyWithZone:(NSZone*)zone {
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;
}

- (void)release {
	return;  
}

- (id)autorelease {
	return self;  
}

#pragma mark -
#pragma mark Core Data

- (BOOL)save {
	NSError *error;
	
	if (![managedObjectContext save:&error]) {
	    NSLog(@"Error saving managed object context: %@", [error localizedDescription]);
		return FALSE;
	}
	
	return TRUE;
}

#pragma mark -
#pragma mark Requests

- (BlogcastsRequest *)requestBlogcastsWithUser:(User *)user maxId:(NSInteger)maxId count:(NSInteger)count delegate:(id)delegate {
	BlogcastsRequest *blogcastsRequest;
	NSString *url;
	NSURL *theUrl;
	NSURLRequest *urlRequest;
	NSURLConnection *urlConnection;
	
#ifdef DEVEL
	url = [[NSString stringWithFormat:@"http://sandbox.blogcastr.com/users/%@/blogcasts.xml?count=%d", user.username, count] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else //DEVEL
	url = [[NSString stringWithFormat:@"http://blogcastr.com/users/%@/blogcasts.xml?count=%d", user.username, count] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#endif //DEVEL
	//MVR - add a max id if set
	if (maxId)
		url = [url stringByAppendingString:[[NSString stringWithFormat:@"&max_id=%d", maxId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	theUrl = [NSURL URLWithString:url];
	urlRequest = [NSURLRequest requestWithURL:theUrl];
	urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
	blogcastsRequest = (BlogcastsRequest *)[[BlogcastsRequest alloc] initWithDelegate:delegate];
	NSLog(@"MVR - request data 0x%x",blogcastsRequest);
	blogcastsRequest.managedObjectContext = managedObjectContext;
	//MVR - add request to dictionary
	CFDictionaryAddValue(self.urlConnectionDictionaryRef, urlConnection, blogcastsRequest);
	[urlConnection release];
	
	return blogcastsRequest;
}

#pragma mark -
#pragma mark Connection dictionary

- (CFMutableDictionaryRef)urlConnectionDictionaryRef {
	//MVR - lazily load
	if (!_urlConnectionDictionaryRef)
		_urlConnectionDictionaryRef = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);	
	return _urlConnectionDictionaryRef;
}

#pragma mark -
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)urlConnection didReceiveResponse:(NSURLResponse *)urlResponse {
    int statusCode;
	Request *request;
	
	request = (Request *)CFDictionaryGetValue(self.urlConnectionDictionaryRef, urlConnection);
	statusCode = [(NSHTTPURLResponse *)urlResponse statusCode];
	//MVR - check for errors
	if (statusCode != 200) {
		NSLog(@"Error URL connection received status code %i", statusCode);
		[urlConnection cancel];
		[request.delegate request:request didFailWithError:RequestServerStatusCodeError];
		//MVR - remove data from dictionary
		CFDictionaryRemoveValue(self.urlConnectionDictionaryRef, urlConnection);
		[request release];
		return;
	}
	//MVR - may receive multiple messages
    [request.mutableData setLength:0];
}

- (void)connection:(NSURLConnection *)urlConnection didReceiveData:(NSData *)data {
	Request *request;
	
	//MVR - get request
	request = (Request *)CFDictionaryGetValue(self.urlConnectionDictionaryRef, urlConnection);
	//MVR - append data
    [request.mutableData appendData:data];
}

- (void)connection:(NSURLConnection *)urlConnection didFailWithError:(NSError *)error {
	Request *request;
	
	NSLog(@"Error URL connection failed: %@", [error localizedDescription]);
	//MVR - get request
	request = (Request *)CFDictionaryGetValue(self.urlConnectionDictionaryRef, urlConnection);
	[request.delegate request:request didFailWithError:RequestServerConnectionError];
    //MVR - remove request from dictionary
	CFDictionaryRemoveValue(self.urlConnectionDictionaryRef, urlConnection);
	[request release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)urlConnection {
	Request *request;
	
	//MVR - get request
	request = (Request *)CFDictionaryGetValue(self.urlConnectionDictionaryRef, urlConnection);
    //MVR - parse response
	if (![request parse]) {
		NSLog(@"MVR - parse error");
		[request.delegate request:request didFailWithError:RequestServerParseResponseError];
	} else {
		NSLog(@"MVR - no parse error");

		if (![self save])
			[request.delegate request:request didFailWithError:RequestServerSaveObjectError];
		else {NSLog(@"MVR - savee error");
			[request finish];}
	}
	//MVR - remove data from dictionary
	CFDictionaryRemoveValue(self.urlConnectionDictionaryRef, urlConnection);
	[request release];
}


@end
