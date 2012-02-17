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
#import "User.h"

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
	NSString *authenticationToken;
    NSNumber *facebookId;
    NSString *facebookFullName;
    NSString *facebookLink;
    NSString *facebookAccessToken;
    NSDate *facebookExpiresAt;
    NSNumber *hasFacebookPublishStream;
    NSString *twitterUsername;
    NSString *twitterAccessToken;
    NSString *twitterTokenSecret;
	NSNumber *numBlogcasts;
	NSNumber *numSubscriptions;
	NSNumber *numSubscribers;
	NSNumber *numPosts;
	NSNumber *numComments;
	NSNumber *numLikes;
	BOOL inStats;
	User *user;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) Subscription *subscription;
//AS DESIGNED: copy always returns an immutable string
@property (nonatomic, retain) NSMutableString *mutableString;
@property (nonatomic, copy) NSNumber *userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *bio;
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *web;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *authenticationToken;
@property (nonatomic, copy) NSNumber *facebookId;
@property (nonatomic, copy) NSString *facebookFullName;
@property (nonatomic, copy) NSString *facebookLink;
@property (nonatomic, copy) NSString *facebookAccessToken;
@property (nonatomic, copy) NSDate *facebookExpiresAt;
@property (nonatomic, copy) NSNumber *hasFacebookPublishStream;
@property (nonatomic, copy) NSString *twitterUsername;
@property (nonatomic, copy) NSString *twitterAccessToken;
@property (nonatomic, copy) NSString *twitterTokenSecret;
@property (nonatomic, copy) NSNumber *numBlogcasts;
@property (nonatomic, copy) NSNumber *numSubscriptions;
@property (nonatomic, copy) NSNumber *numSubscribers;
@property (nonatomic, copy) NSNumber *numPosts;
@property (nonatomic, copy) NSNumber *numComments;
@property (nonatomic, copy) NSNumber *numLikes;
@property (nonatomic, retain) User *user;

- (BOOL)parse;

@end
