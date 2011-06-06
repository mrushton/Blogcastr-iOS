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
#import "XMPPStream.h"
#import "XMPPRoom.h"


@interface DashboardController : TabToolbarController {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
	Blogcast *blogcast;
	XMPPStream *xmppStream;
	XMPPRoom *xmppRoom;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Blogcast *blogcast;
@property (nonatomic, retain) XMPPStream *xmppStream;
@property (nonatomic, retain) XMPPRoom *xmppRoom;

- (BOOL)connect;
- (void)disconnect;

@end
