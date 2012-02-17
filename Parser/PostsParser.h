//
//  PostsParser.h
//  Blogcastr
//
//  Created by Matthew Rushton on 5/14/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Blogcast.h"


@interface PostsParser : NSObject <NSXMLParserDelegate> {
	NSData *data;
	NSManagedObjectContext *managedObjectContext;
	Blogcast *blogcast;
	//MVR - xml parser
    NSMutableString *mutableString;
	NSNumber *postId;
	NSString *postType;
	User *postUser;
	User *commentUser;
	NSNumber *userId;
	NSString *userType;
	NSString *userUsername;
	NSString *userUrl;
	NSString *userAvatarUrl;
	NSString *text;
	NSString *postImageUrl;
	NSNumber *postImageWidth;
	NSNumber *postImageHeight;
	Comment *comment;
	NSNumber *commentId;
	NSDate *commentCreatedAt;
	NSDate *postCreatedAt;
    NSString *url;
    NSString *shortUrl;
	BOOL inUser;
	BOOL inComment;
	NSMutableArray *posts;
}

@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Blogcast *blogcast;
//AS DESIGNED: copy always returns an immutable string
@property (nonatomic, retain) NSString *mutableString;
@property (nonatomic, retain) User *postUser;
@property (nonatomic, retain) NSNumber *postId;
@property (nonatomic, retain) NSString *postType;
@property (nonatomic, retain) NSNumber *userId;
@property (nonatomic, retain) NSString *userType;
@property (nonatomic, retain) NSString *userUsername;
@property (nonatomic, retain) NSString *userAvatarUrl;
@property (nonatomic, retain) NSString *userUrl;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *postImageUrl;
@property (nonatomic, retain) NSNumber *postImageWidth;
@property (nonatomic, retain) NSNumber *postImageHeight;
@property (nonatomic, retain) Comment *comment;
@property (nonatomic, retain) NSNumber *commentId;
@property (nonatomic, retain) User *commentUser;
@property (nonatomic, retain) NSDate *commentCreatedAt;
@property (nonatomic, retain) NSDate *postCreatedAt;
@property (nonatomic, retain) NSMutableArray *posts;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *shortUrl;


- (BOOL)parse;

@end
