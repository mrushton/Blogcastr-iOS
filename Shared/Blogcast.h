//
//  Blogcast.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/3/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>

@class User;

@interface Blogcast :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * startingAt;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * theDescription;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) User * user;
@property (nonatomic, retain) NSNumber * postsAtEnd;
@property (nonatomic, retain) NSNumber * commentsAtEnd;

@end



