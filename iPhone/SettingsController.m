//
//  SettingsController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 2/22/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "SettingsController.h"
#import "TwitterConnectController.h"
#import "AppDelegate_iPhone.h"
#import "Session.h"
#import "ASIFormDataRequest.h"
#import "UserParser.h"


@implementation SettingsController


@synthesize tabToolbarController;
@synthesize managedObjectContext;
@synthesize session;
@synthesize facebook;
@synthesize avatarActionSheet;
@synthesize twitterActionSheet;
@synthesize signOutActionSheet;
@synthesize progressHud;
@synthesize alertView;
@synthesize request;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
		UIImage *image;
		UITabBarItem *theTabBarItem;
		
        // Custom initialization.
		image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"settings" ofType:@"png"]];
		theTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:image tag:0];
		self.tabBarItem = theTabBarItem;
		[theTabBarItem release];
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	UIView *footerView;
	TTButton *signOutButton;
	
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.backgroundColor = TTSTYLEVAR(backgroundColor);
	footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 85.0)];
	self.tableView.tableFooterView = footerView;
	[footerView release];
	//MVR - set up sign out button
	signOutButton = [TTButton buttonWithStyle:@"redTableFooterButton:" title:@"Sign Out"];
	[signOutButton addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchUpInside]; 
	signOutButton.frame = CGRectMake(9.0, 20.0, 302.0, 45.0);
	[self.tableView.tableFooterView  addSubview:signOutButton];	
}

- (void)viewWillAppear:(BOOL)animated {
    //MVR - for Twitter connect
    [self.tableView reloadData];
    [super viewWillAppear:animated];
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
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 3;
		case 1:
			return 2;
		case 2:
			return 1;
		default:
			return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

	//AS DESIGNED: only 3 cells no need to make them reusable
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			UISwitch *theSwitch;
			
			cell.textLabel.text = @"Save original images";
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			theSwitch = [[UISwitch alloc] init];
			[theSwitch setOn:[session.user.saveOriginalImages boolValue] animated:NO];
			[theSwitch addTarget:self action:@selector(saveOriginalImages:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = theSwitch;
		} else if (indexPath.row == 1) {
			UISwitch *theSwitch;
			
			cell.textLabel.text = @"Vibrate";
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			theSwitch = [[UISwitch alloc] init];
			[theSwitch setOn:[session.user.vibrate boolValue] animated:NO];
			[theSwitch addTarget:self action:@selector(vibrate:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = theSwitch;
		} else if (indexPath.row == 2) {
			cell.textLabel.text = @"Change avatar";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Facebook";
            cell.detailTextLabel.text = session.user.facebookFullName;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else if (indexPath.row == 1) {
			cell.textLabel.text = @"Twitter";
            cell.detailTextLabel.text = session.user.twitterUsername;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	} else if (indexPath.section == 2) {
		cell.textLabel.text = @"Version";
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d.%d", VERSION_MAJOR, VERSION_MINOR];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
	if (section == 1)
		return @"Connect";
	
	return nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if (indexPath.section == 0 && indexPath.row == 2) {
		[self.avatarActionSheet showInView:tabToolbarController.view];
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			if ([facebook isSessionValid]) {
                [self.facebookActionSheet showInView:tabToolbarController.view];
            } else {
                UIApplication *application;
                AppDelegate_iPhone *appDelegate;
                NSArray *permissions;
                
                //MVR - set Facebook connect delegate
                application = [UIApplication sharedApplication];
                appDelegate = (AppDelegate_iPhone *)application.delegate;
                appDelegate.facebookConnectDelegate = self;
                permissions = [[NSArray alloc] initWithObjects:@"publish_stream", nil];
                [facebook authorize:permissions];
                [permissions release];
            }
		} else if (indexPath.row == 1) {
            if (session.user.twitterUsername) {
                [self.twitterActionSheet showInView:tabToolbarController.view];
            } else {
                TwitterConnectController *twitterConnectController;
			
                twitterConnectController = [[TwitterConnectController alloc] initWithStyle:UITableViewStyleGrouped];
                twitterConnectController.managedObjectContext = managedObjectContext;
                twitterConnectController.session = session;
                [tabToolbarController.navigationController pushViewController:twitterConnectController animated:YES];
                [twitterConnectController release];
            }
		} 		
	}
}

#pragma mark -
#pragma mark Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet == _avatarActionSheet && (buttonIndex == 0 || buttonIndex == 1)) {
		UIImagePickerController *imagePickerController;
		
		imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		if (buttonIndex == 0)
			imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		else if (buttonIndex == 1)
			imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[tabToolbarController presentModalViewController:imagePickerController animated:YES];
		[imagePickerController release];
	} else if (actionSheet == _signOutActionSheet && buttonIndex == 0) {
		//MVR - clear user session
		session.user.authenticationToken = nil;
		session.user.password = nil;
		session.user = nil;
		if (![self save]) {
			NSLog(@"Error saving session");
			return;
		}
		//MVR - post sign out notification since multiple controllers may be interested
		[[NSNotificationCenter defaultCenter] postNotificationName:@"signOut" object:self];
	} else if (actionSheet == _facebookActionSheet && buttonIndex == 0) {
        ASIFormDataRequest *theRequest;
		
		[self showProgressHudWithLabelText:@"Disconnecting Facebook..." mode:MBProgressHUDModeIndeterminate animated:YES animationType:MBProgressHUDAnimationZoom];
		theRequest = [ASIFormDataRequest requestWithURL:[self facebookDisconnectUrl]];
		[theRequest setRequestMethod:@"DELETE"];
		[theRequest setDelegate:self];
		[theRequest setDidFinishSelector:@selector(facebookDisconnectFinished:)];
		[theRequest setDidFailSelector:@selector(facebookDisconnectFailed:)];
		[theRequest startAsynchronous];
        self.request = theRequest;
    } else if (actionSheet == _twitterActionSheet && buttonIndex == 0) {
        ASIFormDataRequest *theRequest;
		
		[self showProgressHudWithLabelText:@"Disconnecting Twitter..." mode:MBProgressHUDModeIndeterminate animated:YES animationType:MBProgressHUDAnimationZoom];
		theRequest = [ASIFormDataRequest requestWithURL:[self twitterDisconnectUrl]];
		[theRequest setRequestMethod:@"DELETE"];
		[theRequest setDelegate:self];
		[theRequest setDidFinishSelector:@selector(twitterDisconnectFinished:)];
		[theRequest setDidFailSelector:@selector(twitterDisconnectFailed:)];
		[theRequest startAsynchronous];
        self.request = theRequest;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (actionSheet == _avatarActionSheet)
		[self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:YES];
    else if (actionSheet == _facebookActionSheet)
		[self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES];
    else if (actionSheet == _twitterActionSheet)
		[self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] animated:YES];
}

#pragma mark -
#pragma mark Image picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	ASIFormDataRequest *theRequest;
	NSData *data;
	
	//MVR - display HUD
	[self showProgressHudWithLabelText:@"Uploading avatar..." mode:MBProgressHUDModeDeterminate animated:YES animationType:MBProgressHUDAnimationZoom];
	theRequest = [ASIFormDataRequest requestWithURL:[self settingsUrl]];
	[theRequest addPostValue:session.user.authenticationToken forKey:@"authentication_token"];
	data = UIImageJPEGRepresentation(image, 0.5);
	[theRequest addData:data withFileName:@"avatar.jpg" andContentType:@"image/jpeg" forKey:@"setting[avatar]"];
	//MVR - settings update is a PUT request
	[theRequest setRequestMethod:@"PUT"];
	[theRequest setDelegate:self];
	//MVR - update progress view indirectly
	[theRequest setUploadProgressDelegate:self];
	[theRequest setDidFinishSelector:@selector(uploadAvatarFinished:)];
	[theRequest setDidFailSelector:@selector(uploadAvatarFailed:)];
	[theRequest startAsynchronous];
	[tabToolbarController dismissModalViewControllerAnimated:YES];
    self.request = theRequest;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[tabToolbarController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)theProgressHUD {
	//MVR - remove HUD from screen when the HUD was hidden
	[self.progressHud removeFromSuperview];
}

#pragma mark -
#pragma mark FacebookConnectDelegate methods

- (void)facebookIsConnecting {
    //MVR - display HUD
	[self showProgressHudWithLabelText:@"Connecting Facebook..." mode:MBProgressHUDModeIndeterminate animated:NO animationType:MBProgressHUDAnimationFade];
}

- (void)facebookDidConnect {
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES];
    //MVR - hide the progress HUD
	[self.progressHud hide:YES];
    [self.tableView reloadData];
}

- (void)facebookDidNotConnect:(BOOL)cancelled {
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES];
}

- (void)facebookConnectFailed:(NSError *)error {
    NSLog(@"Facebook connect failed");
    //MVR - hide the progress HUD
	[self.progressHud hide:YES];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES];
    [self errorAlertWithTitle:@"Connect Failed" message:@"Oops! We couldn't connect your Facebook account."];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
    [managedObjectContext release];
    [session release];
    [facebook release];
	[_avatarActionSheet release];
    [_facebookActionSheet release];
    [_twitterActionSheet release];
	[_signOutActionSheet release];
    _progressHud.delegate = nil;
	[_progressHud release];
    [request clearDelegatesAndCancel];
    [super dealloc];
}

- (UIActionSheet *)avatarActionSheet {
	if (!_avatarActionSheet)
		_avatarActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];

	return _avatarActionSheet;
}

- (UIActionSheet *)facebookActionSheet {
	if (!_facebookActionSheet)
		_facebookActionSheet = [[UIActionSheet alloc] initWithTitle:@"Would you like to disconnect your Facebook account?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
	
	return _facebookActionSheet;
}

- (UIActionSheet *)twitterActionSheet {
	if (!_twitterActionSheet)
		_twitterActionSheet = [[UIActionSheet alloc] initWithTitle:@"Would you like to disconnect your Twitter account?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
	
	return _twitterActionSheet;
}

- (UIActionSheet *)signOutActionSheet {
	if (!_signOutActionSheet)
		_signOutActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to sign out?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
	
	return _signOutActionSheet;
}

- (MBProgressHUD *)progressHud {
	if (!_progressHud) {
		_progressHud = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
		_progressHud.delegate = self;
	}
	
	return _progressHud;
}

#pragma mark -
#pragma mark Sign Out

- (void)signOut {
	[self.signOutActionSheet showInView:tabToolbarController.view];
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate

- (void)uploadAvatarFinished:(ASIHTTPRequest *)theRequest {
	int statusCode;
	UserParser *parser;
	
    self.request = nil;
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	statusCode = [theRequest responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error uploading avatar: received status code %i", statusCode);
		[self errorAlertWithTitle:@"Upload Failed" message:@"Oops! We couldn't change your avatar."];
		return;
	}
	//MVR - parse response
	parser = [[UserParser alloc] init];
	parser.data = [theRequest responseData];
	parser.user = session.user;
	if (![parser parse]) {
		NSLog(@"Error parsing settings response");
		[self errorAlertWithTitle:@"Parse Error" message:@"Oops! We couldn't change your avatar."];
		[parser release];
		return;
	}
    [parser release];
	if (![self save]) {
		NSLog(@"Error saving settings");
		return;
	}
	//MVR - send settings updated notification
	[[NSNotificationCenter defaultCenter] postNotificationName:@"updatedSettings" object:self];
}

- (void)uploadAvatarFailed:(ASIHTTPRequest *)theRequest {
	NSError *error;
	
    self.request = nil;
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	error = [theRequest error];
	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Error uploading avatar: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection Failure" message:@"Oops! We couldn't change your avatar."];
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Error uploading avatar: request timed out");
			[self errorAlertWithTitle:@"Request Timed Out" message:@"Oops! We couldn't change your avatar."];
			break;
		case ASIRequestCancelledErrorType:
			NSLog(@"Upload avatar request cancelled");
			break;
		default:
			NSLog(@"Error uploading avatar");
			break;
	}	
}

- (void)setProgress:(float)progress {
	self.progressHud.progress = progress;
}

- (void)facebookDisconnectFinished:(ASIHTTPRequest *)theRequest {
	int statusCode;
    
	self.request = nil;
	//MVR - we need to dismiss the action sheet here for some reason
	if (self.facebookActionSheet.visible)
		[self.facebookActionSheet dismissWithClickedButtonIndex:0 animated:YES];
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	statusCode = [theRequest responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error Facebook disconnect received status code %i", statusCode);
		[self errorAlertWithTitle:@"Server Error" message:@"Oops! We couldn't disconnect your Facebook account."];
		return;
	}
    //MVR - logout of Facebook
    [facebook logout];
    //MVR - delete Facebook info
    session.user.facebookAccessToken = nil;
    session.user.facebookId = nil;
    session.user.facebookFullName = nil;
    session.user.facebookLink = nil;
    if (![self save])
		NSLog(@"Error deleting Facebook info");
    //MVR - reload table view
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedSettings" object:self];
}

- (void)facebookDisconnectFailed:(ASIHTTPRequest *)theRequest {
	NSError *error;
    
    self.request = nil;
	//MVR - we need to dismiss the action sheet here for some reason
	if (self.facebookActionSheet.visible)
		[self.facebookActionSheet dismissWithClickedButtonIndex:0 animated:YES];
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	error = [theRequest error];
	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Error disconnecting Facebook: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection Failure" message:@"Oops! We couldn't disconnect your Facebook account."];
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Error disconnecting Facebook: request timed out");
			[self errorAlertWithTitle:@"Request Timed Out" message:@"Oops! We couldn't disconnect your Facebook account."];
			break;
		case ASIRequestCancelledErrorType:
			NSLog(@"Facebook disconnect request cancelled");
			break;
		default:
			NSLog(@"Error disconnecting Facebook");
			break;
	}	
}

- (void)twitterDisconnectFinished:(ASIHTTPRequest *)theRequest {
	int statusCode;
    
	self.request = nil;
	//MVR - we need to dismiss the action sheet here for some reason
	if (self.twitterActionSheet.visible)
		[self.twitterActionSheet dismissWithClickedButtonIndex:0 animated:YES];
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	statusCode = [theRequest responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error Twitter disconnect received status code %i", statusCode);
		[self errorAlertWithTitle:@"Server Error" message:@"Oops! We couldn't disconnect your Twitter account."];
		return;
	}
    //MVR - delete Twitter info
    session.user.twitterAccessToken = nil;
    session.user.twitterTokenSecret = nil;
    session.user.twitterUsername = nil;
    if (![self save])
		NSLog(@"Error deleting Twitter info");
    //MVR - reload table view
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedSettings" object:self];
}

- (void)twitterDisconnectFailed:(ASIHTTPRequest *)theRequest {
	NSError *error;
    
    self.request = nil;
	//MVR - we need to dismiss the action sheet here for some reason
	if (self.twitterActionSheet.visible)
		[self.twitterActionSheet dismissWithClickedButtonIndex:0 animated:YES];
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	error = [theRequest error];
	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Error disconnecting Twitter: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection Failure" message:@"Oops! We couldn't disconnect your Twitter account."];
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Error disconnecting Twitter: request timed out");
			[self errorAlertWithTitle:@"Request Timed Out" message:@"Oops! We couldn't disconnect your Twitter account."];
			break;
		case ASIRequestCancelledErrorType:
			NSLog(@"Twitter disconnect request cancelled");
			break;
		default:
			NSLog(@"Error disconnecting Twitter");
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

- (void)saveOriginalImages:(UISwitch *)theSwitch {
	session.user.saveOriginalImages = [NSNumber numberWithBool:theSwitch.on];
	if (![self save])
		NSLog(@"Error saving save original images setting");
}

- (void)vibrate:(UISwitch *)theSwitch {
	session.user.vibrate = [NSNumber numberWithBool:theSwitch.on];
	if (![self save])
		NSLog(@"Error saving vibrate setting");
}

#pragma mark -
#pragma mark Helpers

- (NSURL *)settingsUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [NSString stringWithFormat:@"http://sandbox.blogcastr.com/settings.xml"];
#else //DEVEL
	string = [NSString stringWithFormat:@"http://blogcastr.com/settings.xml"];
#endif //DEVEL
	url = [NSURL URLWithString:string];
	
	return url;
}

- (NSURL *)facebookConnectUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = @"http://sandbox.blogcastr.com/facebook_connect.xml";
#else //DEVEL
	string = @"http://blogcastr.com/facebook_connect.xml";
#endif //DEVEL
	url = [NSURL URLWithString:string];
	
	return url;
}

- (NSURL *)facebookDisconnectUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [NSString stringWithFormat:@"http://sandbox.blogcastr.com/facebook_disconnect.xml?authentication_token=%@", session.user.authenticationToken];
#else //DEVEL
	string = [NSString stringWithFormat:@"http://blogcastr.com/facebook_disconnect.xml?authentication_token=%@", session.user.authenticationToken];
#endif //DEVEL
	url = [NSURL URLWithString:string];
	
	return url;
}

- (NSURL *)twitterDisconnectUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [NSString stringWithFormat:@"http://sandbox.blogcastr.com/twitter_disconnect.xml?authentication_token=%@", session.user.authenticationToken];
#else //DEVEL
	string = [NSString stringWithFormat:@"http://blogcastr.com/twitter_disconnect.xml?authentication_token=%@", session.user.authenticationToken];
#endif //DEVEL
	url = [NSURL URLWithString:string];
	
	return url;
}

- (void)showProgressHudWithLabelText:(NSString *)labelText mode:(MBProgressHUDMode)mode animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType {
	self.progressHud.labelText = labelText;
    self.progressHud.mode = mode;
	if (animated)
		self.progressHud.animationType = animationType;
	[[[UIApplication sharedApplication] keyWindow] addSubview:self.progressHud];
	[self.progressHud show:animated];    
}

- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message {
	//MVR - display the alert view
	if (!alertView) {
		alertView = [[UIAlertView alloc] initWithTitle:title message: message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	} else {
		alertView.title = title;
		alertView.message = message;
	}
	[alertView show];
}

@end

