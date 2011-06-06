//
//  PostStreamCell.h
//  Blogcastr
//
//  Created by Matthew Rushton on 5/15/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Blogcast;
@class Post;

@interface PostStreamCell :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * maxId;
@property (nonatomic, retain) Post * post;
@property (nonatomic, retain) Blogcast * blogcast;

@end



