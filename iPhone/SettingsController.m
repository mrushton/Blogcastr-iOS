//
//  SettingsController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 2/22/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "SettingsController.h"
#import "AppDelegate_Shared.h"
#import "Session.h"
#import "ASIFormDataRequest.h"
#import "UserParser.h"


@implementation SettingsController


@synthesize tabToolbarController;
@synthesize managedObjectContext;
@synthesize session;
@synthesize avatarActionSheet;
@synthesize signOutActionSheet;
@synthesize windowProgressHud;
@synthesize alertView;

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
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 3;
		case 1:
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
	} else {
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

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if (indexPath.section == 0 && indexPath.row == 2)
		[self.avatarActionSheet showInView:tabToolbarController.view];
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
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (actionSheet == self.avatarActionSheet && buttonIndex == 2)
		[self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:YES];
}

#pragma mark -
#pragma mark Image picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	ASIFormDataRequest *request;
	NSData *data;
	
	//MVR - display HUD
	[self showWindowProgressHudWithLabelText:@"Uploading avatar..." animated:YES animationType:MBProgressHUDAnimationZoom];
	request = [ASIFormDataRequest requestWithURL:[self settingsUrl]];
	[request addPostValue:session.user.authenticationToken forKey:@"authentication_token"];
	data = UIImageJPEGRepresentation(image, 0.5);
	[request addData:data withFileName:@"avatar.jpg" andContentType:@"image/jpeg" forKey:@"setting[avatar]"];
	//MVR - settings update is a PUT request
	[request setRequestMethod:@"PUT"];
	[request setDelegate:self];
	//MVR - update progress view indirectly
	[request setUploadProgressDelegate:self];
	[request setDidFinishSelector:@selector(uploadAvatarFinished:)];
	[request setDidFailSelector:@selector(uploadAvatarFailed:)];
	[request startAsynchronous];
	[tabToolbarController dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[tabToolbarController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)theProgressHUD {
	//MVR - remove HUD from screen when the HUD was hidden
	[self.windowProgressHud removeFromSuperview];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
	[_avatarActionSheet release];
	[_signOutActionSheet release];
	[_windowProgressHud release];
    [super dealloc];
}

- (UIActionSheet *)avatarActionSheet {
	if (!_avatarActionSheet)
		_avatarActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];

	return _avatarActionSheet;
}

- (UIActionSheet *)signOutActionSheet {
	if (!_signOutActionSheet)
		_signOutActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to sign out?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
	
	return _signOutActionSheet;
}

- (MBProgressHUD *)windowProgressHud {
	if (!_windowProgressHud) {
		_windowProgressHud = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
		_windowProgressHud.delegate = self;
		//MVR - show progress view
		_windowProgressHud.mode = MBProgressHUDModeDeterminate;
	}
	
	return _windowProgressHud;
}

#pragma mark -
#pragma mark Sign Out

- (void)signOut {
	[self.signOutActionSheet showInView:tabToolbarController.view];
}

#pragma mark -
#pragma mark Network callbacks

- (void)uploadAvatarFinished:(ASIHTTPRequest *)request {
	int statusCode;
	UserParser *parser;
	
	//MVR - hide the progress HUD
	[self.windowProgressHud hide:YES];
	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error uploading avatar: received status code %i", statusCode);
		[self errorAlertWithTitle:@"Upload failed" message:@"Oops! We couldn't change your avatar."];
		return;
	}
	//MVR - parse response
	parser = [[UserParser alloc] init];
	parser.data = [request responseData];
	parser.user = session.user;
	if (![parser parse]) {
		NSLog(@"Error parsing settings response");
		[self errorAlertWithTitle:@"Parse error" message:@"Oops! We couldn't change your avatar."];
		[parser release];
		return;
	}
	if (![self save]) {
		NSLog(@"Error saving settings");
		return;
	}
	[parser release];
	//MVR - send settings updated notification
	[[NSNotificationCenter defaultCenter] postNotificationName:@"updatedSettings" object:self];
}

- (void)uploadAvatarFailed:(ASIHTTPRequest *)request {
	NSError *error;
	
	//MVR - hide the progress HUD
	[self.windowProgressHud hide:YES];
	error = [request error];
	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Error uploading avatar: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection failure" message:@"Oops! We couldn't change your avatar."];
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Error uploading avatar: request timed out");
			[self errorAlertWithTitle:@"Request timed out" message:@"Oops! We couldn't change your avatar."];
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
	self.windowProgressHud.progress = progress;
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

- (void)showWindowProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType {
	self.windowProgressHud.labelText = labelText;
	if (animated)
		self.windowProgressHud.animationType = animationType;
	[[[UIApplication sharedApplication] keyWindow] addSubview:self.windowProgressHud];
	[self.windowProgressHud show:animated];
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

