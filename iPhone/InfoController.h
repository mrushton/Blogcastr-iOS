//
//  InfoController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 6/11/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "TabToolbarController.h"
#import "TwitterConnectController.h"
#import "Session.h"
#import "Blogcast.h"
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "Timer.h"
#import "FBConnect.h"
#import "AppDelegate_iPhone.h"

#define TIMER_INTERVAL 30.0

@interface InfoController : UIViewController <UITableViewDataSource, UITableViewDelegate, TabToolbarControllerProtocol, TimerProtocol, MBProgressHUDDelegate, UIActionSheetDelegate, FacebookConnectDelegate, FBDialogDelegate, TwitterConnectControllerProtocol, MFMailComposeViewControllerDelegate> {
	TabToolbarController *tabToolbarController;
	NSManagedObjectContext *managedObjectContext;
	Session *session;
    Facebook *facebook;
	Blogcast *blogcast;
    UITableView *tableView;
	ASIHTTPRequest *blogcastRequest;
	Timer *timer;
	UIActionSheet *_actionSheet;
	MBProgressHUD *_progressHud;
	UIAlertView *_alertView;
    NSTimer *twitterTimer;
	BOOL isUpdating;
}

//AS DESIGNED: keep a weak reference to avoid retian cycles
@property (nonatomic, assign) TabToolbarController *tabToolbarController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) Blogcast *blogcast;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) ASIHTTPRequest *blogcastRequest;
@property (nonatomic, retain) Timer *timer;
@property (nonatomic, readonly) UIActionSheet *actionSheet;
@property (nonatomic, readonly) MBProgressHUD *progressHud;
@property (nonatomic, readonly) UIAlertView *alertView;
@property (nonatomic, retain) NSTimer *twitterTimer;

- (void)presentFacebookDialog;
- (void)presentTwitterShareController;
- (BOOL)save;
- (void)updateBlogcast;
- (void)reloadBlogcast;
- (void)deleteBlogcast;
- (void)timerExpired:(Timer *)timer;
- (TTLabel *)tagLabelFor:(NSString *)name;
- (TTView *)statViewFor:(NSString *)name value:(NSNumber *)value;
- (UIView *)footerView;
- (NSURL *)blogcastUrl;
- (NSURL *)deleteBlogcastUrl;
- (NSString *)imageUrl:(NSString *)string forSize:(NSString *)size;
- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
