//
//  UserController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 3/5/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "UserController.h"
#import "ImageViewerController.h"
#import "ASIFormDataRequest.h"
#import "UserParser.h"


@implementation UserController


@synthesize managedObjectContext;
@synthesize session;
@synthesize facebook;
@synthesize user;
@synthesize subscription;
@synthesize tabToolbarController;
@synthesize request;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
        //MVR - Twitter notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedSettings) name:@"updatedSettings" object:nil];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	//MVR - loading hud handles case of missing user info
	if (!user.updatedAt && !isLoading) {
		isLoading = YES;
		isUpdating = YES;
		//MVR - show progress HUD for loading
		[self showViewProgressHudWithLabelText:@"Loading..." animated:YES animationType:MBProgressHUDAnimationZoom];
		//MVR - disable subscribe button as well
		self.navigationItem.rightBarButtonItem.enabled = NO;
		[self updateUser];
	} else if ((!subscription.updatedAt || [subscription.updatedAt timeIntervalSinceNow] < -86400.0 || [user.updatedAt timeIntervalSinceNow] < -86400.0) && !isUpdating) {
		//MVR - update user info if it's been longer than a day
		isUpdating = YES;
		[self updateUser];
	}
}

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
	NSInteger numSections = 1;

	// Return the number of sections.
	if (user.web || (user.facebookFullName && user.facebookLink) || user.twitterUsername)
		numSections++;
	if (user.bio)
		numSections++;

	return numSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ((!user.bio && section == 1) || section == 2) {
        NSInteger numRows = 0;

        if (user.web)
            numRows++;
        if (user.facebookFullName && user.facebookLink)
            numRows++;
        if (user.twitterUsername)
            numRows++;

        return numRows;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0){
		return 86.0;
	} else if (indexPath.section == 1 && user.bio) {
        CGSize size;
		
		size = [user.bio sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(284.0, 100.0) lineBreakMode:UILineBreakModeWordWrap];
		return size.height + 17.0;         
    } else if ((indexPath.section == 1 && !user.bio) || indexPath.section == 2) {
        return 44.0;
    }

	return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
	
    // Configure the cell...
	if (indexPath.section == 0) {
		CGRect rect;
		UILabel *label;

		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		TTButton *avatarButton = [TTButton buttonWithStyle:@"roundedAvatar:"];
		rect = CGRectMake(18.0, 9.0, 69.0, 69.0);
		avatarButton.frame = rect;
		[avatarButton addTarget:self action:@selector(pressAvatar:) forControlEvents:UIControlEventTouchUpInside];
		//MVR - image url based on screen resolution
		if ([[UIScreen mainScreen] scale] > 1.0)
			[avatarButton setImage:[self avatarUrlForSize:@"super"] forState:UIControlStateNormal];
		else
			[avatarButton setImage:[self avatarUrlForSize:@"large"] forState:UIControlStateNormal];
		[cell addSubview:avatarButton];
		rect = CGRectMake(95.0, 14.0, 207.0, 22.0);
		label = [[UILabel alloc] initWithFrame:rect];
		label.text = user.fullName;
		label.textColor = [UIColor colorWithRed:0.176 green:0.322 blue:0.408 alpha:1.0];
        label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:18.0];
		[cell addSubview:label];
		[label release];
		if (user.location) {
			rect = CGRectMake(95.0, 38.0, 207.0, 18.0);
			label = [[UILabel alloc] initWithFrame:rect];
			label.text = user.location;
			label.textColor = [UIColor colorWithRed:0.32 green:0.32 blue:0.32 alpha:1.0];
            label.backgroundColor = [UIColor clearColor];
			label.font = [UIFont boldSystemFontOfSize:14.0];
			[cell addSubview:label];
			[label release];
		}
	} else if (indexPath.section == 1 && user.bio) {
        CGRect rect;
		UILabel *label;
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		rect = CGRectMake(18.0, 9.0, 284.0, 100.0);
		label = [[UILabel alloc] initWithFrame:rect];
		label.text = user.bio;
		label.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont systemFontOfSize:13.0];
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.numberOfLines = 0;
		[label sizeToFit];
		[cell addSubview:label];
    } else if (indexPath.section == 1 || indexPath.section == 2) {    
        if (indexPath.row == 0 && user.web) {        
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
            cell.textLabel.text = @"Web";
            cell.detailTextLabel.text = user.web;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if ((indexPath.row == 0 || (indexPath.row == 1 && user.web)) && user.facebookFullName && user.facebookLink) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
            cell.textLabel.text = @"Facebook";
            cell.detailTextLabel.text = user.facebookFullName;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;            
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
            cell.textLabel.text = @"Twitter";
            cell.detailTextLabel.text = user.twitterUsername;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;        
        }
	}

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 1 && user.bio)
		return @"Bio";

	return nil;
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
	if ((indexPath.section == 1 && !user.bio) || indexPath.section == 2) {
		TTWebController *webController;
        NSString *url;
        
		webController = [[TTWebController alloc] init];
        if (indexPath.row == 0 && user.web)     
            url = user.web;
        else if ((indexPath.row == 0 || (indexPath.row == 1 && user.web)) && user.facebookFullName && user.facebookLink)
            url = user.facebookLink;
        else
            url = [NSString stringWithFormat:@"http://twitter.com/%@", user.twitterUsername];
        [webController openURL:[NSURL URLWithString:url]];
		//MVR - controller can be part of tab toolbar controller
		if (tabToolbarController)
			[self.tabToolbarController.navigationController pushViewController:webController animated:YES];
		else
			[self.navigationController pushViewController:webController animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
}


- (void)dealloc {
	[_subscribeButton release];
	[_unsubscribeButton release];
    _viewProgressHud.delegate = nil;
	[_viewProgressHud release];
    _windowProgressHud.delegate = nil;
	[_windowProgressHud release];
	[_alertView release];
    [super dealloc];
}

- (UIBarButtonItem *)subscribeButton {
	if (!_subscribeButton) {
		_subscribeButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(subscribe)];
		_subscribeButton.title = @"Subscribe";
	}
	
	return _subscribeButton;
}

- (UIBarButtonItem *)unsubscribeButton {
	if (!_unsubscribeButton) {
		_unsubscribeButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(unsubscribe)];
		_unsubscribeButton.title = @"Unsubscribe";
	}
	
	return _unsubscribeButton;
}

- (MBProgressHUD *)viewProgressHud {
	if (!_viewProgressHud) {
		//MVR - use window to allow no navigation back
		_viewProgressHud = [[MBProgressHUD alloc] initWithView:self.view];
		_viewProgressHud.delegate = self;
	}
	
	return _viewProgressHud;
}

- (MBProgressHUD *)windowProgressHud {
	if (!_windowProgressHud) {
		//MVR - use view to allow navigation back
		_windowProgressHud = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
		_windowProgressHud.delegate = self;
	}
	
	return _windowProgressHud;
}

- (UIAlertView *)alertView {
	if (!_alertView) {
		_alertView = [[UIAlertView alloc] init];
		[_alertView addButtonWithTitle:@"Ok"];
	}
	
	return _alertView;
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate

- (void)updateUserFinished:(ASIHTTPRequest *)theRequest {
	int statusCode;
	UserParser *parser;
	
	isUpdating = NO;
	if (isLoading) {
		isLoading = NO;
		//MVR - hide the loading progress HUD
		[self.viewProgressHud hide:YES];
	}
	//MVR - enable the subscribe button
	self.navigationItem.rightBarButtonItem.enabled = YES;
	statusCode = [theRequest responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error update user received status code %i", statusCode);
		[self errorAlertWithTitle:@"Update Failed" message:@"Oops! We couldn't update the user."];
		return;
	}
	//MVR - parse xml
	parser = [[UserParser alloc] init];
	parser.managedObjectContext = managedObjectContext;
	parser.data = [theRequest responseData];
	parser.subscription = subscription;
	if (![parser parse]) {
		NSLog(@"Error parsing update user response");
		[self errorAlertWithTitle:@"Parse Error" message:@"Oops! We couldn't update the user."];
		[parser release];
		return;
	}
	user.updatedAt = [NSDate date];
	subscription.updatedAt = [NSDate date];
	if (![self save])
		NSLog(@"Save error updating user");
	//MVR - reload everything after the update
	[self.tableView reloadData];
	self.tableView.tableFooterView = [self footerView];
	//MVR - update the navigation button
	if (subscription) {
		if ([subscription.isSubscribed boolValue])
			self.navigationItem.rightBarButtonItem = [self unsubscribeButton];
		else
			self.navigationItem.rightBarButtonItem = [self subscribeButton];
	}
}

- (void)subscribeFinished:(ASIHTTPRequest *)theRequest {
	int statusCode;
	
	//MVR - hide the subscription progress HUD
	[self.windowProgressHud hide:YES];
	//MVR - enable subscribe button
	self.navigationItem.rightBarButtonItem.enabled = YES;
	statusCode = [theRequest responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error subscribe received status code %i", statusCode);
		[self errorAlertWithTitle:@"Subscribe Failed" message:@"Oops! We couldn't subscribe you."];
		return;
	}
	//MVR - set subscribed and updatedAt to now
	subscription.isSubscribed = [NSNumber numberWithBool:YES];
	subscription.updatedAt = [NSDate date];
	if (![self save])
		NSLog(@"Save error subscribing");
	//MVR - set the button to unsubscribe
	self.navigationItem.rightBarButtonItem = [self unsubscribeButton];
}

- (void)subscribeFailed:(ASIHTTPRequest *)theRequest {
	NSError *error;
	
	error = [theRequest error];
	//MVR - hide the subscription progress HUD
	[self.windowProgressHud hide:YES];
	//MVR - enable subscribe button
	self.navigationItem.rightBarButtonItem.enabled = YES;
	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Error subscribing: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection Failure" message:@"Oops! We couldn't subscribe you."];
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Error subscribing: request timed out");
			[self errorAlertWithTitle:@"Request Timed Out" message:@"Oops! We couldn't subscribe you."];
			break;
		case ASIRequestCancelledErrorType:
			NSLog(@"Subscibe request cancelled");
			break;
		default:
			NSLog(@"Error subscribing");
			break;
	}	
}

- (void)unsubscribeFinished:(ASIHTTPRequest *)theRequest {
	int statusCode;
	
	//MVR - hide the subscription progress HUD
	[self.windowProgressHud hide:YES];
	//MVR - enable unsubscribe button
	self.navigationItem.rightBarButtonItem.enabled = YES;
	statusCode = [theRequest responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error subscribe received status code %i", statusCode);
		[self errorAlertWithTitle:@"Unsubscribe Failed" message:@"Oops! We couldn't unsubscribe you."];
		return;
	}
	//MVR - set subscribed and updatedAt to now
	subscription.isSubscribed = [NSNumber numberWithBool:NO];
	subscription.updatedAt = [NSDate date];
	if (![self save])
		NSLog(@"Save error unsubscribing");
	//MVR - set the button to subscribe
	self.navigationItem.rightBarButtonItem = [self subscribeButton];
}

- (void)unsubscribeFailed:(ASIHTTPRequest *)theRequest {
	NSError *error;
	
	error = [theRequest error];
	//MVR - hide the subscription progress HUD
	[self.windowProgressHud hide:YES];
	//MVR - enable unsubscribe button
	self.navigationItem.rightBarButtonItem.enabled = YES;
	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Error unsubscribing: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection Failure" message:@"Oops! We couldn't unsubscribe you."];
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Error unsubscribing: request timed out");
			[self errorAlertWithTitle:@"Request Timed Out" message:@"Oops! We couldn't unsubscribe you."];
			break;
		case ASIRequestCancelledErrorType:
			NSLog(@"Unsubscibe request cancelled");
			break;
		default:
			NSLog(@"Error unsubscribing");
			break;
	}
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)theProgressHUD {
	//MVR - remove HUD from screen when the HUD was hidden
	[theProgressHUD removeFromSuperview];
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

- (void)subscribe {
	ASIFormDataRequest *theRequest;
	
	//MVR - disable subscribe button
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[self showWindowProgressHudWithLabelText:@"Subscribing..." animated:YES animationType:MBProgressHUDAnimationZoom];
	theRequest = [ASIFormDataRequest requestWithURL:[self subscribeUrl]];
	[theRequest setRequestMethod:@"POST"];
	[theRequest setDelegate:self];
	[theRequest setDidFinishSelector:@selector(subscribeFinished:)];
	[theRequest setDidFailSelector:@selector(subscribeFailed:)];
	[theRequest addPostValue:session.user.authenticationToken forKey:@"authentication_token"];
	[theRequest startAsynchronous];
}

- (void)unsubscribe {
	ASIFormDataRequest *theRequest;
	
	//MVR - disable subscribe button
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[self showWindowProgressHudWithLabelText:@"Unsubscribing..." animated:YES animationType:MBProgressHUDAnimationZoom];
	theRequest = [ASIFormDataRequest requestWithURL:[self unsubscribeUrl]];
	[theRequest setRequestMethod:@"DELETE"];
	[theRequest setDelegate:self];
	[theRequest setDidFinishSelector:@selector(unsubscribeFinished:)];
	[theRequest setDidFailSelector:@selector(unsubscribeFailed:)];
	[theRequest startAsynchronous];
}

- (void)pressAvatar:(id)object {
	ImageViewerController *imageViewerController;
	
	imageViewerController = [[ImageViewerController alloc] initWithNibName:nil bundle:nil];
	imageViewerController.imageUrl = [self avatarUrlForSize:@"original"];
	//MVR - controller can be part of tab toolbar controller
	if (tabToolbarController)
		[self.tabToolbarController.navigationController pushViewController:imageViewerController animated:YES];
	else
		[self.navigationController pushViewController:imageViewerController animated:YES];
	[imageViewerController release];
}

- (void)updatedSettings {
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Helpers

- (void)updateUser {
	ASIFormDataRequest *theRequest;
	
	theRequest = [ASIFormDataRequest requestWithURL:[self userUrl]];
	[theRequest setDelegate:self];
	[theRequest setDidFinishSelector:@selector(updateUserFinished:)];
	[theRequest setDidFailSelector:@selector(updateUserFailed:)];
	[theRequest startAsynchronous];
	self.request = theRequest;
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
	statValueLabel.text = [NSString stringWithFormat:@"%d", [value intValue]];
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
	UILabel *statsLabel;
	TTView *statView;
	
	styleSheet = [TTStyleSheet globalStyleSheet];
	footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 161.0)] autorelease];
	//MVR - set up stat views
	statsLabel = [[UILabel alloc] init];
	statsLabel.text = @"Stats";
	statsLabel.font = [UIFont boldSystemFontOfSize:17.0];
	statsLabel.textColor = [UIColor colorWithRed:0.298 green:0.337 blue:0.421 alpha:1.0];
	statsLabel.shadowColor = [UIColor whiteColor];
	statsLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	statsLabel.backgroundColor = [UIColor clearColor];
	statsLabel.center = CGPointMake(19.0, 6.0);
	[statsLabel sizeToFit];
	[footerView addSubview:statsLabel];
	[statsLabel release];
	//MVR - blogcasts
	if ([user.numBlogcasts intValue] == 1)
		statView = [self statViewFor:@"BLOGCAST" value:user.numBlogcasts];
	else
		statView = [self statViewFor:@"BLOGCASTS" value:user.numBlogcasts];
	statView.frame = CGRectOffset(statView.frame, 9.0, 36.0);
	[footerView addSubview:statView];
	//MVR - subscriptions
	if ([user.numSubscriptions intValue] == 1)
		statView = [self statViewFor:@"SUBSCRIPTION" value:user.numSubscriptions];
	else
		statView = [self statViewFor:@"SUBSCRIPTIONS" value:user.numSubscriptions];
	statView.frame = CGRectOffset(statView.frame, 165.0, 36.0);
	[footerView addSubview:statView];
	//MVR - subscribers
	if ([user.numSubscribers intValue] == 1)
		statView = [self statViewFor:@"SUBSCRIBER" value:user.numSubscribers];
	else
		statView = [self statViewFor:@"SUBSCRIBERS" value:user.numSubscribers];
	statView.frame = CGRectOffset(statView.frame, 9.0, 76.0);
	[footerView addSubview:statView];
	//MVR - posts
	if ([user.numPosts intValue] == 1)
		statView = [self statViewFor:@"POST" value:user.numPosts];
	else
		statView = [self statViewFor:@"POSTS" value:user.numPosts];
	statView.frame = CGRectOffset(statView.frame, 165.0, 76.0);
	[footerView addSubview:statView];
	//MVR - comments
	if ([user.numComments intValue] == 1)
		statView = [self statViewFor:@"COMMENT" value:user.numComments];
	else
		statView = [self statViewFor:@"COMMENTS" value:user.numComments];
	statView.frame = CGRectOffset(statView.frame, 9.0, 116.0);
	[footerView addSubview:statView];
	//MVR - likes
	if ([user.numLikes intValue] == 1)
		statView = [self statViewFor:@"LIKE" value:user.numLikes];
	else
		statView = [self statViewFor:@"LIKES" value:user.numLikes];
	statView.frame = CGRectOffset(statView.frame, 165.0, 116.0);
	[footerView addSubview:statView];
	
	return footerView;
}

- (NSString *)avatarUrlForSize:(NSString *)size {
	NSString *avatarUrl;
	NSRange range;
	
#ifdef DEVEL
	avatarUrl = [NSString stringWithFormat:@"http://sandbox.blogcastr.com%@", user.avatarUrl];
#else //DEVEL
	avatarUrl = [[user.avatarUrl copy] autorelease];
#endif //DEVEL
	range = [avatarUrl rangeOfString:@"original"];
	if (range.location != NSNotFound) {
		return [avatarUrl stringByReplacingCharactersInRange:range withString:size];
	} else {
		NSLog(@"Error replacing size in avatar url: %@", avatarUrl);
		return avatarUrl;
	}
}

- (NSURL *)userUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [NSString stringWithFormat:@"http://sandbox.blogcastr.com/users/%d.xml?authentication_token=%@", [user.id intValue], session.user.authenticationToken];
#else //DEVEL
	string = [NSString stringWithFormat:@"http://blogcastr.com/users/%d.xml?authentication_token=%@", [user.id intValue], session.user.authenticationToken];
#endif //DEVEL
	url = [NSURL URLWithString:string];
	
	return url;
}

- (NSURL *)subscribeUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [NSString stringWithFormat:@"http://sandbox.blogcastr.com/users/%d/subscriptions.xml", [user.id intValue]];
#else //DEVEL
	string = [NSString stringWithFormat:@"http://blogcastr.com/users/%d/subscriptions.xml", [user.id intValue]];
#endif //DEVEL
	url = [NSURL URLWithString:string];
	
	return url;
}

- (NSURL *)unsubscribeUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [NSString stringWithFormat:@"http://sandbox.blogcastr.com/users/%d/subscriptions.xml?authentication_token=%@", [user.id intValue], session.user.authenticationToken];
#else //DEVEL
	string = [NSString stringWithFormat:@"http://blogcastr.com/users/%d/subscriptions.xml?authentication_token=%@", [user.id intValue], session.user.authenticationToken];
#endif //DEVEL
	url = [NSURL URLWithString:string];
	
	return url;
}

- (void)showViewProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType {
	self.viewProgressHud.labelText = labelText;
	if (animated)
		self.viewProgressHud.animationType = animationType;
	//MVR - use superview to handle a display bug
	[self.view.superview addSubview:self.viewProgressHud];
	[self.viewProgressHud show:animated];
}

- (void)showWindowProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType {
	self.windowProgressHud.labelText = labelText;
	if (animated)
		self.windowProgressHud.animationType = animationType;
	[[[UIApplication sharedApplication] keyWindow] addSubview:self.windowProgressHud];
	[self.windowProgressHud show:animated];
}

- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message {
	//MVR - update and display the alert view
	self.alertView.title = title;
	self.alertView.message = message;
	[self.alertView show];
}

@end

