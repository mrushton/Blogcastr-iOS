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
#import "ASIHTTPRequest.h"


@interface NewBlogcastController : UITableViewController <MBProgressHUDDelegate, UIActionSheetDelegate> {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
	UITextField *titleTextField;
	NSDate *startingAt;
	TextViewWithPlaceholder *descriptionTextView;
	TextViewWithPlaceholder *tagsTextView;
	MBProgressHUD *_progressHud;
	UIActionSheet *_cancelActionSheet;
	UIActionSheet *_cancelRequestActionSheet;
	UIAlertView *_alertView;
	ASIHTTPRequest *request;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) UITextField *titleTextField;
@property (nonatomic, retain) NSDate *startingAt;
@property (nonatomic, retain) TextViewWithPlaceholder *descriptionTextView;
@property (nonatomic, retain) TextViewWithPlaceholder *tagsTextView;
@property (nonatomic, readonly) MBProgressHUD *progressHud;
@property (nonatomic, readonly) UIActionSheet *cancelActionSheet;
@property (nonatomic, readonly) UIActionSheet *cancelRequestActionSheet;
@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) ASIHTTPRequest *request;

- (void)updateNavigationButtons;
- (NSURL *)newBlogcastUrl;
- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
