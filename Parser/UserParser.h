//
//  UserParser.h
//  Blogcastr
//
//  Created by Matthew Rushton on 7/17/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Subscription.h"

@interface UserParser : NSObject <NSXMLParserDelegate> {
	NSManagedObjectContext *managedObjectContext;
	NSData *data;
	Subscription *subscription;
	//MVR - xml parser
    NSMutableString *mutableString;
	NSNumber *userId;
	NSString *username;
	NSString *location;
	NSString *bio;
	NSString *fullName;
	NSString *web;
	NSString *avatarUrl;
	NSNumber *numBlogcasts;
	NSNumber *numSubscriptions;
	NSNumber *numSubscribers;
	NSNumber *numPosts;
	NSNumber *numComments;
	NSNumber *numLikes;
	BOOL isSubscribed;
	BOOL inStats;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) Subscription *subscription;
@property (nonatomic, retain) NSMutableString *mutableString;
@property (nonatomic, copy) NSNumber *userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *bio;
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *web;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSNumber *numBlogcasts;
@property (nonatomic, copy) NSNumber *numSubscriptions;
@property (nonatomic, copy) NSNumber *numSubscribers;
@property (nonatomic, copy) NSNumber *numPosts;
@property (nonatomic, copy) NSNumber *numComments;
@property (nonatomic, copy) NSNumber *numLikes;

- (BOOL)parse;

@end