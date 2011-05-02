//
//  UserController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 3/5/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "TabToolbarController.h"
#import "Session.h"
#import "User.h"


@interface UserController : UITableViewController <TabToolbarControllerProtocol> {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
	User *user;
	TabToolbarController *tabToolbarController;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) User *user;
//AS DESIGNED: keep a weak reference to avoid retian cycles
@property (nonatomic, assign) TabToolbarController *tabToolbarController;

- (NSString *)avatarUrlForSize:(NSString *)size;
- (TTView *)statViewFor:(NSString *)name value:(NSNumber *)value;
- (UIView *)footerView;

@end
