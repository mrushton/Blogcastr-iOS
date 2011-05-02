    //
//  PostsController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/30/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "PostsController.h"
#import "NewTextPostController.h"


@implementation PostsController

@synthesize tabToolbarController;
@synthesize managedObjectContext;
@synthesize session;
@synthesize blogcast;

static const CGFloat kPostBarViewHeight = 40.0;

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	TTView *topBar;
	TTButton *newTextPostButton;
	TTButton *newImagePostButton;
	TTStyleSheet *styleSheet;
	TTStyle *style;
	
	[super viewDidLoad];
	topBar = [[TTView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, kPostBarViewHeight)];
	styleSheet = [TTStyleSheet globalStyleSheet];
	style = [styleSheet styleWithSelector:@"topBar" forState:UIControlStateNormal];
	topBar.style = style;
	//MVR - set up the post buttons
	newTextPostButton = [TTButton buttonWithStyle:@"blueButtonWithImage:" title:@"New Text Post"];
	//MVR - image url based on screen resolution
	//if ([[UIScreen mainScreen] scale] > 1.0)
	//[textPostButton setImage:@"bundle://logo~iphone.png" forState:UIControlStateNormal];
	[newTextPostButton addTarget:self action:@selector(newTextPost:) forControlEvents:UIControlEventTouchUpInside]; 
	newTextPostButton.frame = CGRectMake(5.0, 6.0, 150.0, 28.0);
	[topBar addSubview:newTextPostButton];
	newImagePostButton = [TTButton buttonWithStyle:@"orangeButtonWithImage:" title:@"New Image Post"];
	//MVR - image url based on screen resolution
	//if ([[UIScreen mainScreen] scale] > 1.0)
	//[textPostButton setImage:@"bundle://logo~iphone.png" forState:UIControlStateNormal];
	[newImagePostButton addTarget:self action:@selector(newImagePost:) forControlEvents:UIControlEventTouchUpInside]; 
	newImagePostButton.frame = CGRectMake(165.0, 6.0, 150.0, 28.0);
	[topBar addSubview:newImagePostButton];
	[self.view addSubview:topBar];
	[topBar release];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (void)newTextPost:(id)object {
	UINavigationController *theNavigationController;
	NewTextPostController *newTextPostController;

	newTextPostController = [[NewTextPostController alloc] initWithStyle:UITableViewStyleGrouped];
	newTextPostController.managedObjectContext = managedObjectContext;
	newTextPostController.session = session;
	newTextPostController.blogcast = blogcast;
	theNavigationController = [[UINavigationController alloc] initWithRootViewController:newTextPostController];
	[newTextPostController release];
	theNavigationController.navigationBar.tintColor = TTSTYLEVAR(navigationBarTintColor);
	[self.tabToolbarController presentModalViewController:theNavigationController animated:YES];
}
	

@end
