    //
//  DashboardController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/30/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "DashboardController.h"


@implementation DashboardController

@synthesize managedObjectContext;
@synthesize session;
@synthesize blogcast;

- (id)init {
	self = [super init];
	if (self) {
		UIBarButtonItem *editBlogcastButton;
		
		//MVR - add bar button item
		editBlogcastButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(editBlogcast)];
		editBlogcastButton.title = @"Edit";
		self.navigationItem.rightBarButtonItem = editBlogcastButton;		
		[editBlogcastButton release];
	}
	
	return self;
}

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

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
#pragma mark Actions

- (void)editBlogcast {
/*	UINavigationController *theNavigationController;
	NewBlogcastController *newBlogcastController;
	
	newBlogcastController = [[NewBlogcastController alloc] initWithStyle:UITableViewStyleGrouped];
	newBlogcastController.managedObjectContext = managedObjectContext;
	newBlogcastController.session = session;
	theNavigationController = [[UINavigationController alloc] initWithRootViewController:newBlogcastController];
	[newBlogcastController release];
	theNavigationController.navigationBar.tintColor = TTSTYLEVAR(navigationBarTintColor);
	[self presentModalViewController:theNavigationController animated:YES];
*/
}


@end
