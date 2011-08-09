    //
//  CommentController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 7/3/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "CommentController.h"
#import "UserController.h"
#import "Blogcast.h"
#import "Comment.h"
#import "Subscription.h"
#import "BlogcastrStyleSheet.h"
#import "ASIFormDataRequest.h"
#import "NSDate+Timestamp.h"


@implementation CommentController

@synthesize managedObjectContext;
@synthesize session;
@synthesize comment;
@synthesize tableView;

static const CGFloat kTableViewSectionWidth = 284.0;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		UIBarButtonItem *postCommentButton;
		
        // Custom initialization.
		//MVR - add bar button item
		postCommentButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(postComment)];
		postCommentButton.title = @"Post";
		self.navigationItem.rightBarButtonItem = postCommentButton;		
		[postCommentButton release];
    }
	
	return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	UITableView *theTableView;
	CGRect frame;
	
    [super viewDidLoad];
	frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
	theTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
	theTableView.backgroundColor = TTSTYLEVAR(backgroundColor);
	theTableView.separatorColor = BLOGCASTRSTYLEVAR(tableViewSeperatorColor);
	theTableView.delegate = self;
	theTableView.dataSource = self;
	theTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:theTableView];
	self.tableView = theTableView;
	[theTableView release];	
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
	self.tableView = nil;
}


- (void)dealloc {
	[tableView release];
	[_progressHud release];
	[_alertView release];
    [super dealloc];
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
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGSize commentTextViewSize;

	commentTextViewSize = [comment.text sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(kTableViewSectionWidth, 100.0) lineBreakMode:UILineBreakModeWordWrap];
	return 57.0 + commentTextViewSize.height + 8.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    // Return the number of sections.
	return 1;
}


- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	NSString *avatarUrl;
	NSString *username;
	TTButton *button;
	UILabel *label;
	
	// Configure the cell...
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	//MVR - save some temporary variables for use later
	if ([[UIScreen mainScreen] scale] > 1.0)
		avatarUrl = [self avatarUrlForUser:comment.user size:@"super"];
	else
		avatarUrl = [self avatarUrlForUser:comment.user size:@"small"];
	NSLog(@"MVR - avatar URL %@",avatarUrl);

	if ([comment.user.type isEqual:@"BlogcastrUser"])
		username = comment.user.username;
	else if ([comment.user.type isEqual:@"FacebookUser"])
		username = comment.user.facebookFullName;
	else if ([comment.user.type isEqual:@"TwitterUser"])
		username = comment.user.twitterUsername;
	//MVR - avatar
	button = [TTButton buttonWithStyle:@"avatar:"];
	button.frame = CGRectMake(18.0, 9.0, 40.0, 40.0);
	[button addTarget:self action:@selector(pressAvatar) forControlEvents:UIControlEventTouchUpInside];
	[button setImage:avatarUrl forState:UIControlStateNormal];
	[cell addSubview:button];
	//MVR - username
	label = [[UILabel alloc] init];
	label.text = username;
	label.textColor = [UIColor colorWithRed:0.176 green:0.322 blue:0.408 alpha:1.0];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.frame = CGRectMake(66.0, 9.0, 100.0, 18.0);
	[label sizeToFit];
	[cell addSubview:label];
	[label release];
	//MVR - created at
	label = [[UILabel alloc] init];
	label.text = [comment.createdAt stringInWords];
	label.textColor = [UIColor colorWithRed:0.32 green:0.32 blue:0.32 alpha:1.0];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.frame = CGRectMake(66.0, 28.0, 100.0, 18.0);
	[label sizeToFit];
	[cell addSubview:label];
	[label release];
	//MVR - text
	label = [[UILabel alloc] init];
	label.text = comment.text;
	label.font = [UIFont systemFontOfSize:13.0];
	label.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
	label.lineBreakMode = UILineBreakModeWordWrap;
	label.numberOfLines = 0;
	label.frame = CGRectMake(18.0, 57.0, kTableViewSectionWidth, 100.0);
	[label sizeToFit];
	[cell addSubview:label];
	
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
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate

- (void)postCommentFinished:(ASIHTTPRequest *)theRequest {
	int statusCode;
	
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	//MVR - enable post button
	self.navigationItem.rightBarButtonItem.enabled = YES;
	statusCode = [theRequest responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error post comment received status code %i", statusCode);
		//MVR - enable delete button
		self.navigationItem.rightBarButtonItem.enabled = YES;
		[self errorAlertWithTitle:@"Post failed" message:@"Oops! We couldn't post the comment."];
		return;
	}
}

- (void)postCommentFailed:(ASIHTTPRequest *)theRequest {
	NSError *error;
	
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	//MVR - enable post button
	self.navigationItem.rightBarButtonItem.enabled = YES;
	error = [theRequest error];
	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Error posting comment: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection failure" message:@"Oops! We couldn't post the comment."];
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Error posting comment: request timed out");
			[self errorAlertWithTitle:@"Request timed out" message:@"Oops! We couldn't post the comment."];
			break;
		case ASIRequestCancelledErrorType:
			NSLog(@"Post comment request cancelled");
			break;
		default:
			NSLog(@"Error posting comment");
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
#pragma mark Actions

- (void)postComment {
	ASIFormDataRequest *request;
	
	//MVR - disable delete button
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[self showProgressHudWithLabelText:@"Posting comment..." animated:YES animationType:MBProgressHUDAnimationZoom];
	request = [ASIFormDataRequest requestWithURL:[self postCommentUrl]];
	[request setRequestMethod:@"POST"];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(postCommentFinished:)];
	[request setDidFailSelector:@selector(postCommentFailed:)];
	[request addPostValue:session.user.authenticationToken forKey:@"authentication_token"];
	//TODO: currently param format isn't standard
	[request addPostValue:comment.id forKey:@"comment_id"];
	[request addPostValue:@"iPhone" forKey:@"from"];
	[request startAsynchronous];
}

- (void)pressAvatar {
	if ([comment.user.type isEqualToString:@"BlogcastrUser"]) {
		UserController *userController;
		
		userController = [[UserController alloc] initWithStyle:UITableViewStyleGrouped];
		userController.managedObjectContext = self.managedObjectContext;
		userController.session = session;
		userController.user = comment.user;
		if (session.user != comment.user) {
			Subscription *subscription;
			
			subscription = [self subscriptionForUser:comment.user];
			userController.subscription = subscription;
			if ([subscription.isSubscribed boolValue])
				userController.navigationItem.rightBarButtonItem = [userController unsubscribeButton];
			else
				userController.navigationItem.rightBarButtonItem = [userController subscribeButton];
		}
		userController.title = comment.user.username;
		[self.navigationController pushViewController:userController animated:YES];
		[userController release];
	} else {
		TTWebController *webController;
		NSString *url;

		if ([comment.user.type isEqualToString:@"FacebookUser"]) {
			url = comment.user.facebookLink;
		} else if ([comment.user.type isEqualToString:@"TwitterUser"]) {
			url = [@"http://twitter.com/" stringByAppendingString:comment.user.twitterUsername];
		} else {
			NSLog(@"Error unknown comment user type");
			return;
		}
		webController = [[TTWebController alloc] init];
		[webController openURL:[NSURL URLWithString:url]];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	}	
}

#pragma mark -
#pragma mark Helpers

- (NSString *)avatarUrlForUser:(User *)user size:(NSString *)size {
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

- (NSURL *)postCommentUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [NSString stringWithFormat:@"http://sandbox.blogcastr.com/blogcasts/%d/comment_posts.xml", [comment.blogcast.id integerValue]];
#else //DEVEL
	string = [NSString stringWithFormat:@"http://blogcastr.com/blogcasts/%d/comment_posts.xml", [comment.blogcast.id integerValue]];
#endif //DEVEL
	url = [NSURL URLWithString:string];
	
	return url;
}

- (Subscription *)subscriptionForUser:(User *)user {
	NSFetchRequest *request;
	NSEntityDescription *entity;
	NSPredicate *predicate;
	NSArray *array;
	Subscription *subscription;
	NSError *error;
	
	//MVR - find subscription if it exists
	request = [[NSFetchRequest alloc] init];
	entity = [NSEntityDescription entityForName:@"Subscription" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	predicate = [NSPredicate predicateWithFormat:@"(subscriber == %@) AND (subscription == %@)", session.user, user];
	[request setPredicate:predicate];
	//MVR - execute the fetch
	array = [managedObjectContext executeFetchRequest:request error:&error];
	//MVR - create subscription if it doesn't exist
	if ([array count] > 0) {
		subscription = [array objectAtIndex:0];
	} else {
		subscription = [NSEntityDescription insertNewObjectForEntityForName:@"Subscription" inManagedObjectContext:managedObjectContext];
		subscription.subscriber = session.user;
		subscription.subscription = user;
		subscription.isSubscribed = [NSNumber numberWithBool:NO];
	}
	[request release];
	
	return subscription;	
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
