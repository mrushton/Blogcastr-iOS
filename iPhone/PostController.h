//
//  PostController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 6/18/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Session.h"
#import "Post.h"
#import "MBProgressHUD.h"
#import "Subscription.h"
#import "FBConnect.h"
#import "AppDelegate_iPhone.h"
#import "TwitterConnectController.h"


@interface PostController : UIViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate, UIActionSheetDelegate, FacebookConnectDelegate, FBDialogDelegate, TwitterConnectControllerProtocol, MFMailComposeViewControllerDelegate> {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
    Facebook *facebook;
	Post *post;
	UITableView *tableView;
	UIActionSheet *_actionSheet;
	MBProgressHUD *_progressHud;
	UIAlertView *_alertView;
    NSTimer *timer;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, readonly) UIActionSheet *actionSheet;
@property (nonatomic, readonly) MBProgressHUD *progressHud;
@property (nonatomic, readonly) UIAlertView *alertView;
@property (nonatomic, retain) NSTimer *timer;

- (void)presentFacebookDialog;
- (void)presentTwitterShareController;
- (BOOL)save;
- (NSString *)avatarUrlForUser:(User *)user size:(NSString *)size;
- (NSString *)imagePostUrlForSize:(NSString *)size;
- (NSURL *)deletePostUrl;
- (NSString *)imageUrl:(NSString *)string forSize:(NSString *)size;
- (Subscription *)subscriptionForUser:(User *)user;
- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
