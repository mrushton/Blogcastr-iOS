//
//  TwitterConnectController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 10/3/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "TwitterConnectController.h"
#import "AppDelegate_iPhone.h"
#import "BlogcastrStyleSheet.h"
#import "TwitterCredentials.h"
#import "TwitterXAuth.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@implementation TwitterConnectController


@synthesize managedObjectContext;
@synthesize session;
@synthesize delegate;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize request;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
		UITextField *theUsernameTextField;
		UITextField *thePasswordTextField;

        // Custom initialization.
		self.navigationItem.title = @"Twitter Connect";
		theUsernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0, 0.0, 284.0, 43.0)];
		theUsernameTextField.placeholder = @"Username";
		theUsernameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		theUsernameTextField.textColor = BLOGCASTRSTYLEVAR(blueTextColor);
		theUsernameTextField.returnKeyType = UIReturnKeyNext;
		theUsernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		theUsernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[theUsernameTextField addTarget:self action:@selector(usernameEntered) forControlEvents:UIControlEventEditingDidEndOnExit];
		self.usernameTextField = theUsernameTextField;
		[theUsernameTextField release];
		thePasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0, 0.0, 284.0, 43.0)];
		thePasswordTextField.placeholder = @"Password";
		thePasswordTextField.secureTextEntry = YES;
		thePasswordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		thePasswordTextField.textColor = BLOGCASTRSTYLEVAR(blueTextColor);
		thePasswordTextField.returnKeyType = UIReturnKeyGo;
		thePasswordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		thePasswordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[thePasswordTextField addTarget:self action:@selector(connect) forControlEvents:UIControlEventEditingDidEndOnExit];
		self.passwordTextField = thePasswordTextField;
        isConnecting = NO;
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
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	// Set up the cell...
	
	//AS DESIGNED: only a few cells no need to make them reusable
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	if (indexPath.section == 0) {
		if (indexPath.row == 0)
			[cell.contentView addSubview:usernameTextField];
		else if (indexPath.row == 1)
			[cell.contentView addSubview:passwordTextField];
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


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"We use XAuth and don't transmit your password unencrypted or store it.";
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
#pragma mark Actions

- (void)usernameEntered {
	NSIndexPath *indexPath;
	
	indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
	[passwordTextField becomeFirstResponder];
}

- (void)connect {
	if (!usernameTextField.text || !passwordTextField.text || [usernameTextField.text isEqualToString:@""] || [passwordTextField.text isEqualToString:@""]) {
		[self errorAlertWithTitle:@"Empty field" message:@"Oops! Please enter your Twitter username and password."];
        return;
	}
    isConnecting = YES;
    [self showProgressHudWithLabelText:@"Connecting Twitter..." animated:YES animationType: MBProgressHUDAnimationZoom];
    self.twitterXAuth.username = usernameTextField.text;
    self.twitterXAuth.password = passwordTextField.text;
    //MVR - may already be authorized but do it anyway
    [self.twitterXAuth authorize];
}

- (void)cancel {
    if (isConnecting)
        [self.actionSheet showInView:self.view];
    else
        [self dismissModalViewControllerAnimated:YES];
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
    [managedObjectContext release];
    [session release];
    _twitterXAuth.delegate = nil;
    [_twitterXAuth cancel];
    [_twitterXAuth release];
    [request clearDelegatesAndCancel];
    [request release];
    _progressHud.delegate = nil;
    [_progressHud release];
	[_alertView release];
    [_cancelButton release];
    [super dealloc];
}

- (TwitterXAuth *)twitterXAuth {
	if (!_twitterXAuth) {
        _twitterXAuth = [[TwitterXAuth alloc] init];
        _twitterXAuth.consumerKey = CONSUMER_KEY;
        _twitterXAuth.consumerSecret = CONSUMER_SECRET;
        _twitterXAuth.delegate = self;
	}
	
	return _twitterXAuth;
}

- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        //MVR - modal view can cancel
        if (self.presentingViewController)
            _progressHud = [[MBProgressHUD alloc] initWithView:self.view.superview];
        else
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

- (UIBarButtonItem *)cancelButton {
	if (!_cancelButton) {
		_cancelButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
		_cancelButton.title = @"Cancel";
	}
	
	return _cancelButton;
}

- (UIActionSheet *)actionSheet {
	if (!_actionSheet)
		_actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to cancel connecting to Twitter?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
	
	return _actionSheet;
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
#pragma mark TwitterXAuth delegate

- (void)twitterXAuthAuthorizationDidFail:(TwitterXAuth *)twitterXAuth {
    NSLog(@"Error connecting to Twitter");
    isConnecting = NO;
    //MVR - hide the progress HUD
	[self.progressHud hide:YES];
    if (twitterXAuth.error == TwitterXAuthConnectionError)
        [self errorAlertWithTitle:@"Connection Error" message:@"Oops! We couldn't connect your Twitter account."];
    else
        [self errorAlertWithTitle:@"Authentication Failed" message:@"Oops! We couldn't connect your Twitter account."];
}

- (void)twitterXAuthDidAuthorize:(TwitterXAuth *)twitterXAuth {
    ASIFormDataRequest *theRequest;

    //MVR - save to server
    theRequest = [ASIFormDataRequest requestWithURL:[self twitterConnectUrl]];
	[theRequest setDelegate:self];
	[theRequest setDidFinishSelector:@selector(twitterConnectFinished:)];
	[theRequest setDidFailSelector:@selector(twitterConnectFailed:)];
	[theRequest addPostValue:session.user.authenticationToken forKey:@"authentication_token"];
	[theRequest addPostValue:twitterXAuth.token forKey:@"blogcastr_user[twitter_access_token]"];
	[theRequest addPostValue:twitterXAuth.tokenSecret forKey:@"blogcastr_user[twitter_token_secret]"];
    [theRequest startAsynchronous];
    self.request = theRequest;
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate

- (void)twitterConnectFinished:(ASIHTTPRequest *)theRequest {
	int statusCode;

	self.request = nil;
    isConnecting = NO;
	//MVR - we need to dismiss the action sheet here for some reason
	if (self.actionSheet.visible)
		[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	statusCode = [theRequest responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error Twitter connect received status code %i", statusCode);
		[self errorAlertWithTitle:@"Server Error" message:@"Oops! We couldn't connect to Twitter."];
		return;
	}
    //MVR - save Twitter info
    session.user.twitterAccessToken = self.twitterXAuth.token;
    session.user.twitterTokenSecret = self.twitterXAuth.tokenSecret;
    session.user.twitterUsername = self.twitterXAuth.username;
    if (![self save])
		NSLog(@"Error saving Twitter info");
    //MVR - dismiss controller
    if (self.presentingViewController)
        [self dismissModalViewControllerAnimated:YES];
    else
        [self.navigationController popViewControllerAnimated:YES];
    //MVR - inform delegate
    if ([delegate respondsToSelector:@selector(didConnectTwitter:)])
        [delegate didConnectTwitter:self];
    //MVR - send settings updated notification
	[[NSNotificationCenter defaultCenter] postNotificationName:@"updatedSettings" object:self];
}

- (void)twitterConnectFailed:(ASIHTTPRequest *)theRequest {
	NSError *error;
    
	self.request = nil;
    isConnecting = NO;
	//MVR - we need to dismiss the action sheet here for some reason
	if (self.actionSheet.visible)
		[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	error = [theRequest error];
	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Error connecting to Twitter: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection Failure" message:@"Oops! We couldn't connect to Twitter."];
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Error connecting to Twitter: request timed out");
			[self errorAlertWithTitle:@"Request Timed Out" message:@"Oops! We couldn't connect to Twitter."];
			break;
		case ASIRequestCancelledErrorType:
			NSLog(@"Twitter connect request cancelled");
			break;
		default:
			NSLog(@"Error connecting to Twitter");
			break;
	}	
}

#pragma mark -
#pragma mark Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet == _actionSheet && buttonIndex == 0)
        [self dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
}

#pragma mark -
#pragma mark MBProgressHUDDelegate delegate

- (void)hudWasHidden:(MBProgressHUD *)theProgressHUD {
	//MVR - remove HUD from screen when the HUD was hidden
	[theProgressHUD removeFromSuperview];
}

#pragma mark -
#pragma mark Helpers

- (NSURL *)twitterConnectUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = @"http://sandbox.blogcastr.com/twitter_connect.xml";
#else //DEVEL
	string = @"http://blogcastr.com/twitter_connect.xml";
#endif //DEVEL
	url = [NSURL URLWithString:string];
	
	return url;
}

- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType {
	self.progressHud.labelText = labelText;
	if (animated)
		self.progressHud.animationType = animationType;
    //MVR - modal view can cancel
    if (self.presentingViewController)
        [self.view.superview addSubview:self.progressHud];
    else
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

