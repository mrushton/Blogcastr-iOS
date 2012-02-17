//
//  TwitterShareController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 12/20/11.
//  Copyright (c) 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "MBProgressHUD.h"
#import "TwitterXAuth.h"

@interface TwitterShareController : UITableViewController <MBProgressHUDDelegate, UIActionSheetDelegate, UITextViewDelegate, TwitterXAuthDelegate> {
    Session *session;
    UITextView *textView;
    NSString *text;
    TwitterXAuth *_twitterXAuth;
    MBProgressHUD *_progressHud;
	UIActionSheet *_cancelActionSheet;
	UIActionSheet *_cancelRequestActionSheet;
	UIAlertView *_alertView;
    BOOL isTweeting;
}

@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, readonly) TwitterXAuth *twitterXAuth;
@property (nonatomic, readonly) MBProgressHUD *progressHud;
@property (nonatomic, readonly) UIActionSheet *cancelActionSheet;
@property (nonatomic, readonly) UIActionSheet *cancelRequestActionSheet;
@property (nonatomic, readonly) UIAlertView *alertView;

- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
