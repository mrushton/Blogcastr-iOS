//
//  NewBlogcastController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/23/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Session.h"
#import "Blogcast.h"
#import "TextViewWithPlaceholder.h"
#import "MBProgressHUD.h"


@interface NewBlogcastController : UITableViewController {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
	UITextField *titleTextField;
	NSDate *startingAt;
	TextViewWithPlaceholder *descriptionTextView;
	TextViewWithPlaceholder *tagsTextView;
	MBProgressHUD *_progressHud;
	UIAlertView *_alertView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) UITextField *titleTextField;
@property (nonatomic, retain) NSDate *startingAt;
@property (nonatomic, retain) TextViewWithPlaceholder *descriptionTextView;
@property (nonatomic, retain) TextViewWithPlaceholder *tagsTextView;
@property (nonatomic, readonly) MBProgressHUD *progressHud;
@property (nonatomic, retain) UIAlertView *alertView;

- (NSURL *)newBlogcastUrl;
- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
