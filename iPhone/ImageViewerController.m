//
//  ImageViewerController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 3/28/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "ImageViewerController.h"
#import "ResizeImageOperation.h"
#import "AppDelegate_Shared.h"


@implementation ImageViewerController

@synthesize imageUrl;
@synthesize image;
@synthesize imageView;
@synthesize activityIndicatorView;
@synthesize toolbar;
@synthesize actionButtonItem;
@synthesize request;

//MVR - the operation queue is static for memory management purposes
static NSOperationQueue *sharedOperationQueue;

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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	CGRect screenFrame;
	UIView *theView;
	UIImageView *theImageView;
	TTScrollView *scrollView;
	UIActivityIndicatorView *theActivityIndicatorView;
	UIToolbar *theToolbar;
	UIBarItem *spaceItem;
	UIBarButtonItem *theActionButtonItem;
	TTURLImageResponse *imageResponse;

	screenFrame = [UIScreen mainScreen].bounds;
	theView = [[UIView alloc] initWithFrame:screenFrame];
	self.view = theView;
	[theView release];
	theImageView = [[UIImageView alloc] init];
	self.imageView = theImageView;
	[theImageView release];
	scrollView = [[TTScrollView alloc] initWithFrame:screenFrame];
	scrollView.delegate = self;
	scrollView.dataSource = self;
	scrollView.backgroundColor = [UIColor blackColor];
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:scrollView];
	[scrollView release];
	//MVR - place activity indicator view in the center of the screen
	theActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	theActivityIndicatorView.hidesWhenStopped = YES;
	theActivityIndicatorView.center = CGPointMake(screenFrame.size.width / 2.0, screenFrame.size.height / 2.0);
	theActivityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
	[theActivityIndicatorView startAnimating];
	[self.view addSubview:theActivityIndicatorView];
	self.activityIndicatorView = theActivityIndicatorView;
	[theActivityIndicatorView release];
	theToolbar = [[UIToolbar alloc] init];
	theToolbar.barStyle = UIBarStyleBlackTranslucent;
	theToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
	spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	theActionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(pressAction:)];
	theActionButtonItem.enabled = NO;
	theToolbar.items = [NSArray arrayWithObjects: spaceItem, theActionButtonItem, nil];
	[spaceItem release];
	self.actionButtonItem = theActionButtonItem;
	[theActionButtonItem release];
	theToolbar.frame = CGRectMake(0, screenFrame.size.height - TT_TOOLBAR_HEIGHT, screenFrame.size.width, TT_TOOLBAR_HEIGHT);
	[self.view addSubview:theToolbar];
	self.toolbar = theToolbar;
	[theToolbar release];
	//MVR - load the image
	self.request = [TTURLRequest requestWithURL:imageUrl delegate:self];
	imageResponse = [[TTURLImageResponse alloc] init];
	request.response = imageResponse;
	[imageResponse release];
	[request send];
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

/*
- (void)viewDidAppear:(BOOL)animated {

}
*/

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
	self.imageView = nil;
	self.activityIndicatorView = nil;
	self.toolbar = nil;
	self.actionButtonItem = nil;
}


- (void)dealloc {
	[image release];
	[activityIndicatorView release];
	[toolbar release];
	[actionButtonItem release];
	[imageView release];
	[_actionSheet release];
	[_progressHUD release];
	[request cancel];
	[request release];
	[super dealloc];
}

+ (NSOperationQueue *)sharedOperationQueue {
	if (!sharedOperationQueue)
		sharedOperationQueue = [[NSOperationQueue alloc] init];
	
	return sharedOperationQueue;
}

- (UIActionSheet *)actionSheet {
	if (!_actionSheet)
		_actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save Image", nil];
		
	return _actionSheet;
}

- (UIAlertView *)alertView {
	if (!_alertView) {
		_alertView = [[UIAlertView alloc] init];
		[_alertView addButtonWithTitle:@"Ok"];
	}

	return _alertView;
}

- (MBProgressHUD *)progressHUD {
	if (!_progressHUD)
		_progressHUD = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
	
	return _progressHUD;
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
#pragma mark TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest *)theRequest {
}

- (void)requestDidFinishLoad:(TTURLRequest *)theRequest {
	ResizeImageOperation *resizeImageOperation;
	TTURLImageResponse *response;

	resizeImageOperation = [[ResizeImageOperation alloc] init];
	response = theRequest.response;
	resizeImageOperation.image = response.image;
	//MVR - keep the original image for saving
	self.image = response.image;
	resizeImageOperation.imageViewerController = self;
	[[ImageViewerController sharedOperationQueue] addOperation:resizeImageOperation];
	[resizeImageOperation release];
}

- (void)request:(TTURLRequest *)theRequest didFailLoadWithError:(NSError *)error {
	NSLog(@"Error loading image %@", [error localizedDescription]);
	self.request = nil;
	[self errorAlertWithTitle:@"Load Error" message:(NSString *)@"Oops! We couldn't load the image."];
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

- (NSInteger)numberOfPagesInScrollView:(TTScrollView* )scrollView {
	return 1;
}

- (UIView *)scrollView:(TTScrollView *)scrollView pageAtIndex:(NSInteger)pageIndex {
	return self.imageView;
}

- (CGSize)scrollView:(TTScrollView *)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex {
	if (self.imageView.image)
		return self.imageView.image.size;
	else
		return CGSizeZero;
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		//MVR - show progress HUD
		[self showProgressHudWithLabelText:@"Saving image..." animationType:MBProgressHUDAnimationZoom];
		UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
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
#pragma mark Actions

- (void)pressAction:(id)object {
	//MVR - dislpay action sheet
	[self.actionSheet showFromBarButtonItem:self.actionButtonItem animated:YES];
}

- (void)resizedImage:(UIImage *)theImage {
	self.imageView.image = theImage;
	[self.imageView sizeToFit];
	[activityIndicatorView stopAnimating];
	actionButtonItem.enabled = YES;
}

#pragma mark -
#pragma mark Helpers

- (void)showProgressHudWithLabelText:(NSString *)labelText animationType:(MBProgressHUDAnimation)animationType{
	self.progressHUD.labelText = labelText;
	self.progressHUD.animationType = animationType;
	[[[UIApplication sharedApplication] keyWindow] addSubview:self.progressHUD];
	[self.progressHUD show:YES];
}

- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message {
	//MVR - display the alert view
	self.alertView.title = title;
	self.alertView.message = message;
	[self.alertView show];
}

@end
