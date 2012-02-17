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
#import "Subscription.h"
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "FBConnect.h"


@interface UserController : UITableViewController <TabToolbarControllerProtocol, MBProgressHUDDelegate> {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
    Facebook *facebook;
	User *user;
	Subscription *subscription;
	TabToolbarController *tabToolbarController;
	UIBarButtonItem *_subscribeButton;
	UIBarButtonItem *_unsubscribeButton;
	ASIHTTPRequest *request;
	BOOL isLoading;
	BOOL isUpdating;
	MBProgressHUD *_viewProgressHud;
	MBProgressHUD *_windowProgressHud;
	UIAlertView *_alertView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Subscription *subscription;
//AS DESIGNED: keep a weak reference to avoid retian cycles
@property (nonatomic, assign) TabToolbarController *tabToolbarController;
@property (nonatomic, readonly) UIBarButtonItem *subscribeButton;
@property (nonatomic, readonly) UIBarButtonItem *unsubscribeButton;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, readonly) MBProgressHUD *viewProgressHud;
@property (nonatomic, readonly) MBProgressHUD *windowProgressHud;
@property (nonatomic, readonly) UIAlertView *alertView;

- (BOOL)save;
- (void)updateUser;
- (NSString *)avatarUrlForSize:(NSString *)size;
- (TTView *)statViewFor:(NSString *)name value:(NSNumber *)value;
- (UIView *)footerView;
- (NSURL *)userUrl;
- (NSURL *)subscribeUrl;
- (NSURL *)unsubscribeUrl;
- (void)showViewProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)showWindowProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
