//
//  TabToolbarController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 2/26/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "TabToolbarController.h"
#import "RootController_iPhone.h"


@implementation TabToolbarController

@synthesize selectedIndex;
@synthesize tabBar;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	CGRect applicationFrame;
	UIView *theView;
	CGRect frame;
	NSMutableArray *items;
	UIViewController *viewController;

	applicationFrame = [UIScreen mainScreen].applicationFrame;
	theView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, applicationFrame.size.width, applicationFrame.size.height - TT_TOOLBAR_HEIGHT)];
	//MVR - set up the tab view
	viewController = [viewControllers objectAtIndex:selectedIndex];
	if (viewController) {
		viewController.view.frame = CGRectMake(0.0, 0.0, applicationFrame.size.width, applicationFrame.size.height - TT_TOOLBAR_HEIGHT - TAB_TOOLBAR_HEIGHT);
		[theView addSubview:viewController.view];
	}
	//MVR - set up the tab bar
	frame = CGRectMake(0.0, applicationFrame.size.height - TT_TOOLBAR_HEIGHT - TAB_TOOLBAR_HEIGHT, applicationFrame.size.width, TAB_TOOLBAR_HEIGHT);
	tabBar = [[UITabBar alloc] initWithFrame:frame];
	tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
	tabBar.delegate = self;
	items = [NSMutableArray arrayWithCapacity:5];
	for (int i = 0; i < [viewControllers count]; i++)
		[items addObject:[[viewControllers objectAtIndex:i] tabBarItem]];
	tabBar.items = items;
	//TODO: saving state of tab bar
	if (viewController)
		tabBar.selectedItem = viewController.tabBarItem;	
	[theView addSubview:tabBar];
	self.view = theView;
	[theView release];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)viewWillAppear:(BOOL)animated {
	UIViewController *viewController;
	
	[super viewWillAppear:animated];
	viewController = [viewControllers objectAtIndex:selectedIndex];
	if (!viewController) {
		NSLog(@"Error finding tab view controller");
		return;
	}
	[viewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	UIViewController *viewController;

	[super viewWillAppear:animated];
	viewController = [viewControllers objectAtIndex:selectedIndex];
	if (!viewController) {
		NSLog(@"Error finding tab view controller");
		return;
	}
	[viewController viewDidAppear:animated];
}

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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.tabBar = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	[viewControllers release];
	[tabBar release];
    [super dealloc];
}

- (NSArray *)viewControllers {
	return viewControllers;
}

- (void)setViewControllers:(NSArray *)theViewControllers {
	//AS DESIGNED: this does nothing to the tab bar
	[viewControllers release];
	viewControllers = [theViewControllers copy];
	NSLog(@"MVR - setting view controllers %d", [viewControllers count]);
	//MVR - set up the tab bar views
	for (int i = 0; i < [viewControllers count]; i++) {
		UIViewController<TabToolbarControllerProtocol> *viewController;

		viewController = [viewControllers objectAtIndex:i];
		[viewController setTabToolbarController:self];
		viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		viewController.view.tag = TAB_TOOLBAR_VIEW_TAG;
	}
}

#pragma mark -
#pragma mark UITabBarDelegate methods

- (void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)item {
	NSUInteger index;
	UIViewController *viewController;
	UIView *currentView;
	CGRect applicationFrame;
	CGRect frame;

	//MVR - remove current view
	currentView = [self.view viewWithTag:TAB_TOOLBAR_VIEW_TAG];
	[currentView removeFromSuperview];
	//MVR - add selected view
	index = [[theTabBar items] indexOfObject:item];
	viewController = [viewControllers objectAtIndex:index];
	if (!viewController) {
		NSLog(@"Error finding tab view controller");
		return;
	}
	//MVR - update index
	selectedIndex = index;
	//MVR - set frame
	applicationFrame = [UIScreen mainScreen].applicationFrame;
	frame = CGRectMake(0.0, 0.0, applicationFrame.size.width, applicationFrame.size.height - TT_TOOLBAR_HEIGHT - TAB_TOOLBAR_HEIGHT);
	viewController.view.frame = frame;
	[self.view addSubview:viewController.view];
	[viewController viewWillAppear:NO];
}	
	
@end
