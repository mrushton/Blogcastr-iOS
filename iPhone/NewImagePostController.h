//
//  NewImagePostController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 5/3/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Session.h"
#import "Blogcast.h"
#import "TextViewWithPlaceholder.h"
#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"

@interface NewImagePostController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate, UIActionSheetDelegate, NSXMLParserDelegate> {
	NSManagedObjectContext *managedObjectContext;
	Session *session;
	Blogcast *blogcast;
	UIImage *image;
	UIImage *thumbnailImage;
	NSData *data;
	TextViewWithPlaceholder *textView;
	MBProgressHUD *_progressHud;
	UIActionSheet *_imageActionSheet;
	UIActionSheet *_cancelActionSheet;
	UIActionSheet *_cancelRequestActionSheet;
	UIAlertView *_alertView;
	ASIHTTPRequest *request;
	NSMutableString *mutableString;
	NSInteger theId;
	BOOL inUser;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Blogcast *blogcast;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) TextViewWithPlaceholder *textView;
@property (nonatomic, readonly) MBProgressHUD *progressHud;
@property (nonatomic, readonly) UIActionSheet *imageActionSheet;
@property (nonatomic, readonly) UIActionSheet *cancelActionSheet;
@property (nonatomic, readonly) UIActionSheet *cancelRequestActionSheet;
@property (nonatomic, readonly) UIAlertView *alertView;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) NSMutableString *mutableString;

- (void)savedImage:(UIImage *)image withError:(NSError *)error contextInfo:(void *)contextInfo;
- (NSURL *)newImagePostUrl;
- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
