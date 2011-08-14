//
//  RootController_iPhone.m
//  Blogcaster
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
#import "BlogcastrStyleSheet.h"

@implementation RootController_iPhone

@synthesize managedObjectContext;
@synthesize session;

- (RootController_iPhone *)init {
	[super init];
	self.navigationBar.tintColor = TTSTYLEVAR(navigationBarTintColor);
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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

}
*/

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
	NSLog(@"MVR - RootController didReceiveMemWAtn");
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	NSLog(@"MVR - RootController viewDidUnload");
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
	UIImage *image;
	UITabBarItem *theTabBarItem;

	//MVR - create the Home Controller at the bottom of the navigation controller stack
	homeController = [[HomeController alloc] init];
	homeController.title = session.user.username;
	homeController.session = session;
	//MVR - connect to XMPP server
	[homeController connect];
	//MVR - now create each tab
	blogcastsController = [[BlogcastsController alloc] initWithStyle:UITableViewStylePlain];
	blogcastsController.managedObjectContext = self.managedObjectContext;
	blogcastsController.session = session;
	blogcastsController.user = session.user;
	blogcastsController.xmppStream = homeController.xmppStream;
	userController = [[UserController alloc] initWithStyle:UITableViewStyleGrouped];
	//MVR - the user controller does not create a tab bar item
	image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"profile" ofType:@"png"]];
	theTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Profile" image:image tag:0];
	userController.tabBarItem = theTabBarItem;
	[theTabBarItem release];
	userController.managedObjectContext = self.managedObjectContext;
	userController.session = session;
	userController.user = session.user;
	settingsController = [[SettingsController alloc] initWithStyle:UITableViewStyleGrouped];
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
	UINavigationController *theNavigationController;
	SignInController *signInController;
	
	signInController = [[SignInController alloc] initWithStyle:UITableViewStyleGrouped];
	signInController.managedObjectContext = self.managedObjectContext;
	signInController.session = self.session;
	signInController.delegate = self;
	theNavigationController = [[UINavigationController alloc] initWithRootViewController:signInController];
	[signInController release];
	theNavigationController.navigationBar.tintColor = TTSTYLEVAR(navigationBarTintColor);
	[self presentModalViewController:theNavigationController animated:YES];
	[theNavigationController release];
}

@end
