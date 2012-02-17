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
#import "XMPPStream.h"
#import "XMPPReconnect.h"
#import "FBConnect.h"


@interface HomeController : TabToolbarController {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
    Facebook *facebook;
	XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
	BOOL didAuthenticate;
	BOOL wasToldToDisconnect;
	UIAlertView *_alertView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) XMPPStream *xmppStream;
@property (nonatomic, retain) XMPPReconnect *xmppReconnect;
@property (nonatomic, retain, readonly) UIAlertView *alertView;

- (BOOL)connect;
- (void)disconnect;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
