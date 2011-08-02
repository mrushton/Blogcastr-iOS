//
//  User.h
//  Blogcastr
//
//  Created by Matthew Rushton on 7/11/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Blogcast;
@class Comment;
@class Post;
@class Settings;

@interface User :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * numComments;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * numBlogcasts;
@property (nonatomic, retain) NSNumber * facebookId;
@property (nonatomic, retain) NSString * facebookFullName;
@property (nonatomic, retain) NSDate * blogcastsUpdatedAt;
@property (nonatomic, retain) NSNumber * numSubscriptions;
@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * numLikes;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * web;
@property (nonatomic, retain) NSNumber * numPosts;
@property (nonatomic, retain) NSString * twitterUsername;
@property (nonatomic, retain) NSNumber * blogcastsAtEnd;
@property (nonatomic, retain) NSString * facebookLink;
@property (nonatomic, retain) NSNumber * numSubscribers;
@property (nonatomic, retain) NSString * facebookAccessToken;
@property (nonatomic, retain) NSString * twitterAccessToken;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet* blogcasts;
@property (nonatomic, retain) NSSet* subscriptions;
@property (nonatomic, retain) Settings * settings;
@property (nonatomic, retain) NSSet* subscribers;
@property (nonatomic, retain) NSSet* posts;
@property (nonatomic, retain) NSSet* comments;

@end


@interface User (CoreDataGeneratedAccessors)
- (void)addBlogcastsObject:(Blogcast *)value;
- (void)removeBlogcastsObject:(Blogcast *)value;
- (void)addBlogcasts:(NSSet *)value;
- (void)removeBlogcasts:(NSSet *)value;

- (void)addSubscriptionsObject:(NSManagedObject *)value;
- (void)removeSubscriptionsObject:(NSManagedObject *)value;
- (void)addSubscriptions:(NSSet *)value;
- (void)removeSubscriptions:(NSSet *)value;

- (void)addSubscribersObject:(NSManagedObject *)value;
- (void)removeSubscribersObject:(NSManagedObject *)value;
- (void)addSubscribers:(NSSet *)value;
- (void)removeSubscribers:(NSSet *)value;

- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSSet *)value;
- (void)removePosts:(NSSet *)value;

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)value;
- (void)removeComments:(NSSet *)value;

@end

