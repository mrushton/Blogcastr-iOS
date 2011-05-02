//
//  RequestServer.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/10/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Session.h"
#import "Request.h"
#import "BlogcastsRequest.h"


typedef enum {
	RequestServerConnectionError,
	RequestServerStatusCodeError,
	RequestServerParseResponseError,
	RequestServerSaveObjectError
} RequestServerError;

@class Request;
@class BlogcastsRequest;

@protocol RequestServerProtocol

- (void)request:(Request *)request didFailWithError:(RequestServerError)error;

@optional 

- (void)requestFinishedWithBlogcasts:(NSArray *)blogcasts;

@end

@interface RequestServer : NSObject {
	Session *session;
	NSManagedObjectContext *managedObjectContext;
	//AS DESIGNED: NSMutableDictionary is not used because NSURLConnection does not support copying	
	CFMutableDictionaryRef _urlConnectionDictionaryRef;
}

@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) CFMutableDictionaryRef urlConnectionDictionaryRef;

+ (RequestServer *)sharedRequestServer;
- (BlogcastsRequest *)requestBlogcastsWithUser:(User *)user maxId:(NSInteger)maxId count:(NSInteger)count delegate:(id)delegate;
- (void)cancelRequest:(NSInteger)requestId;
- (BOOL)save;


@end
