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
	NSNumber *postUserId;
	NSString *postUserUsername;
	NSString *postUserAvatarUrl;
	NSString *postText;
	NSString *postImageUrl;
	NSNumber *postImageWidth;
	NSNumber *postImageHeight;
	NSNumber *commentId;
	NSNumber *commentUserId;
	NSString *commentUserType;
	NSString *commentUserUsername;
	NSString *commentUserUrl;
	NSString *commentUserAvatarUrl;
	NSDate *commentCreatedAt;
	NSDate *postCreatedAt;
	BOOL inUser;
	BOOL inComment;
	NSMutableArray *posts;
}

@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Blogcast *blogcast;
//AS DESIGNED: copy always returns an immutable string
@property (nonatomic, retain) NSString *mutableString;
@property (nonatomic, retain) NSNumber *postId;
@property (nonatomic, retain) NSString *postType;
@property (nonatomic, retain) NSNumber *postUserId;
@property (nonatomic, retain) NSString *postUserUsername;
@property (nonatomic, retain) NSString *postUserAvatarUrl;
@property (nonatomic, retain) NSString *postText;
@property (nonatomic, retain) NSString *postImageUrl;
@property (nonatomic, retain) NSNumber *postImageWidth;
@property (nonatomic, retain) NSNumber *postImageHeight;
@property (nonatomic, retain) NSNumber *commentId;
@property (nonatomic, retain) NSNumber *commentUserId;
@property (nonatomic, retain) NSString *commentUserType;
@property (nonatomic, retain) NSString *commentUserUsername;
@property (nonatomic, retain) NSString *commentUserUrl;
@property (nonatomic, retain) NSString *commentUserAvatarUrl;
@property (nonatomic, retain) NSDate *commentCreatedAt;
@property (nonatomic, retain) NSDate *postCreatedAt;
@property (nonatomic, retain) NSMutableArray *posts;

- (BOOL)parse;
- (NSDate *)parseTimestamp: (NSString *)timestamp;

@end
