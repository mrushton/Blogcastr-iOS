//
//  ImageViewerController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 3/28/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "ImageViewerController.h"


@implementation ImageViewerController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		self.wantsFullScreenLayout = YES;
		self.hidesBottomBarWhenPushed = YES;		
    }
    return self;
}

- (id)initWithImageUrl:(NSString *)imageUrl {
	imageView = [[TTImageView alloc] init];
	imageView.delegate = self;
	imageView.autoresizesToImage = YES;
	[imageView setUrlPath:imageUrl];
	[self initWithNibName:nil bundle:nil];
	
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	CGRect screenFrame;

	screenFrame = [UIScreen mainScreen].bounds;
	self.view = [[[UIView alloc] initWithFrame:screenFrame] autorelease];
	scrollView = [[TTScrollView alloc] initWithFrame:screenFrame];
	scrollView.delegate = self;
	scrollView.dataSource = self;
	scrollView.rotateEnabled = NO;
	scrollView.backgroundColor = [UIColor blackColor];
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:scrollView];
	//MVR - place activity indicator view in the center of the screen
	self.activityIndicatorView.center = CGPointMake(screenFrame.size.width / 2.0, screenFrame.size.height / 2.0);
	[self.view addSubview:self.activityIndicatorView];	
	self.toolbar.frame = CGRectMake(0, screenFrame.size.height - TT_TOOLBAR_HEIGHT, screenFrame.size.width, TT_TOOLBAR_HEIGHT);
	[self.view addSubview:self.toolbar];
}

- (void)viewWillAppear:(BOOL)animated {
	UINavigationBar *navigationBar;

	//MVR - navigation bar
	navigationBar = self.navigationController.navigationBar;
    navigationBar.barStyle = UIBarStyleBlack;
	navigationBar.translucent = YES;
	navigationBar.tintColor = nil;
	//MVR - status bar
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	[self updateToolbarWithOrientation:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated {
	UINavigationBar *navigationBar;
	
	//MVR - navigation bar
	navigationBar = self.navigationController.navigationBar;
    navigationBar.barStyle = UIBarStyleDefault;
	navigationBar.translucent = NO;
	navigationBar.tintColor = TTSTYLEVAR(navigationBarTintColor);
	//MVR - status bar
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	switch (interfaceOrientation) {
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationLandscapeRight:
		case UIDeviceOrientationLandscapeLeft:
			return YES;
		case UIDeviceOrientationPortraitUpsideDown:
		default:
			return NO;
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self updateToolbarWithOrientation:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[scrollView release];
	[imageView release];
	[_toolbar release];
	[_actionButtonItem release];
	[_activityIndicatorView release];
	[_actionSheet release];
	[_progressHUD release];
}

#pragma mark -
#pragma mark Activity Indicator View

- (UIActivityIndicatorView *)activityIndicatorView {
	if (!_activityIndicatorView) {
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_activityIndicatorView.hidesWhenStopped = YES;
	}

	return _activityIndicatorView;
}

#pragma mark -
#pragma mark Toolbar

- (UIToolbar *)toolbar {
	if (!_toolbar) {
		UIBarItem *spaceItem;

		_toolbar = [[UIToolbar alloc] init];
		_toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);
		_toolbar.barStyle = UIBarStyleBlack;
		_toolbar.translucent = YES;
		_toolbar.tintColor = nil;
		_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
		spaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		_toolbar.items = [NSArray arrayWithObjects: spaceItem, self.actionButtonItem, nil];
	}

	return _toolbar;
}

#pragma mark -
#pragma mark Action Button Item

- (UIBarButtonItem *)actionButtonItem {
	if (!_actionButtonItem) {
		_actionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(pressAction:)];
		if (imageView.image)
			_actionButtonItem.enabled = YES;
		else
			_actionButtonItem.enabled = NO;
	}

	return _actionButtonItem;
}

#pragma mark -
#pragma mark Action Sheet

- (UIActionSheet *)actionSheet {
	if (!_actionSheet)
		_actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save Image", nil];
	
	return _actionSheet;
}

#pragma mark -
#pragma mark Alert View

- (UIAlertView *)alertView {
	if (!_alertView) {
		_alertView = [[UIAlertView alloc] init];
		[_alertView addButtonWithTitle:@"Ok"];
	}

	return _alertView;
}

#pragma mark -
#pragma mark Progress HUD

- (MBProgressHUD *)progressHUD {
	if (!_progressHUD)
		_progressHUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
	
	return _progressHUD;
}

- (void)showProgressHudWithLabelText:(NSString *)labelText animationType:(MBProgressHUDAnimation)animationType{
	self.progressHUD.labelText = labelText;
	self.progressHUD.animationType = animationType;
	[[[UIApplication sharedApplication] keyWindow] addSubview:self.progressHUD];
	[self.progressHUD show:YES];
}

#pragma mark -
#pragma mark Bar Management

- (BOOL)isShowingBars {
	UINavigationBar *navigationBar;
	
	navigationBar = self.navigationController.navigationBar;
	//MVR - current navigation bar state
	if (navigationBar.alpha == 0)
		return NO;
	else
		return YES;
}

- (void)showBars:(BOOL)show animated:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarHidden:!show withAnimation:animated];
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:TT_TRANSITION_DURATION];
		[UIView setAnimationDelegate:self];
		if (show)
			[UIView setAnimationDidStopSelector:@selector(showBarsAnimationDidStop)];
		else
			[UIView setAnimationDidStopSelector:@selector(hideBarsAnimationDidStop)];
	} else {
		if (show)
			[self showBarsAnimationDidStop];
		else
			[self hideBarsAnimationDidStop];
	}
	self.navigationController.navigationBar.alpha = show ? 1 : 0;
	self.toolbar.alpha = show ? 1 : 0;
	if (animated)
		[UIView commitAnimations];
}

- (void)showBarsAnimationDidStop {
	self.navigationController.navigationBarHidden = NO;
}

- (void)hideBarsAnimationDidStop {
	self.navigationController.navigationBarHidden = YES;
}

- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
	CGSize size;

	size = self.view.frame.size;
	if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
		self.toolbar.frame = CGRectMake(0.0, size.height - TT_TOOLBAR_HEIGHT, size.width, TT_TOOLBAR_HEIGHT);
	else
		self.toolbar.frame = CGRectMake(0.0, size.height - TT_LANDSCAPE_TOOLBAR_HEIGHT, size.width, TT_LANDSCAPE_TOOLBAR_HEIGHT + 1);
}

#pragma mark -
#pragma mark TTImageViewDelegate

- (void)imageViewDidStartLoad:(TTImageView *)imageView {
	[self.activityIndicatorView startAnimating];
	self.actionButtonItem.enabled = NO;
}

- (void)imageView:(TTImageView *)imageView didLoadImage:(UIImage *)image {
	[self.activityIndicatorView stopAnimating];
	self.actionButtonItem.enabled = YES;
}

- (void)imageView:(TTImageView *)imageView didFailLoadWithError:(NSError *)error {
	NSLog(@"Error loading image view: %@", [error localizedDescription]);
	[self.activityIndicatorView stopAnimating];
}

#pragma mark -
#pragma mark TTScrollViewDelegate

- (void)scrollView:(TTScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex {
}

- (void)scrollViewWillBeginDragging:(TTScrollView *)scrollView {
	if ([self isShowingBars])
		[self showBars:NO animated:YES];
}

- (void)scrollViewDidEndDecelerating:(TTScrollView*)scrollView {
}

- (void)scrollViewWillRotate:(TTScrollView*)scrollView toOrientation:(UIInterfaceOrientation)orientation {
}

- (void)scrollViewDidRotate:(TTScrollView*)scrollView {
}

- (BOOL)scrollViewShouldZoom:(TTScrollView*)scrollView {
	return YES;
}

- (void)scrollViewDidBeginZooming:(TTScrollView*)scrollView {
}

- (void)scrollViewDidEndZooming:(TTScrollView*)scrollView {
}

- (void)scrollView:(TTScrollView*)scrollView tapped:(UITouch*)touch {
	if ([self isShowingBars])
		[self showBars:NO animated:YES];
	else
		[self showBars:YES animated:NO];
}

#pragma mark -
#pragma mark TTScrollViewDataSource

- (NSInteger)numberOfPagesInScrollView:(TTScrollView*)scrollView {
	return 1;
}

- (UIView *)scrollView:(TTScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex {
	return imageView;
}

- (CGSize)scrollView:(TTScrollView *)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex {
	if (imageView.image)
		return imageView.image.size;
	else
		return CGSizeZero;
}

#pragma mark -
#pragma mark Action

- (void)pressAction:(id)object {
	//MVR - dislpay action sheet
	[self.actionSheet showFromBarButtonItem:self.actionButtonItem animated:YES];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		//MVR - show progress HUD
		[self showProgressHudWithLabelText:@"Saving" animationType:MBProgressHUDAnimationZoom];
		UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	}
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	//MVR - dismiss HUD
	[self.progressHUD hide:YES];
	if (error) {
		NSLog(@"Error saving image: %@", [error localizedDescription]);
		[self errorAlertWithTitle:@"Save Error" message:(NSString *)@"Oops! We couldn't save the image."];
	}
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)theProgressHUD {
	//MVR - remove HUD from screen when the HUD was hidden
	[theProgressHUD removeFromSuperview];
}

#pragma mark -
#pragma mark Error handling

- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message {
	//MVR - display the alert view
	self.alertView.title = title;
	self.alertView.message = message;
	[self.alertView show];
}

@end
