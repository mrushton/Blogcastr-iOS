//
//  TwitterConnectController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 10/3/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Session.h"
#import "TwitterXAuth.h"
#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"

@class TwitterConnectController;

@protocol TwitterConnectControllerProtocol <NSObject>

- (void)didConnectTwitter:(TwitterConnectController *)twitterConnectController;

@end

@interface TwitterConnectController : UITableViewController <UIActionSheetDelegate, TwitterXAuthDelegate, MBProgressHUDDelegate> {
    NSManagedObjectContext *managedObjectContext;
	Session *session;
    id<TwitterConnectControllerProtocol> delegate;
	UITextField *usernameTextField;
	UITextField *passwordTextField;
    TwitterXAuth *_twitterXAuth;
    MBProgressHUD *_progressHud;
	UIAlertView *_alertView;
    UIBarButtonItem *_cancelButton;
    UIActionSheet *_actionSheet;
	ASIHTTPRequest *request;
    BOOL isConnecting;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UITextField *usernameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;
@property (nonatomic, readonly) TwitterXAuth *twitterXAuth;
@property (nonatomic, readonly) MBProgressHUD *progressHud;
@property (nonatomic, readonly) UIAlertView *alertView;
@property (nonatomic, readonly) UIBarButtonItem *cancelButton;
@property (nonatomic, readonly) UIActionSheet *actionSheet;
@property (nonatomic, retain) ASIHTTPRequest *request;

- (BOOL)save;
- (NSURL *)twitterConnectUrl;
- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
