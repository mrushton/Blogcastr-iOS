//
//  Blogcast.h
//  Blogcastr
//
//  Created by Matthew Rushton on 7/3/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>

@class BlogcastStreamCell;
@class Comment;
@class Post;
@class User;

@interface Blogcast :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * numComments;
@property (nonatomic, retain) NSNumber * postsBadgeVal;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSNumber * commentsBadgeVal;
@property (nonatomic, retain) NSNumber * numCurrentViewers;
@property (nonatomic, retain) NSNumber * numViews;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * theDescription;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * numLikes;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * numPosts;
@property (nonatomic, retain) NSNumber * postsAtEnd;
@property (nonatomic, retain) NSNumber * commentsAtEnd;
@property (nonatomic, retain) NSDate * startingAt;
@property (nonatomic, retain) NSSet* streamCell;
@property (nonatomic, retain) User * user;
@property (nonatomic, retain) NSSet* posts;
@property (nonatomic, retain) NSSet* comments;

@end


@interface Blogcast (CoreDataGeneratedAccessors)
- (void)addStreamCellObject:(BlogcastStreamCell *)value;
- (void)removeStreamCellObject:(BlogcastStreamCell *)value;
- (void)addStreamCell:(NSSet *)value;
- (void)removeStreamCell:(NSSet *)value;

- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSSet *)value;
- (void)removePosts:(NSSet *)value;

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)value;
- (void)removeComments:(NSSet *)value;

@end

