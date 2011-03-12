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
//#import "NewBlogcastController_Shared.h"
#import "SettingsController.h"
#import "Session.h"
#import "SignInController.h"

@implementation RootController_iPhone

@synthesize managedObjectContext;
@synthesize session;

- (RootController_iPhone *)initWithRootViewController:(UIViewController *)viewController {
	[super initWithRootViewController:viewController];
	self.navigationBar.tintColor = [UIColor colorWithRed:0.18 green:0.30 blue:0.38 alpha:1.0];
	
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
    [super dealloc];
}

- (void)signIn {
	HomeController *homeController;

	//MVR - set Home Controller title
	homeController = [self.viewControllers objectAtIndex:0];
	homeController.title = session.user.username;
	/*if (blogcastsController.updatedAt) {
		[blogcastsController.updatedAt release];
		blogcastsController.updatedAt = nil;
		[blogcastsController.dragRefreshView setUpdateDate:nil];
	}*/
//	[blogcastsController update];
	//MVR - dismiss sign in controller
	[self dismissModalViewControllerAnimated:YES];
}

- (void)settings {
	/*settingsController = [[SettingsController alloc] init];
	settingsController.managedObjectContext = managedObjectContext;
	settingsController.session = session;
	settingsController.delegate = self;
	[self presentModalViewController:sessionController animated:YES];
	[sessionController release];*/
}

- (void)signOut {
/*	BlogcastsController_Shared *blogcastsController;
	SessionController *sessionController;
	NSFetchRequest *fetchRequest;
	NSEntityDescription *entityDescription;
	NSArray *array;
	NSError *error;

	//MVR - clear Session object
	session.username = nil;
	session.password = nil;
	session.authenticationToken = nil;
	session.isAuthenticated = [NSNumber numberWithBool:NO];
	//MVR - delete Blogcast objects
	fetchRequest = [[NSFetchRequest alloc] init];
	entityDescription = [NSEntityDescription entityForName:@"Blogcast" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entityDescription];
	array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	for (NSManagedObject *managedObject in array)
        [managedObjectContext deleteObject:managedObject];
	if (![managedObjectContext save:&error]) {
	    NSLog(@"Error saving managed object context: %@", [error localizedDescription]);
		return;
	}	
	//[session release];
	//session = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:managedObjectContext];
	//[session retain];
	//MVR - update blogcasts controller
	blogcastsController = [self.viewControllers objectAtIndex:0];
	//MVR - session info
	blogcastsController.session = session;
	sessionController = [[SessionController alloc] init];
	sessionController.managedObjectContext = managedObjectContext;
	sessionController.session = session;
	sessionController.delegate = self;
	[self presentModalViewController:sessionController animated:YES];
	[sessionController release];
 */
}

@end
