//
//  RootController_iPhone.m
//  Broadcaster
//
//  Created by Matthew Rushton on 8/10/10.
//  Copyright 2010 Blogcastr. All rights reserved.
//

#import "AppDelegate_Shared.h"
#import "RootController_iPhone.h"
#import "HomeController.h"
#import "BlogcastsController.h"
#import "UserController.h"
#import "SettingsController.h"
#import "Session.h"
#import "SignInController.h"

@implementation RootController_iPhone

@synthesize managedObjectContext;
@synthesize session;

- (RootController_iPhone *)init {
	[super init];
	self.navigationBar.tintColor = [UIColor colorWithRed:0.18 green:0.30 blue:0.38 alpha:1.0];
	//MVR - sign out notification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signOut) name:@"signOut" object:nil];
	
	return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		// Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
//	BlogcastsController_Shared *blogcastsController;
 
	//MVR - initialize blogcasts controller
//	blogcastsController = [self.viewControllers objectAtIndex:0];
//	blogcastsController.managedObjectContext = managedObjectContext;
//	blogcastsController.session = session;
}

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {

}
*/
 
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)signIn {
	BlogcastsController *blogcastsController;
	UserController *userController;
	SettingsController *settingsController;
	HomeController *homeController;

	//MVR - create the Home Controller at the bottom of the navigation controller stack
	homeController = [[HomeController alloc] init];
	homeController.session = session;
	//MVR - set Home Controller title
	homeController.title = session.user.username;
	//MVR - now create each tab
	blogcastsController = [[BlogcastsController alloc] initWithStyle:UITableViewStylePlain];
	blogcastsController.managedObjectContext = self.managedObjectContext;
	blogcastsController.session = session;
	blogcastsController.user = session.user;
	blogcastsController.tabBarItem.title = @"Blogcasts";
	userController = [[UserController alloc] initWithStyle:UITableViewStyleGrouped];
	userController.managedObjectContext = self.managedObjectContext;
	userController.session = session;
	userController.user = session.user;
	userController.tabBarItem.title = @"Profile";
	settingsController = [[SettingsController alloc] initWithStyle:UITableViewStyleGrouped];
	settingsController.tabBarItem.title = @"Settings";
	settingsController.managedObjectContext = self.managedObjectContext;
	settingsController.session = session;
	homeController.viewControllers = [NSArray arrayWithObjects:blogcastsController, userController, settingsController, nil];
	[userController release];
	[settingsController release];
	//MVR - set the navigation stack
	self.viewControllers = [NSArray arrayWithObjects:homeController, nil];
	[homeController release];
}

- (void)signOut {
	SignInController *signInController;
	
	signInController = [[SignInController alloc] init];
	signInController.managedObjectContext = self.managedObjectContext;
	signInController.session = session;
	signInController.delegate = self;
	[self presentModalViewController:signInController animated:YES];
	[signInController release];
}

@end
