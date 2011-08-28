    //
//  PostController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 6/18/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "PostController.h"
#import "UserController.h"
#import "ImageViewerController.h"
#import "Post.h"
#import "Comment.h"
#import "BlogcastrStyleSheet.h"
#import "ASIFormDataRequest.h"
#import "NSDate+Timestamp.h"
#import "UINavigationBar+ButtonColor.h"


@implementation PostController

@synthesize managedObjectContext;
@synthesize session;
@synthesize post;
@synthesize tableView;

static const CGFloat kTableViewSectionWidth = 284.0;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		UIBarButtonItem *deletePostButton;

        // Custom initialization.
		//MVR - add bar button item
		deletePostButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(deletePost)];
		deletePostButton.title = @"Delete";
		self.navigationItem.rightBarButtonItem = deletePostButton;		
		[deletePostButton release];
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
- (void)viewDidAppear:(BOOL)animated {
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
	self.tableView = nil;
}


- (void)dealloc {
	[tableView release];
	[_actionSheet release];
	[_alertView release];
    [super dealloc];
}

- (UIActionSheet *)actionSheet {
	if (!_actionSheet)
		_actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this post?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
	
	return _actionSheet;
}

- (MBProgressHUD *)progressHud {
	if (!_progressHud) {
		_progressHud = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
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
	CGFloat textOffset = 0.0;
	NSString *postText;

	if ([post.type isEqual:@"ImagePost"]) {
		CGFloat imageHeight;

		if ([post.imageWidth integerValue] > kTableViewSectionWidth)
			imageHeight = roundf(kTableViewSectionWidth * [post.imageHeight integerValue] / [post.imageWidth integerValue]); 
		else
			imageHeight = [post.imageHeight integerValue];
		textOffset = imageHeight + 8.0;
	}
	//MVR - text
	if ([post.type isEqual:@"CommentPost"])
		postText = post.comment.text;
	else
		postText = post.text;
	if (postText) {
		CGSize postTextViewSize;

		postTextViewSize = [postText sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(kTableViewSectionWidth, 1000.0) lineBreakMode:UILineBreakModeWordWrap];
		return 57.0 + textOffset + postTextViewSize.height + 8.0;
	} else {
		return 57.0 + textOffset;
	}
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
	CGFloat textOffset = 0.0;
	NSString *postText;
	
	// Configure the cell...
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	//MVR - save some temporary variables for use later
	if ([post.type isEqualToString:@"CommentPost"]) {
		if ([[UIScreen mainScreen] scale] > 1.0)
			avatarUrl = [self avatarUrlForUser:post.comment.user size:@"super"];
		else
			avatarUrl = [self avatarUrlForUser:post.comment.user size:@"small"];
		if ([post.comment.user.type isEqualToString:@"BlogcastrUser"])
			username = post.comment.user.username;
		else if ([post.comment.user.type isEqualToString:@"FacebookUser"])
			username = post.comment.user.facebookFullName;
		else if ([post.comment.user.type isEqualToString:@"TwitterUser"])
			username = post.comment.user.twitterUsername;
	} else {
		if ([[UIScreen mainScreen] scale] > 1.0)
			avatarUrl = [self avatarUrlForUser:post.user size:@"super"];
		else
			avatarUrl = [self avatarUrlForUser:post.user size:@"small"];
		username = post.user.username;
	}
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
	label.text = [post.createdAt stringInWords];
	label.textColor = [UIColor colorWithRed:0.32 green:0.32 blue:0.32 alpha:1.0];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.frame = CGRectMake(66.0, 28.0, 100.0, 18.0);
	[label sizeToFit];
	[cell addSubview:label];
	[label release];
	if ([post.type isEqualToString:@"ImagePost"]) {
		CGFloat imageWidth;
		CGFloat imageHeight;
		
		if ([post.imageWidth integerValue] > kTableViewSectionWidth) {
			imageWidth = kTableViewSectionWidth;
			imageHeight = roundf(kTableViewSectionWidth * [post.imageHeight integerValue] / [post.imageWidth integerValue]); 
		} else {
			imageWidth = [post.imageWidth integerValue];
			imageHeight = [post.imageHeight integerValue];
		}
		button = [TTButton buttonWithStyle:@"roundedImagePost:"];
		button.frame = CGRectMake(18.0, 57.0, imageWidth, imageHeight);
		[button addTarget:self action:@selector(pressImagePost) forControlEvents:UIControlEventTouchUpInside];
		[button setImage:[self imagePostUrlForSize:@"default"] forState:UIControlStateNormal];
		[cell addSubview:button];
		textOffset = imageHeight + 8.0;
	}
	//MVR - text
	if ([post.type isEqualToString:@"CommentPost"])
		postText = post.comment.text;
	else
		postText = post.text;
	if (postText) {
		label = [[UILabel alloc] init];
		label.text = postText;
		label.font = [UIFont systemFontOfSize:13.0];
		label.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.numberOfLines = 0;
		label.frame = CGRectMake(18.0, 57.0 + textOffset, kTableViewSectionWidth, 100.0);
		[label sizeToFit];
		[cell addSubview:label];
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
}

#pragma mark -
#pragma mark Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		ASIFormDataRequest *request;
		
		//MVR - disable delete button
		self.navigationItem.rightBarButtonItem.enabled = NO;
		[self showProgressHudWithLabelText:@"Deleting post..." animated:YES animationType:MBProgressHUDAnimationZoom];
		request = [ASIFormDataRequest requestWithURL:[self deletePostUrl]];
		[request setRequestMethod:@"DELETE"];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(deletePostFinished:)];
		[request setDidFailSelector:@selector(deletePostFailed:)];
		[request startAsynchronous];
	}
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate

- (void)deletePostFinished:(ASIHTTPRequest *)theRequest {
	int statusCode;
	
	//MVR - we need to dismiss the action sheet here for some reason
	if (self.actionSheet.visible)
		[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	statusCode = [theRequest responseStatusCode];
	//MVR - 404 indicates the post may have already been deleted
	if (statusCode != 200 && statusCode != 404) {
		NSLog(@"Error delete post received status code %i", statusCode);
		//MVR - enable delete button
		self.navigationItem.rightBarButtonItem.enabled = YES;
		[self errorAlertWithTitle:@"Delete failed" message:@"Oops! We couldn't delete the post."];
		return;
	}
	[self.managedObjectContext deleteObject:post];
	if (![self save])
		NSLog(@"Error deleting post");
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)deletePostFailed:(ASIHTTPRequest *)theRequest {
	NSError *error;
	
	error = [theRequest error];
	//MVR - we need to dismiss the action sheet here for some reason
	if (self.actionSheet.visible)
		[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	//MVR - enable delete button
	self.navigationItem.rightBarButtonItem.enabled = YES;
	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Error deleting post: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection failure" message:@"Oops! We couldn't delete the post."];
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Error deleting post: request timed out");
			[self errorAlertWithTitle:@"Request timed out" message:@"Oops! We couldn't delete the post."];
			break;
		case ASIRequestCancelledErrorType:
			NSLog(@"Delete post request cancelled");
			break;
		default:
			NSLog(@"Error deleting post");
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

- (void)deletePost {
	[self.actionSheet showInView:self.view];
}

- (void)pressAvatar {
	if ([post.type isEqualToString:@"CommentPost"] && ![post.comment.user.type isEqualToString:@"BlogcastrUser"]) {
		TTWebController *webController;
		NSString *url;
		
		if ([post.comment.user.type isEqualToString:@"FacebookUser"]) {
			url = post.comment.user.facebookLink;
		} else if ([post.comment.user.type isEqualToString:@"TwitterUser"]) {
			url = [@"http://twitter.com/" stringByAppendingString:post.comment.user.twitterUsername];
		} else {
			NSLog(@"Error unknown comment user type");
			return;
		}
		webController = [[TTWebController alloc] init];
		[webController openURL:[NSURL URLWithString:url]];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	} else {
		UserController *userController;
		User *user;

		userController = [[UserController alloc] initWithStyle:UITableViewStyleGrouped];
		userController.managedObjectContext = self.managedObjectContext;
		userController.session = session;
		if ([post.type isEqualToString:@"CommentPost"])
			user = post.comment.user;
		else
			user = post.user;
		userController.user = user;
		if (session.user != user) {
			Subscription *subscription;

			subscription = [self subscriptionForUser:user];
			userController.subscription = subscription;
			if ([subscription.isSubscribed boolValue])
				userController.navigationItem.rightBarButtonItem = [userController unsubscribeButton];
			else
				userController.navigationItem.rightBarButtonItem = [userController subscribeButton];
		}
		userController.title = user.username;
		[self.navigationController pushViewController:userController animated:YES];
		[userController release];
	}
}

- (void)pressImagePost {
	ImageViewerController *imageViewerController;
	
	imageViewerController = [[ImageViewerController alloc] initWithNibName:nil bundle:nil];
	imageViewerController.imageUrl = [self imagePostUrlForSize:@"original"];
	[self.navigationController pushViewController:imageViewerController animated:YES];
	[imageViewerController release];
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

- (NSString *)imagePostUrlForSize:(NSString *)size {
	NSString *imagePostUrl;
	NSRange range;
	
#ifdef DEVEL
	imagePostUrl = [NSString stringWithFormat:@"http://sandbox.blogcastr.com%@", post.imageUrl];
#else //DEVEL
	imagePostUrl = [[post.imageUrl copy] autorelease];
#endif //DEVEL
	range = [imagePostUrl rangeOfString:@"original"];
	if (range.location != NSNotFound) {
		return [imagePostUrl stringByReplacingCharactersInRange:range withString:size];
	} else {
		NSLog(@"Error replacing size in image post url: %@", imagePostUrl);
		return imagePostUrl;
	}
}

- (NSURL *)deletePostUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [NSString stringWithFormat:@"http://sandbox.blogcastr.com/posts/%d.xml?authentication_token=%@", [post.id integerValue], session.user.authenticationToken];
#else //DEVEL
	string = [NSString stringWithFormat:@"http://blogcastr.com/posts/%d.xml?authentication_token=%@", [post.id integerValue], session.user.authenticationToken];
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
	[[[UIApplication sharedApplication] keyWindow] addSubview:self.progressHud];
	[self.progressHud show:animated];
}

- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message {
	//MVR - update and display the alert view
	self.alertView.title = title;
	self.alertView.message = message;
	[self.alertView show];
}


@end
