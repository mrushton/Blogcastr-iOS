    //
//  DashboardController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/30/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "DashboardController.h"
#import "EditBlogcastController.h"


@implementation DashboardController

@synthesize managedObjectContext;
@synthesize session;
@synthesize blogcast;
@synthesize xmppStream;
@synthesize xmppRoom;

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
	[managedObjectContext release];
	[session release];
	[blogcast release];
	[xmppStream removeDelegate:self];
	[xmppStream release];
	//MVR - leaves room when it gets dealloced
	[xmppRoom release];
    [super dealloc];
}

#pragma mark -
#pragma mark XMPPStream delegate

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
	//MVR - reconnect every time we authenticate
	[self connect];
}

#pragma mark -
#pragma mark XMPPRoom delegate

- (void)xmppRoom:(XMPPRoom *)room didEnter:(BOOL)enter {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"joinedRoom" object:self];
}

- (void)xmppRoom:(XMPPRoom *)room didLeave:(BOOL)leave {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"leftRoom" object:self];
}

#pragma mark -
#pragma mark Actions

- (void)editBlogcast {
	UINavigationController *theNavigationController;
	EditBlogcastController *editBlogcastController;
	
	editBlogcastController = [[EditBlogcastController alloc] initWithStyle:UITableViewStyleGrouped];
	editBlogcastController.managedObjectContext = managedObjectContext;
	editBlogcastController.session = session;
	editBlogcastController.blogcast = blogcast;
	theNavigationController = [[UINavigationController alloc] initWithRootViewController:editBlogcastController];
	[editBlogcastController release];
	theNavigationController.navigationBar.tintColor = TTSTYLEVAR(navigationBarTintColor);
	[self presentModalViewController:theNavigationController animated:YES];
}

#pragma mark -
#pragma mark Helpers

- (BOOL)connect {
	[xmppRoom createOrJoinRoom];

	return YES;
}


@end
