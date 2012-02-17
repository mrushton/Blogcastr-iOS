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
#import "ASIHTTPRequest.h"
#import "AppDelegate_iPhone.h"
#import "FBConnect.h"

@interface NewTextPostController : UITableViewController <MBProgressHUDDelegate, UIActionSheetDelegate, UITextViewDelegate, FacebookConnectDelegate> {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
    Facebook *facebook;
	Blogcast *blogcast;
	UITextView *textView;
    UISwitch *twitterSwitch;
	UISwitch *facebookSwitch;
	MBProgressHUD *_progressHud;
	UIActionSheet *_cancelActionSheet;
	UIActionSheet *_cancelRequestActionSheet;
	UIAlertView *_alertView;
	ASIHTTPRequest *request;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) Blogcast *blogcast;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UISwitch *twitterSwitch;
@property (nonatomic, retain) UISwitch *facebookSwitch;
@property (nonatomic, readonly) MBProgressHUD *progressHud;
@property (nonatomic, readonly) UIActionSheet *cancelActionSheet;
@property (nonatomic, readonly) UIActionSheet *cancelRequestActionSheet;
@property (nonatomic, readonly) UIAlertView *alertView;
@property (nonatomic, retain) ASIHTTPRequest *request;

- (NSURL *)newTextPostUrl;
- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
