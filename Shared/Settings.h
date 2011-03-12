//
//  Settings.h
//  Blogcastr
//
//  Created by Matthew Rushton on 3/7/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Settings :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * saveOriginalImages;
@property (nonatomic, retain) NSNumber * vibrate;

@end



