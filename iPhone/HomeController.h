//
//  HomeController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 2/26/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TabToolbarController.h"
#import "Session.h"


@interface HomeController : TabToolbarController {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;

@end
