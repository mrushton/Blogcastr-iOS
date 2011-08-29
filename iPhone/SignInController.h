//
//  SignInController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 2/26/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "MBProgressHUD.h"

@protocol SignInControllerProtocol

- (void)signIn;

@end

@interface SignInController : UITableViewController <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate> {
    NSManagedObjectContext *managedObjectContext;
	Session *session;
  	//MVR - use a delegate to properly get rid of a compiler warning
	id<SignInControllerProtocol> delegate;
	UITextField *signInUsernameTextField;
	UITextField *signInPasswordTextField;
	UITextField *signUpFullNameTextField;
	UITextField *signUpUsernameTextField;
	UITextField *signUpPasswordTextField;
	UITextField *signUpEmailTextField;
	MBProgressHUD *_progressHud;
	UIAlertView *_alertView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) id<SignInControllerProtocol> delegate;
@property (nonatomic, retain) UITextField *signInUsernameTextField;
@property (nonatomic, retain) UITextField *signInPasswordTextField;
@property (nonatomic, retain) UITextField *signUpFullNameTextField;
@property (nonatomic, retain) UITextField *signUpUsernameTextField;
@property (nonatomic, retain) UITextField *signUpPasswordTextField;
@property (nonatomic, retain) UITextField *signUpEmailTextField;
@property (nonatomic, readonly) MBProgressHUD *progressHud;
@property (nonatomic, readonly) UIAlertView *alertView;

- (BOOL)save;
- (void)signInUsernameEntered;
- (void)signIn;
- (void)signUpFullNameEntered;
- (void)signUpUsernameEntered;
- (void)signUpPasswordEntered;
- (void)signUp;
- (NSURL *)authenticationTokenUrl;
- (NSURL *)signUpUrl;
- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
