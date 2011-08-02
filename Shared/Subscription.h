//
//  Subscription.h
//  Blogcastr
//
//  Created by Matthew Rushton on 7/11/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>

@class User;

@interface Subscription :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * isSubscribed;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) User * subscriber;
@property (nonatomic, retain) User * subscription;

@end



