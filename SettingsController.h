//
//  SettingsController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 2/22/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"


@interface SettingsController : UITableViewController {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
	UIAlertView *alertView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) UIAlertView *alertView;

- (void)saveOriginalImages:(UISwitch *)theSwitch;
- (void)errorAlert:(NSString *)error;

@end
