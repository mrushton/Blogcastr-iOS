//
//  CommentStreamCell.h
//  Blogcastr
//
//  Created by Matthew Rushton on 6/4/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Blogcast;
@class Comment;

@interface CommentStreamCell :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * maxId;
@property (nonatomic, retain) Blogcast * blogcast;
@property (nonatomic, retain) Comment * comment;

@end



