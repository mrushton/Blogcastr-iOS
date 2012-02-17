//
//  HomeController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 2/26/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "HomeController.h"
#import "BlogcastrStyleSheet.h"
#import "NewBlogcastController.h"
#import "XMPPStream.h"
#import "XMPPReconnect.h"
#import "XMPPJID.h"


@implementation HomeController

@synthesize managedObjectContext;
@synthesize session;
@synthesize facebook;
@synthesize xmppStream;
@synthesize xmppReconnect;

- (id)init {
	self = [super init];
	if (self) {
		UIBarButtonItem *newBlogcastButton;
		XMPPStream *theXmppStream;
		XMPPReconnect *theXmppReconnect;
		
		//MVR - add bar button item
		newBlogcastButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(newBlogcast)];
		newBlogcastButton.title = @"New";
		self.navigationItem.rightBarButtonItem = newBlogcastButton;		
		[newBlogcastButton release];
		theXmppStream = [[XMPPStream alloc] init];
		//MVR - use ping instead of keep alive
		theXmppStream.keepAliveInterval = 0.0;
		[theXmppStream addDelegate:self];
		self.xmppStream = theXmppStream;
		[theXmppStream release];
		theXmppReconnect = [[XMPPReconnect alloc] initWithStream:xmppStream];
		theXmppReconnect.pingInterval = 60.0;
		self.xmppReconnect = theXmppReconnect;
		[theXmppReconnect release];
		didAuthenticate = NO;
		wasToldToDisconnect = NO;
		//MVR - sign out notification
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signOut) name:@"signOut" object:nil];
	}
	
	return self;
}

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
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

/*
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
*/

- (void)dealloc {
	[xmppStream release];
	[xmppReconnect release];
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
#pragma mark XMPPStream delegate

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
	NSError *error = nil;
	
	wasToldToDisconnect = NO;
	if (![xmppStream authenticateWithPassword:session.user.password error:&error])
		NSLog(@"Error trying to authenticate with XMPP server: %@", error);
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
	didAuthenticate = YES;
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
	NSLog(@"Error authentication failed with XMPP server");
	//MVR - the password may have changed so give a warning
	[self errorAlertWithTitle:@"Authentication Failed" message:@"Oops! We couldn't connect to our server. You may want to sign out and try again."];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error {
	if ([error isKindOfClass:[NSError class]]) {
		NSLog(@"Received TCP error: %@",[error localizedDescription]);
	} else if ([error isKindOfClass:[NSXMLElement class]]) {
		NSLog(@"Received XMPP error");
		[self errorAlertWithTitle:@"Server Error" message:@"Oops! We received an error from the server."];
	}
}

- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender {
	//MVR - happens after signing out
	wasToldToDisconnect = YES;
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender {
	//MVR - do manual start if we haven't connected yet and didn't sign out
	if (didAuthenticate == NO && wasToldToDisconnect == NO)
		[xmppReconnect manualStart];
}

#pragma mark -
#pragma mark Actions

- (void)newBlogcast {
	UINavigationController *theNavigationController;
	NewBlogcastController *newBlogcastController;
	
	newBlogcastController = [[NewBlogcastController alloc] initWithStyle:UITableViewStyleGrouped];
	newBlogcastController.managedObjectContext = managedObjectContext;
	newBlogcastController.session = session;
    newBlogcastController.facebook = facebook;
	theNavigationController = [[UINavigationController alloc] initWithRootViewController:newBlogcastController];
	[newBlogcastController release];
	theNavigationController.navigationBar.tintColor = TTSTYLEVAR(navigationBarTintColor);
	[self presentModalViewController:theNavigationController animated:YES];
}

- (void)signOut {
	[self disconnect];
}

#pragma mark -
#pragma mark Helpers

- (BOOL)connect {
	NSError *error = nil;

#ifdef DEVEL
	xmppStream.myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@sandbox.blogcastr.com/dashboard", session.user.username]];
	xmppStream.hostName = @"sandbox.blogcastr.com";
#else //DEVEL
	xmppStream.myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@blogcastr.com/dashboard", session.user.username]];
	xmppStream.hostName = @"ejabberd.blogcastr.com";
#endif //DEVEL
	if (![xmppStream connect:&error]) {
		NSLog(@"Error connecting to XMPP server: %@", error);
		return FALSE;
	}
	
	return TRUE;
}

- (void)disconnect {
	//AS DESIGNED: the reconnect object will be stopped when disconnecting
	[xmppStream disconnect];
}

- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message {
	//MVR - update and display the alert view
	self.alertView.title = title;
	self.alertView.message = message;
	[self.alertView show];
}

@end
