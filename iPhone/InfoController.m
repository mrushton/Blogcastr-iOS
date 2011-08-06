//
//  InfoController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 6/11/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "InfoController.h"
#import "NSDate+Timestamp.h"
#import "BlogcastrStyleSheet.h"
#import "BlogcastsParser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Timer.h"


@implementation InfoController


@synthesize tabToolbarController;
@synthesize managedObjectContext;
@synthesize session;
@synthesize blogcast;
@synthesize blogcastRequest;
@synthesize timer;

static const CGFloat kGroupedTableViewMargin = 9.0;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
		UIImage *image;
		UITabBarItem *theTabBarItem;

        // Custom initialization.
		image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"info" ofType:@"png"]];
		theTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Info" image:image tag:0];
		self.tabBarItem = theTabBarItem;
		[theTabBarItem release];
		//MVR - updated blogcast notification
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedBlogcast) name:@"updatedBlogcast" object:nil];
	}
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.backgroundColor = TTSTYLEVAR(backgroundColor);
	self.tableView.tableFooterView = [self footerView];
	//MVR - timer
	timer = [[Timer alloc] initWithTimeInterval:TIMER_INTERVAL delegate:self];
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
	if (blogcast.theDescription) {
		CGSize descriptionViewSize;

		descriptionViewSize = [blogcast.theDescription sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(284.0, 100.0) lineBreakMode:UILineBreakModeWordWrap];
		return 62.0 + descriptionViewSize.height;
	} else {
		return 59.0;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	UILabel *label;
	CGFloat usernameWidth;
	//NSDateFormatter *dateFormatter;
	
	// Configure the cell...
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	//MVR - title
	label = [[UILabel alloc] init];
	label.text = blogcast.title;
	label.textColor = [UIColor colorWithRed:0.176 green:0.322 blue:0.408 alpha:1.0];
	label.font = [UIFont boldSystemFontOfSize:18.0];
	label.frame = CGRectMake(18.0, 9.0, 284.0, 22.0);
	[cell addSubview:label];
	[label release];
	//MVR - username
	label = [[UILabel alloc] init];
	label.text = blogcast.user.username;
	label.textColor = [UIColor colorWithRed:0.176 green:0.322 blue:0.408 alpha:1.0];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.frame = CGRectMake(18.0, 33.0, 100.0, 18.0);
	[label sizeToFit];
	usernameWidth = label.bounds.size.width;
	[cell addSubview:label];
	[label release];
	//MVR - starting at
	label = [[UILabel alloc] init];
	/*
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMM d, yyyy h:mm a"];
	label.text = [dateFormatter stringFromDate:blogcast.startingAt];
	[dateFormatter release];
	*/
	label.text = [blogcast.startingAt stringInWords];
	label.textColor = [UIColor colorWithRed:0.32 green:0.32 blue:0.32 alpha:1.0];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.frame = CGRectMake(23.0 + usernameWidth, 33.0, 100.0, 18.0);
	[label sizeToFit];
	[cell addSubview:label];
	[label release];
	//MVR - description
	if (blogcast.description) {
		label = [[UILabel alloc] init];
		label.text = blogcast.theDescription;
		label.font = [UIFont systemFontOfSize:13.0];
		label.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.numberOfLines = 0;
		label.frame = CGRectMake(18.0, 54.0, 284.0, 100.0);
		[label sizeToFit];
		[cell addSubview:label];
		[label release];
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
	[timer invalidate];
	self.timer = nil;
}


- (void)dealloc {
	[managedObjectContext release];
	[session release];
	[blogcast release];
	if (blogcastRequest)
		[blogcastRequest setDelegate:nil];
	[blogcastRequest release];
	[timer invalidate];
	[timer release];
	[_actionSheet release];
	[_progressHud release];
	[_alertView release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (UIActionSheet *)actionSheet {
	if (!_actionSheet)
		_actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this blogcast?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
	
	return _actionSheet;
}

- (MBProgressHUD *)progressHud {
	if (!_progressHud) {
		//MVR - use superview to handle a display bug
		_progressHud = [[MBProgressHUD alloc] initWithView:self.view.superview];
		_progressHud.delegate = self;
	}
	
	return _progressHud;
}

- (UIAlertView *)alertView {
	if (!_alertView) {
		_alertView = [[UIAlertView alloc] init];
		[_alertView addButtonWithTitle:@"Ok"];
	}
	
	return _alertView;
}

#pragma mark -
#pragma mark Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		ASIFormDataRequest *request;
		
		[self showProgressHudWithLabelText:@"Deleting blogcast..." animated:YES animationType:MBProgressHUDAnimationZoom];
		request = [ASIFormDataRequest requestWithURL:[self deleteBlogcastUrl]];
		[request setRequestMethod:@"DELETE"];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(deleteBlogcastFinished:)];
		[request setDidFailSelector:@selector(deleteBlogcastFailed:)];
		[request startAsynchronous];
	}
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)theProgressHUD {
	//MVR - remove HUD from screen when the HUD was hidden
	[theProgressHUD removeFromSuperview];
}

#pragma mark -
#pragma mark ASIHTTPRequest callbacks

- (void)updateBlogcastFinished:(ASIHTTPRequest *)request {
	int statusCode;
	BlogcastsParser *parser;
	
	self.blogcastRequest = nil;
	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Update blogcast received status code %i", statusCode);
		[self errorAlertWithTitle:@"Update failed" message:@"Oops! We couldn't update the blogcast."];
		return;
	}
	//MVR - parse xml
	parser = [[BlogcastsParser alloc] initWithData:[request responseData] managedObjectContext:managedObjectContext];
	if (![parser parse]) {
		NSLog(@"Error parsing update blogcast response");
		[self errorAlertWithTitle:@"Parse error" message:@"Oops! We couldn't update the blogcast."];
		[parser release];
		return;
	}
	[parser release];
	//MVR - reload table and update footer
	[self.tableView reloadData];
	self.tableView.tableFooterView = [self footerView];
	//MVR - update the title of the tab bar controller as well
	self.tabToolbarController.title = blogcast.title;
}

- (void)updateBlogcastFailed:(ASIHTTPRequest *)request {
	NSLog(@"Update blogcast failed");
	[self errorAlertWithTitle:@"Update failed" message:@"Oops! We couldn't update the blogcast."];
	self.blogcastRequest = nil;
}

- (void)deleteBlogcastFinished:(ASIHTTPRequest *)theRequest {
	int statusCode;
	
	//MVR - we need to dismiss the action sheet here for some reason
	if (self.actionSheet.visible)
		[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	statusCode = [theRequest responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error delete blogcast received status code %i", statusCode);
		[self errorAlertWithTitle:@"Delete failed" message:@"Oops! We couldn't delete the blogcast."];
		return;
	}
	[self.managedObjectContext deleteObject:blogcast];
	if (![self save])
		NSLog(@"Error deleting post");
	[self.tabToolbarController.navigationController popViewControllerAnimated:YES];
}

- (void)deleteBlogcastFailed:(ASIHTTPRequest *)theRequest {
	NSError *error;
	
	error = [theRequest error];
	//MVR - we need to dismiss the action sheet here for some reason
	if (self.actionSheet.visible)
		[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Error deleting blogcast: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection failure" message:@"Oops! We couldn't delete the blogcast."];
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Error deleting blogcast: request timed out");
			[self errorAlertWithTitle:@"Request timed out" message:@"Oops! We couldn't delete the blogcast."];
			break;
		case ASIRequestCancelledErrorType:
			NSLog(@"Delete blogcast request cancelled");
			break;
		default:
			NSLog(@"Error deleting blogcast");
			break;
	}	
}

#pragma mark -
#pragma mark Core Data

- (BOOL)save {
	NSError *error;
	
    if (![managedObjectContext save:&error]) {
	    NSLog(@"Error saving managed object context: %@", [error localizedDescription]);
		return FALSE;
	}
	
	return TRUE;
}

#pragma mark -
#pragma mark Actions

- (void)deleteBlogcast {
	[self.actionSheet showInView:self.tabToolbarController.view];
}

- (void)timerExpired:(Timer *)timer {
	if (!blogcastRequest)
		[self updateBlogcast];
}

- (void)updatedBlogcast {
	//AS DESIGNED: issue a new request to update info asap
	if (!blogcastRequest)
		[self updateBlogcast];
}

#pragma mark -
#pragma mark Helpers

- (void)updateBlogcast {
	NSURL *url;
	ASIHTTPRequest *request;
	
	url = [self blogcastUrl];	
	request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(updateBlogcastFinished:)];
	[request setDidFailSelector:@selector(updateBlogcastFailed:)];
	[request startAsynchronous];
	self.blogcastRequest = request;
}

- (TTLabel *)tagLabelFor:(NSString *)name {
	TTStyleSheet *styleSheet;
	TTLabel *label;
	
	styleSheet = [TTStyleSheet globalStyleSheet];
	label = [[[TTLabel alloc] init] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.style = [styleSheet styleWithSelector:@"tag"];
	label.text = name;
	label.font = [UIFont systemFontOfSize:14.0];
	[label sizeToFit];
	
	return label;
}

- (TTView *)currentViewersViewValue:(NSNumber *)value {
	TTStyleSheet *styleSheet;
	TTView *theView;
	UILabel *label;
	
	styleSheet = [TTStyleSheet globalStyleSheet];
	theView = [[[TTView alloc] initWithFrame:CGRectMake(0.0, 0.0, 146.0, 76.0)] autorelease];
	theView.backgroundColor = [UIColor clearColor];
	theView.style = [styleSheet styleWithSelector:@"currentViewers"];
	label = [[UILabel alloc] init];
	label.text = [NSString stringWithFormat:@"%d", [value integerValue]];
	label.font = [UIFont boldSystemFontOfSize:40.0];
	label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor colorWithRed:0.659 green:0.584 blue:0.396 alpha:1.0];
	label.shadowOffset = CGSizeMake(0.0, 1.0);
	label.backgroundColor = [UIColor clearColor];
	[label sizeToFit];
	label.center = CGPointMake(73.0, 28.0);
	[theView addSubview:label];
	[label release];
	label = [[UILabel alloc] init];
	label.text = @"CURRENT VIEWERS";
	label.font = [UIFont boldSystemFontOfSize:10.0];
	label.textColor = [UIColor colorWithRed:0.518 green:0.349 blue:0.012 alpha:1.0];
	label.shadowColor = [UIColor colorWithRed:0.855 green:0.718 blue:0.025 alpha:1.0];
	label.shadowOffset = CGSizeMake(0.0, 1.0);
	label.backgroundColor = [UIColor clearColor];
	[label sizeToFit];
	label.center = CGPointMake(73.0, 56.0);
	[theView addSubview:label];
	[label release];

	return theView;
}

- (TTView *)statViewFor:(NSString *)name value:(NSNumber *)value {
	TTStyleSheet *styleSheet;
	TTView *statView;
	UILabel *statValueLabel;
	UILabel *statNameLabel;
	
	styleSheet = [TTStyleSheet globalStyleSheet];
	statView = [[[TTView alloc] initWithFrame:CGRectMake(0.0, 0.0, 146.0, 36.0)] autorelease];
	statView.backgroundColor = [UIColor clearColor];
	statView.style = [styleSheet styleWithSelector:@"stat"];
	statValueLabel = [[UILabel alloc] init];
	statValueLabel.text = [NSString stringWithFormat:@"%d", [value integerValue]];
	statValueLabel.font = [UIFont boldSystemFontOfSize:15.0];
	statValueLabel.textColor = [UIColor colorWithRed:0.176 green:0.322 blue:0.408 alpha:1.0];
	statValueLabel.backgroundColor = [UIColor clearColor];
	statValueLabel.center = CGPointMake(8.0, 6.0);
	[statValueLabel sizeToFit];
	[statView addSubview:statValueLabel];
	statNameLabel = [[UILabel alloc] init];
	statNameLabel.text = name;
	statNameLabel.font = [UIFont boldSystemFontOfSize:10.0];
	statNameLabel.textColor = [UIColor colorWithRed:0.565 green:0.565 blue:0.565 alpha:1.0];
	statNameLabel.shadowColor = [UIColor whiteColor];
	statNameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	statNameLabel.backgroundColor = [UIColor clearColor];
	statNameLabel.center = CGPointMake(statValueLabel.bounds.size.width + 12.0, 9.0);
	[statNameLabel sizeToFit];
	[statValueLabel release];
	[statView addSubview:statNameLabel];
	[statNameLabel release];
	
	return statView;
}

- (UIView *)footerView {
	TTStyleSheet *styleSheet;
	UIView *footerView;
	CGFloat tagsHeight = 0.0;
	UILabel *label;
	UIView *theView;
	TTButton *deleteBlogcastButton;
	
	styleSheet = [TTStyleSheet globalStyleSheet];
	footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 100.0)] autorelease];
	//MVR - set up tag views
	if (blogcast.tags) {
		NSArray *tagsArray;
		TTLabel *tagLabel;
		CGFloat xOffset = kGroupedTableViewMargin;
		CGFloat yOffset;
		
		label = [[UILabel alloc] init];
		label.text = @"Tags";
		label.font = [UIFont boldSystemFontOfSize:17.0];
		label.textColor = [UIColor colorWithRed:0.298 green:0.337 blue:0.421 alpha:1.0];
		label.shadowColor = [UIColor whiteColor];
		label.shadowOffset = CGSizeMake(0.0, 1.0);
		label.backgroundColor = [UIColor clearColor];
		//MVR - doing this before sizeToFit sets the origin
		label.center = CGPointMake(19.0, 6.0);
		[label sizeToFit];
		yOffset = label.bounds.size.height + 6.0;
		[footerView addSubview:label];
		[label release];
		//MVR - parse comma separated tags
		tagsArray = [blogcast.tags componentsSeparatedByString:@", "];
		for (NSString *tag in tagsArray) {
			tagLabel = [self tagLabelFor:tag];
			if (tagLabel.bounds.size.width > self.tableView.bounds.size.width - xOffset - kGroupedTableViewMargin) {
				yOffset = yOffset + tagLabel.bounds.size.height + 5.0;
				xOffset = kGroupedTableViewMargin;
			}
			tagLabel.center = CGPointMake(xOffset + tagLabel.bounds.size.width / 2.0, yOffset + 5.0 + tagLabel.bounds.size.height / 2.0);
			[footerView addSubview:tagLabel];
			xOffset = xOffset + tagLabel.bounds.size.width + 5.0;
		}
		//MVR - also add the typical offset of the footer view
		tagsHeight = yOffset + tagLabel.bounds.size.height + 10.0;
	}
	//MVR - set up stat views
	label = [[UILabel alloc] init];
	label.text = @"Stats";
	label.font = [UIFont boldSystemFontOfSize:17.0];
	label.textColor = [UIColor colorWithRed:0.298 green:0.337 blue:0.421 alpha:1.0];
	label.shadowColor = [UIColor whiteColor];
	label.shadowOffset = CGSizeMake(0.0, 1.0);
	label.backgroundColor = [UIColor clearColor];
	label.center = CGPointMake(19.0, tagsHeight + 6.0);
	[label sizeToFit];
	[footerView addSubview:label];
	[label release];
	//MVR - current viewers
	theView = [self currentViewersViewValue:blogcast.numCurrentViewers];
	theView.frame = CGRectOffset(theView.frame, kGroupedTableViewMargin, tagsHeight + 36.0);
	[footerView addSubview:theView];
	//MVR - posts
	theView = [self statViewFor:@"POSTS" value:blogcast.numPosts];
	theView.frame = CGRectOffset(theView.frame, 165.0, tagsHeight + 36.0);
	[footerView addSubview:theView];
	//MVR - comments
	theView = [self statViewFor:@"COMMENTS" value:blogcast.numComments];
	theView.frame = CGRectOffset(theView.frame, 165.0, tagsHeight + 76.0);
	[footerView addSubview:theView];
	//MVR - likes
	theView = [self statViewFor:@"LIKES" value:blogcast.numLikes];
	theView.frame = CGRectOffset(theView.frame, kGroupedTableViewMargin, tagsHeight + 116.0);
	[footerView addSubview:theView];
	//MVR - views
	theView = [self statViewFor:@"VIEWS" value:blogcast.numViews];
	theView.frame = CGRectOffset(theView.frame, 165.0, tagsHeight + 116.0);
	[footerView addSubview:theView];
	//MVR - set up delete blogcast button
	deleteBlogcastButton = [TTButton buttonWithStyle:@"redTableFooterButton:" title:@"Delete Blogcast"];
	[deleteBlogcastButton addTarget:self action:@selector(deleteBlogcast) forControlEvents:UIControlEventTouchUpInside];
	//MVR - 30px space
	deleteBlogcastButton.frame = CGRectMake(9.0, tagsHeight + 182.0, 302.0, 45.0);
	[footerView addSubview:deleteBlogcastButton];
	footerView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, tagsHeight + 237.0);
	
	return footerView;
}

- (NSURL *)blogcastUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [[NSString stringWithFormat:@"http://sandbox.blogcastr.com/blogcasts/%d.xml", [blogcast.id integerValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else //DEVEL
	string = [[NSString stringWithFormat:@"http://blogcastr.com/blogcasts/%d.xml", [blogcast.id integerValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#endif //DEVEL
	url = [NSURL URLWithString:string];
	
	return url;
}

- (NSURL *)deleteBlogcastUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [NSString stringWithFormat:@"http://sandbox.blogcastr.com/blogcasts/%d.xml?authentication_token=%@", [blogcast.id integerValue], session.user.authenticationToken];
#else //DEVEL
	string = [NSString stringWithFormat:@"http://blogcastr.com/blogcasts/%d.xml?authentication_token=%@", [blogcast.id integerValue], session.user.authenticationToken];
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

