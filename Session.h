//
//  Session.h
//  Blogcastr
//
//  Created by Matthew Rushton on 2/21/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "User.h"
#import "Settings.h"


@interface Session :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * authenticationToken;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) User * user;


@end



