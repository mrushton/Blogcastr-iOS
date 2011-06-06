//
//  BlogcastStreamCell.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/13/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Blogcast;
@class User;

@interface BlogcastStreamCell :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * maxId;
@property (nonatomic, retain) Blogcast * blogcast;
@property (nonatomic, retain) User * user;

@end



