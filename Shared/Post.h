//
//  Post.h
//  Blogcastr
//
//  Created by Matthew Rushton on 7/3/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Blogcast;
@class Comment;
@class PostStreamCell;
@class User;

@interface Post :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * imageWidth;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * imageHeight;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) User * user;
@property (nonatomic, retain) Blogcast * blogcast;
@property (nonatomic, retain) PostStreamCell * streamCell;
@property (nonatomic, retain) Comment * comment;

@end



