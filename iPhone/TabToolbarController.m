//
//  TabToolbarController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 2/26/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "TabToolbarController.h"


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
	UIView *view;
	CGRect frame;
	NSMutableArray *items;
	UIViewController *firstViewController;
	
	view = [[UIView alloc] init];
	//MVR - set up the tab view
	if ([viewControllers count] > 0) {
		firstViewController = [viewControllers objectAtIndex:0];
		[view addSubview:firstViewController.view];
	}
	else {
		firstViewController = nil;
	}
	//MVR - set up the tab bar
	frame = CGRectMake(0.0, 367.0, 320.0, 49.0);
	tabBar = [[UITabBar alloc] initWithFrame:frame];
	tabBar.delegate = self;
	items = [NSMutableArray arrayWithCapacity:5];
	for (int i = 0; i < [viewControllers count]; i++)
		[items addObject:[[viewControllers objectAtIndex:i] tabBarItem]];
	tabBar.items = items;
	//TODO: saving state of tab bar
	if (firstViewController)
		tabBar.selectedItem = firstViewController.tabBarItem;	
	[view addSubview:tabBar];
	self.view = view;
	//NSLog(@"TableViewFrame before set:%@",NSStringFromCGRect(firstViewController.view.frame));
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
	self.tabBar = nil;
}

- (NSArray *)viewControllers {
	return viewControllers;
}

- (void)setViewControllers:(NSArray *)theViewControllers {
	CGRect frame;

	//AS DESIGNED: this does nothing to the tab bar
	NSLog(@"MVR - setting view controllers");
	[viewControllers release];
	viewControllers = [theViewControllers copy];
	//MVR - set up the tab bar views
	frame = CGRectMake(0.0, 0.0, 320.0, 367.0);
	for (int i = 0; i < [viewControllers count]; i++) {
		UIViewController *viewController;

		viewController = [viewControllers objectAtIndex:0];
		viewController.view.frame = frame;
		viewController.view.autoresizingMask = UIViewAutoresizingNone;
		viewController.view.tag = TAB_TOOLBAR_VIEW_TAG;
	}
}

#pragma mark -
#pragma mark UITabBarDelegate methods

- (void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)item {
	NSUInteger index;
	UIViewController *viewController;
	UIView *currentView;
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
	//MVR - need to set frame here as well not exactly sure why?
	frame = CGRectMake(0.0, 0.0, 320.0, 367.0);
	viewController.view.frame = frame;
	[self.view addSubview:viewController.view];
}	
	
@end
