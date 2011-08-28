//
//  RootController.m
//  Blogcaster
//
//  Created by Matthew Rushton on 8/10/10.
//  Copyright 2010 Blogcastr. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "AppDelegate_Shared.h"
#import "RootController.h"
#import "HomeController.h"
#import "BlogcastsController.h"
#import "UserController.h"
#import "SettingsController.h"
#import "Session.h"
#import "SignInController.h"
#import "BlogcastrStyleSheet.h"

@implementation RootController

@synthesize managedObjectContext;
@synthesize session;

- (RootController *)init {
	self = [super init];
	if (self) {
		self.navigationBar.tintColor = TTSTYLEVAR(navigationBarTintColor);
		//MVR - active/inactive notifications used for reachability
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(active:) name:UIApplicationDidBecomeActiveNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive:) name:UIApplicationWillResignActiveNotification object:nil];
		//MVR - sign out notification
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signOut) name:@"signOut" object:nil];
	}

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
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[self teardownNetworkMonitoring];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (UIAlertView *)alertView {
	if (!_alertView) {
		_alertView = [[UIAlertView alloc] init];
		[_alertView addButtonWithTitle:@"Ok"];
	}
	
	return _alertView;
}

#pragma mark -
#pragma mark Reachability

static void ReachabilityChanged(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
	NSInteger isReachable;
	NSInteger isConnectionRequired;
	NSInteger isWWAN;
	
	//MVR - this code was adapted from some old Movolu code
	NSLog(@"Network reachability changed 0x%x\n", flags);
	isReachable = flags&kSCNetworkReachabilityFlagsReachable;
	isConnectionRequired = flags&kSCNetworkReachabilityFlagsConnectionRequired;
	isWWAN = flags&kSCNetworkReachabilityFlagsIsWWAN;
	if (isReachable && (!isConnectionRequired || isWWAN)) {
		NSLog(@"Network connection is up");
	} else {
		HomeController *homeController = (HomeController *)info;
		
		NSLog(@"Network connection is down");
		[homeController errorAlertWithTitle:@"No connection" message:@"Oops! We don't have a network connection."];
	}
}

#pragma mark -
#pragma mark Actions

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

- (void)active:(NSNotification *)notification {
	[self setupNetworkMonitoring];
}

- (void)resignActive:(NSNotification *)notification {
	NSLog(@"MVR - DID BECOME INACTIVE");
}

#pragma mark -
#pragma mark Actions

//MVR - network monitoring setup/teardown code was adapted from XMPPReconnect
- (void)setupNetworkMonitoring
{
	if (reachability == NULL)
	{
#ifdef DEVEL
		NSString *domain = @"blogcastr.com";
#else //DEVEL
		NSString *domain = @"sandbox.blogcastr.com";
#endif //DEVEL
		
		reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
		
		if (reachability)
		{
			SCNetworkReachabilityContext context = {0, self, NULL, NULL, NULL};
			SCNetworkReachabilitySetCallback(reachability, ReachabilityChanged, &context);
			
			SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		}
	}
}

- (void)teardownNetworkMonitoring
{
	if (reachability)
	{
		SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		CFRelease(reachability);
		reachability = NULL;
	}
}

- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message {
	//MVR - update and display the alert view
	self.alertView.title = title;
	self.alertView.message = message;
	[self.alertView show];
}

@end
