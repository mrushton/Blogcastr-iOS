//
//  ImageViewerController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 3/28/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "ImageViewerController.h"


@implementation ImageViewerController

@synthesize scrollView;
@synthesize imageView;

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

- (id)initWithImageView:(TTImageView *)theImageView {
	theImageView.autoresizesToImage = YES;
	self.imageView = theImageView;
	[self initWithNibName:nil bundle:nil];
	
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	CGRect screenFrame;
	CGRect innerFrame;

	screenFrame = [UIScreen mainScreen].bounds;
	self.view = [[[UIView alloc] initWithFrame:screenFrame] autorelease];
	/*CGRect innerFrame = CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height);
	_innerView = [[UIView alloc] initWithFrame:innerFrame];
	_innerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_innerView];*/
	
	scrollView = [[TTScrollView alloc] initWithFrame:screenFrame];
	scrollView.delegate = self;
	scrollView.dataSource = self;
	scrollView.rotateEnabled = NO;
	scrollView.backgroundColor = [UIColor blackColor];
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	//[scrollView addSubview:imageView];

	[self.view addSubview:scrollView];
	
	/*
	
	_toolbar = [[UIToolbar alloc] initWithFrame:
				CGRectMake(0, screenFrame.size.height - TT_ROW_HEIGHT,
						   screenFrame.size.width, TT_ROW_HEIGHT)];
	if (self.navigationBarStyle == UIBarStyleDefault) {
		_toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);
	}
	
	_toolbar.barStyle = self.navigationBarStyle;
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
	_toolbar.items = [NSArray arrayWithObjects:
					  space, _previousButton, space, _nextButton, space, nil];
	[_innerView addSubview:_toolbar];
	*/
}

- (void)viewWillAppear:(BOOL)animated {
	UINavigationBar *navigationBar;

	NSLog(@"MVR - view will appear");
	//MVR - navigation bar
	navigationBar = self.navigationController.navigationBar;
    navigationBar.barStyle = UIBarStyleBlack;
	navigationBar.translucent = YES;
	navigationBar.tintColor = nil;
	//MVR - status bar
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
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

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	if (animated)
		[UIView commitAnimations];
}

- (void)showBarsAnimationDidStop {
	self.navigationController.navigationBarHidden = NO;
}

- (void)hideBarsAnimationDidStop {
	self.navigationController.navigationBarHidden = YES;
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
	//[self startImageLoadTimer:kPhotoLoadShortDelay];
}

- (void)scrollViewWillRotate:(TTScrollView*)scrollView toOrientation:(UIInterfaceOrientation)orientation {
	//self.centerPhotoView.hidesExtras = YES;
}

- (void)scrollViewDidRotate:(TTScrollView*)scrollView {
	//self.centerPhotoView.hidesExtras = NO;
}

- (BOOL)scrollViewShouldZoom:(TTScrollView*)scrollView {
	//return self.centerPhotoView.image != self.centerPhotoView.defaultImage;
	return YES;
}

- (void)scrollViewDidBeginZooming:(TTScrollView*)scrollView {
	//self.centerPhotoView.hidesExtras = YES;
}

- (void)scrollViewDidEndZooming:(TTScrollView*)scrollView {
	//self.centerPhotoView.hidesExtras = NO;
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)scrollView:(TTScrollView *)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex {
	if (imageView.image)
		return imageView.image.size;
	else
		return CGSizeZero;
}

@end
