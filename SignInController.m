//
//  SignInController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 2/26/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "SignInController.h"
#import "UserParser.h"
#import "BlogcastrStyleSheet.h"

@implementation SignInController

@synthesize managedObjectContext;
@synthesize session;
@synthesize delegate;
@synthesize usernameTextField;
@synthesize passwordTextField;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	NSArray *nibArray;
	UIView *signInView;
	UITextField *theUsernameTextField;
	UITextField *thePasswordTextField;

    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

 	//MVR - load Sign In View nib
	//AS DESIGNED: nib loading uses the setter methods so the retain count does not need to be incremented
	nibArray = [[NSBundle mainBundle] loadNibNamed:@"SignInView_iPhone" owner:self options:nil];
	signInView = [nibArray objectAtIndex:0];
	[self.view addSubview:signInView];
	theUsernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0, 0.0, 284.0, 43.0)];
	theUsernameTextField.placeholder = @"Username/Email";
	theUsernameTextField.keyboardType = UIKeyboardTypeEmailAddress;
	theUsernameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	theUsernameTextField.textColor = TTSTYLEVAR(blueTextColor);
	theUsernameTextField.returnKeyType = UIReturnKeyNext;
	theUsernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	theUsernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[theUsernameTextField addTarget:self action:@selector(usernameEntered:) forControlEvents:UIControlEventEditingDidEndOnExit];
	self.usernameTextField = theUsernameTextField;
	[theUsernameTextField release];
	thePasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0, 0.0, 284.0, 43.0)];
	thePasswordTextField.placeholder = @"Password";
	thePasswordTextField.secureTextEntry = YES;
	thePasswordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	thePasswordTextField.textColor = TTSTYLEVAR(blueTextColor);
	thePasswordTextField.returnKeyType = UIReturnKeyGo;
	thePasswordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	thePasswordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[thePasswordTextField addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventEditingDidEndOnExit];
	self.passwordTextField = thePasswordTextField;
	[thePasswordTextField release];
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

	//AS DESIGNED: only 2 cells no need to make them reusable
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	if (indexPath.row == 0)
		[cell.contentView addSubview:usernameTextField];
	else
		[cell.contentView addSubview:passwordTextField];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Sign In";
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
	self.usernameTextField = nil;
	self.passwordTextField = nil;
}


- (void)dealloc {
	[managedObjectContext release];
	[session release];
	[usernameTextField release];
	[passwordTextField release];
	[_alertView release];
	[_progressHud release];
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
#pragma mark ASIHTTPRequest delegate

- (void)authenticationTokenRequestFinished:(ASIHTTPRequest *)request {
	int statusCode;
	UserParser *parser;
	
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
		[self errorAlertWithTitle:@"Authentication error" message:@"Oops! We couldn't sign you in."];
		return;
	}
	//MVR - parse response
	parser = [[UserParser alloc] init];
	parser.data = [request responseData];
	parser.managedObjectContext = managedObjectContext;
	if (![parser parse]) {
		NSLog(@"Error parsing authentication token response");
		[self errorAlertWithTitle:@"Parse error" message:@"Oops! We couldn't sign you in."];
		[parser release];
		return;
	}
	//MVR - need to save password for XMPP client
	parser.user.password = passwordTextField.text;
	if (![self save])
		NSLog(@"Error saving user");
	[parser release];
	//MVR - update the session with authenticated user
	session.user = parser.user;
	//MVR - sign in to the root view controller
	//AS DESIGNED: use delegate to avoid compiler warning
	[delegate signIn];
	//MVR - this message gets forwarded to the parent 
	[self dismissModalViewControllerAnimated:YES];
}

- (void)authenticationTokenRequestFailed:(ASIHTTPRequest *)request {
	NSError *error;
	
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	error = [request error];

	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Authentication token request error: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection failure" message:@"Oops! We couldn't sign you in."];
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Authentication token request error: request timed out");
			[self errorAlertWithTitle:@"Request timed out" message:@"Oops! We couldn't sign you in."];
			break;
		case ASIRequestCancelledErrorType:
			NSLog(@"Authentication token request cancelled");
			break;
		default:
			NSLog(@"Authentication token request error");
			break;
	}	
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)theProgressHUD {
	//MVR - remove HUD from screen when the HUD is hidden
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

- (void)usernameEntered:(id)object {
	//MVR - make password text field the first responder
	[passwordTextField becomeFirstResponder];
}

- (void)signIn:(id)object {
	ASIHTTPRequest *request;

	//MVR - make sure the text fields were filled in
	//TODO: check to make sure username and password are well formed
	if (!usernameTextField.text || !passwordTextField.text || [usernameTextField.text isEqualToString:@""] || [passwordTextField.text isEqualToString:@""]) {
		[self errorAlertWithTitle:@"Empty field" message:@"Oops! Please enter your username and password."];
        return;
	}
	[passwordTextField resignFirstResponder];
	[self showProgressHudWithLabelText:@"Authenticating..." animated:YES animationType:MBProgressHUDAnimationZoom];
	request = [ASIHTTPRequest requestWithURL:[self authenticationTokenUrl]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(authenticationTokenRequestFinished:)];
	[request setDidFailSelector:@selector(authenticationTokenRequestFailed:)];
	[request startAsynchronous];
}

#pragma mark -
#pragma mark Helpers

- (NSURL *)authenticationTokenUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [[NSString stringWithFormat:@"http://sandbox.blogcastr.com/authentication_token.xml?username=%@&password=%@", usernameTextField.text, passwordTextField.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else //DEVEL
	string = [[NSString stringWithFormat:@"https://blogcastr.com/authentication_token.xml?username=%@&password=%@", usernameTextField.text, passwordTextField.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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

