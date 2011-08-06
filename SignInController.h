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

@interface SignInController : UIViewController <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate> {
    NSManagedObjectContext *managedObjectContext;
	Session *session;
  	//MVR - use a delegate to properly get rid of a compiler warning
	id<SignInControllerProtocol> delegate;
	UITextField *usernameTextField;
	UITextField *passwordTextField;
	MBProgressHUD *_progressHud;
	UIAlertView *_alertView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) id<SignInControllerProtocol> delegate;
@property (nonatomic, retain) UITextField *usernameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;
@property (nonatomic, readonly) MBProgressHUD *progressHud;
@property (nonatomic, readonly) UIAlertView *alertView;

- (BOOL)save;
- (void)usernameEntered:(id)object;
- (void)signIn:(id)object;
- (NSURL *)authenticationTokenUrl;
- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
