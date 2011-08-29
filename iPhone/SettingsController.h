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
#import "Session.h"
#import "MBProgressHUD.h"


@interface SettingsController : UITableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate, UINavigationControllerDelegate> {
	TabToolbarController *tabToolbarController;
	NSManagedObjectContext *managedObjectContext;
	Session *session;
	UIActionSheet *_avatarActionSheet;
	UIActionSheet *_signOutActionSheet;
	MBProgressHUD *_windowProgressHud;
	UIAlertView *alertView;
}

//AS DESIGNED: keep a weak reference to avoid retian cycles
@property (nonatomic, assign) TabToolbarController *tabToolbarController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, readonly) UIActionSheet *avatarActionSheet;
@property (nonatomic, readonly) UIActionSheet *signOutActionSheet;
@property (nonatomic, readonly) MBProgressHUD *windowProgressHud;
@property (nonatomic, retain) UIAlertView *alertView;

- (void)saveOriginalImages:(UISwitch *)theSwitch;
- (void)vibrate:(UISwitch *)theSwitch;
- (void)signOut;
- (BOOL)save;
- (NSURL *)settingsUrl;
- (void)showWindowProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
