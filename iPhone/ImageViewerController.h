//
//  ImageViewerController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 3/28/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "MBProgressHUD.h"


@interface ImageViewerController : UIViewController <TTURLRequestDelegate, TTScrollViewDataSource, TTScrollViewDelegate, UIActionSheetDelegate, MBProgressHUDDelegate> {
	NSString *imageUrl;
	UIImage *image;
	UIImageView *imageView;
	UIToolbar *toolbar;
	UIBarButtonItem *actionButtonItem;
	UIActivityIndicatorView *activityIndicatorView;
	UIActionSheet *_actionSheet;
	MBProgressHUD *_progressHUD;
	UIAlertView *_alertView;
	TTURLRequest *request;
}

@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIBarButtonItem *actionButtonItem;
@property (nonatomic, retain, readonly) UIActionSheet *actionSheet;
@property (nonatomic, retain, readonly) MBProgressHUD *progressHUD;
@property (nonatomic, retain, readonly) UIAlertView *alertView;
@property (nonatomic, retain) TTURLRequest *request;

+ (NSOperationQueue *)sharedOperationQueue;
- (BOOL)isShowingBars;
- (void)showBars:(BOOL)show animated:(BOOL)animated;
- (void)showBarsAnimationDidStop;
- (void)hideBarsAnimationDidStop;
- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)showProgressHudWithLabelText:(NSString *)labelText animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
