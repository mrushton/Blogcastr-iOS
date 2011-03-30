//
//  SettingsController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 2/22/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "TabToolbarController.h"


@interface SettingsController : UITableViewController {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
	UIAlertView *alertView;
	TabToolbarController *tabToolbarController;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) UIAlertView *alertView;
//AS DESIGNED: keep a weak reference to avoid retian cycles
@property (nonatomic, assign) TabToolbarController *tabToolbarController;


- (void)saveOriginalImages:(UISwitch *)theSwitch;
- (void)signOut:(id)object;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
