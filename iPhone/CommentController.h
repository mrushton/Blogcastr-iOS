//
//  CommentController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 7/3/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Session.h"
#import "Comment.h"
#import "Subscription.h"
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"


@interface CommentController : UIViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate> {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
	Comment *comment;
	UITableView *tableView;
	ASIHTTPRequest *request;
	MBProgressHUD *_progressHud;
	UIAlertView *_alertView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Comment *comment;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, readonly) MBProgressHUD *progressHud;
@property (nonatomic, readonly) UIAlertView *alertView;

- (NSString *)avatarUrlForUser:(User *)user size:(NSString *)size;
- (NSURL *)postCommentUrl;
- (Subscription *)subscriptionForUser:(User *)user;
- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
