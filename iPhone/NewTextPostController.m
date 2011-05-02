//
//  NewTextPostController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 5/1/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "NewTextPostController.h"
#import "ASIFormDataRequest.h"
#import "BlogcastrStyleSheet.h"


@implementation NewTextPostController


@synthesize managedObjectContext;
@synthesize session;
@synthesize blogcast;
@synthesize textView;
@synthesize progressHud;
@synthesize alertView;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
		UIBarButtonItem *cancelButton;
		UIBarButtonItem *postButton;
        
		// Custom initialization.
		self.navigationItem.title = @"New Text Post";
		cancelButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
		cancelButton.title = @"Cancel";
		self.navigationItem.leftBarButtonItem = cancelButton;
		[cancelButton release];
		postButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(post)];
		postButton.title = @"Post";
		self.navigationItem.rightBarButtonItem = postButton;
		[postButton release];
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	UITextView *theTextView;
	
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.backgroundColor = TTSTYLEVAR(backgroundColor);
	theTextView = [[UITextView alloc] initWithFrame:CGRectMake(2.0, 4.0, 296.0, 92.0)];
	//MVR - slight hack with insets to make the top align a little nicer
	theTextView.contentInset = UIEdgeInsetsMake(-4.0, 0.0, 0.0, 0.0);
	theTextView.backgroundColor = [UIColor clearColor];	
	theTextView.font = [UIFont systemFontOfSize:15.0];
	theTextView.textColor = BLOGCASTRSTYLEVAR(blueTextColor);
	self.textView = theTextView;
	[theTextView release];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0)
		return 100.0;
	
	return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;

	// Configure the cell...

	//AS DESIGNED: only a few cells no need to make them reusable
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
	if (indexPath.section == 0) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell.contentView addSubview:textView];
	}

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0)
		return @"Text";
	
	return nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.textView = nil;
}

- (UIAlertView *)alertView {
	if (!_alertView) {
		_alertView = [[UIAlertView alloc] init];
		[_alertView addButtonWithTitle:@"Ok"];
	}
	
	return _alertView;
}

- (MBProgressHUD *)progressHud {
	if (!_progressHud) {
		//MVR - use superview to handle a display bug
		_progressHud = [[MBProgressHUD alloc] initWithView:self.view.superview];
		_progressHud.delegate = self;
	}
	
	return _progressHud;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate

- (void)newTextPostFinished:(ASIHTTPRequest *)request {
	NSLog(@"MVR - new blogcast finished");
}


- (void)newTextPostFailed:(ASIHTTPRequest *)request {
	NSLog(@"MVR - new blogcast failed");
	
}

#pragma mark -
#pragma mark Actions

- (void)post {
	NSString *string;
	NSURL *url;
	ASIFormDataRequest *request;
	
	//MVR - check for errors
	if (!textView.text || [textView.text compare:@""] == NSOrderedSame) {
		[self errorAlertWithTitle:@"Empty post" message:@"Oops! You need to enter some text."];
		return;
	}
	//MVR - dismiss keyboard
	[textView resignFirstResponder];
	[self showProgressHudWithLabelText:@"Posting text..." animated:YES animationType:MBProgressHUDAnimationZoom];
	request = [ASIFormDataRequest requestWithURL:[self newTextPostUrl]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(newTextPostFinished:)];
	[request setDidFailSelector:@selector(newTextPostFailed:)];
	[request addPostValue:session.authenticationToken forKey:@"authentication_token"];
	[request addPostValue:textView.text forKey:@"text_post[text]"];
	[request addPostValue:@"iPhone" forKey:@"text_post[from]"];
	[request startAsynchronous];
}

- (void)cancel {
	//TODO: need to cancel request as well
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Helpers

- (NSURL *)newTextPostUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [NSString stringWithFormat:@"http://sandbox.blogcastr.com/blogcasts/%d/text_posts.xml", [blogcast.id intValue]];
#else //DEVEL
	string = [NSString stringWithFormat:@"http:/blogcastr.com/blogcasts/%d/text_posts.xml", [blogcast.id intValue]];
#endif //DEVEL
	url = [NSURL URLWithString:string];
	
	return url;
}

- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType {
	self.progressHud.labelText = labelText;
	if (animated)
		self.progressHud.animationType = animationType;
	//MVR - use superview to handle a display bug
	[self.view.superview addSubview:self.progressHud];
	[self.progressHud show:animated];
}

- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message {
	//MVR - update and display the alert view
	self.alertView.title = title;
	self.alertView.message = message;
	[self.alertView show];
}

@end

