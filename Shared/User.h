//
//  User.h
//  Blogcastr
//
//  Created by Matthew Rushton on 3/7/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>


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
@property (nonatomic, retain) NSString * avatarFileName;

@end



