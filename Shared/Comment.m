// 
//  Comment.m
//  Blogcastr
//
//  Created by Matthew Rushton on 7/3/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "Comment.h"

#import "Blogcast.h"
#import "CommentStreamCell.h"
#import "Post.h"
#import "User.h"

@implementation Comment 

@dynamic id;
@dynamic text;
@dynamic createdAt;
@dynamic blogcast;
@dynamic post;
@dynamic streamCell;
@dynamic user;

@end
