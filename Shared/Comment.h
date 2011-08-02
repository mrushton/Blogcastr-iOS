//
//  Comment.h
//  Blogcastr
//
//  Created by Matthew Rushton on 7/3/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Blogcast;
@class CommentStreamCell;
@class Post;
@class User;

@interface Comment :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) Blogcast * blogcast;
@property (nonatomic, retain) Post * post;
@property (nonatomic, retain) CommentStreamCell * streamCell;
@property (nonatomic, retain) User * user;

@end



