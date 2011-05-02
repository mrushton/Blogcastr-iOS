//
//  NewTextPostController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 5/1/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Session.h"
#import "Blogcast.h"
#import "MBProgressHUD.h"

@interface NewTextPostController : UITableViewController {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
	Blogcast *blogcast;
	UITextView *textView;
	MBProgressHUD *_progressHud;
	UIAlertView *_alertView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Blogcast *blogcast;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, readonly) MBProgressHUD *progressHud;
@property (nonatomic, readonly) UIAlertView *alertView;

- (NSURL *)newTextPostUrl;
- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
