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


@interface ImageViewerController : UIViewController <TTImageViewDelegate, TTScrollViewDataSource, TTScrollViewDelegate, UIActionSheetDelegate, MBProgressHUDDelegate> {
	TTScrollView *scrollView;
	TTImageView *imageView;
	UIToolbar *_toolbar;
	UIBarButtonItem *_actionButtonItem;
	UIActivityIndicatorView *_activityIndicatorView;
	UIActionSheet *_actionSheet;
	MBProgressHUD *_progressHUD;
	UIAlertView *_alertView;
}

@property (nonatomic, retain, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain, readonly) UIToolbar *toolbar;
@property (nonatomic, retain, readonly) UIBarButtonItem *actionButtonItem;
@property (nonatomic, retain, readonly) UIActionSheet *actionSheet;
@property (nonatomic, retain, readonly) MBProgressHUD *progressHUD;
@property (nonatomic, retain, readonly) UIAlertView *alertView;

- (id)initWithImageUrl:(NSString *)imageUrl;
- (BOOL)isShowingBars;
- (void)showBars:(BOOL)show animated:(BOOL)animated;
- (void)showBarsAnimationDidStop;
- (void)hideBarsAnimationDidStop;
- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)showProgressHudWithLabelText:(NSString *)labelText animationType:(MBProgressHUDAnimation)animationType;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
