//
//  DashboardController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/30/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TabToolbarController.h"
#import "Session.h"
#import "Blogcast.h"


@interface DashboardController : TabToolbarController {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
	Blogcast *blogcast;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Blogcast *blogcast;

@end
