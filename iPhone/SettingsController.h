//
//  SettingsController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 2/22/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TabToolbarController.h"
#import "AppDelegate_iPhone.h"
#import "Session.h"
#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "FBConnect.h"

@interface SettingsController : UITableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate, UINavigationControllerDelegate, FacebookConnectDelegate> {
	TabToolbarController *tabToolbarController;
	NSManagedObjectContext *managedObjectContext;
	Session *session;
    Facebook *facebook;
	UIActionSheet *_avatarActionSheet;
    UIActionSheet *_facebookActionSheet;
    UIActionSheet *_twitterActionSheet;
	UIActionSheet *_signOutActionSheet;
	MBProgressHUD *_progressHud;
	UIAlertView *alertView;
    //MVR - only one request can be active at once
    ASIHTTPRequest *request;
}

//AS DESIGNED: keep a weak reference to avoid retian cycles
@property (nonatomic, assign) TabToolbarController *tabToolbarController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, readonly) UIActionSheet *avatarActionSheet;
@property (nonatomic, readonly) UIActionSheet *facebookActionSheet;
@property (nonatomic, readonly) UIActionSheet *twitterActionSheet;
@property (nonatomic, readonly) UIActionSheet *signOutActionSheet;
@property (nonatomic, readonly) MBProgressHUD *progressHud;
@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) ASIHTTPRequest *request;

- (void)saveOriginalImages:(UISwitch *)theSwitch;
- (void)vibrate:(UISwitch *)theSwitch;
- (void)signOut;
- (BOOL)save;
- (NSURL *)settingsUrl;
- (NSURL *)facebookConnectUrl;
- (NSURL *)facebookDisconnectUrl;
- (NSURL *)twitterDisconnectUrl;
- (void)showProgressHudWithLabelText:(NSString *)labelText mode:(MBProgressHUDMode)mode animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
