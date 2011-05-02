//
//  User.h
//  Blogcastr
//
//  Created by Matthew Rushton on 3/7/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Settings.h"


@interface User :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * web;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) NSNumber * numBlogcasts;
@property (nonatomic, retain) NSNumber * numSubscriptions;
@property (nonatomic, retain) NSNumber * numSubscribers;
@property (nonatomic, retain) NSNumber * numPosts;
@property (nonatomic, retain) NSNumber * numComments;
@property (nonatomic, retain) NSNumber * numLikes;
@property (nonatomic, retain) NSDate * blogcastsUpdatedAt;
@property (nonatomic, retain) NSNumber * blogcastsAtEnd;
@property (nonatomic, retain) Settings * settings;

@end



