//
//  Comment.h
//  Blogcastr
//
//  Created by Matthew Rushton on 5/17/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Post;
@class User;

@interface Comment :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) User * user;
@property (nonatomic, retain) NSManagedObject * streamCell;
@property (nonatomic, retain) Post * post;

@end



