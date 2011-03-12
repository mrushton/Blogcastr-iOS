//
//  BlogcastrServer.h
//  Blogcastr
//
//  Created by Matthew Rushton on 3/1/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"


@interface BlogcastrServer : NSObject {
    NSManagedObjectContext *managedObjectContext;
//	Session *session;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, retain) Session *session;

+ (BlogcastrServer *)sharedBlogcastrServer;
- (NSUInteger)getAuthenticationTokenForUsername:(NSString *)username password:(NSString *)password;
- (NSUInteger)getUser:(NSUInteger)userId;

@end
