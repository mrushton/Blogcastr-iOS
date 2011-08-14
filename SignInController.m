//
//  SignInController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 2/26/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "SignInController.h"
#import "UserParser.h"
#import "ErrorsParser.h"
#import "BlogcastrStyleSheet.h"
#import "NSString+Validations.h"

@implementation SignInController

@synthesize managedObjectContext;
@synthesize session;
@synthesize delegate;
@synthesize signInUsernameTextField;
@synthesize signInPasswordTextField;
@synthesize signUpFullNameTextField;
@synthesize signUpUsernameTextField;
@synthesize signUpPasswordTextField;
@synthesize signUpEmailTextField;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
    if (self) {
		UIImage *titleImage;
		UIImageView *titleView;
		UITextField *theSignInUsernameTextField;
		UITextField *theSignInPasswordTextField;
		UITextField *theSignUpFullNameTextField;
		UITextField *theSignUpUsernameTextField;
		UITextField *theSignUpPasswordTextField;
		UITextField *theSignUpEmailTextField;

		titleImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"]];
		titleView = [[UIImageView alloc] initWithImage:titleImage];
		self.navigationItem.titleView = titleView;
		[titleView release];
		theSignInUsernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0, 0.0, 284.0, 43.0)];
		theSignInUsernameTextField.placeholder = @"Username/Email";
		theSignInUsernameTextField.keyboardType = UIKeyboardTypeEmailAddress;
		theSignInUsernameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		theSignInUsernameTextField.textColor = BLOGCASTRSTYLEVAR(blueTextColor);
		theSignInUsernameTextField.returnKeyType = UIReturnKeyNext;
		theSignInUsernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		theSignInUsernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[theSignInUsernameTextField addTarget:self action:@selector(signInUsernameEntered) forControlEvents:UIControlEventEditingDidEndOnExit];
		self.signInUsernameTextField = theSignInUsernameTextField;
		[theSignInUsernameTextField release];
		theSignInPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0, 0.0, 284.0, 43.0)];
		theSignInPasswordTextField.placeholder = @"Password";
		theSignInPasswordTextField.secureTextEntry = YES;
		theSignInPasswordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		theSignInPasswordTextField.textColor = BLOGCASTRSTYLEVAR(blueTextColor);
		theSignInPasswordTextField.returnKeyType = UIReturnKeyGo;
		theSignInPasswordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		theSignInPasswordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[theSignInPasswordTextField addTarget:self action:@selector(signIn) forControlEvents:UIControlEventEditingDidEndOnExit];
		self.signInPasswordTextField = theSignInPasswordTextField;
		[theSignInPasswordTextField release];
		theSignUpFullNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0, 0.0, 284.0, 43.0)];
		theSignUpFullNameTextField.placeholder = @"Full name";
		theSignUpFullNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		theSignUpFullNameTextField.textColor = BLOGCASTRSTYLEVAR(blueTextColor);
		theSignUpFullNameTextField.returnKeyType = UIReturnKeyNext;
		theSignUpFullNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		theSignUpFullNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[theSignUpFullNameTextField addTarget:self action:@selector(signUpFullNameEntered) forControlEvents:UIControlEventEditingDidEndOnExit];
		self.signUpFullNameTextField = theSignUpFullNameTextField;
		[theSignUpFullNameTextField release];
		theSignUpUsernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0, 0.0, 284.0, 43.0)];
		theSignUpUsernameTextField.placeholder = @"Username";
		theSignUpUsernameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		theSignUpUsernameTextField.textColor = BLOGCASTRSTYLEVAR(blueTextColor);
		theSignUpUsernameTextField.returnKeyType = UIReturnKeyNext;
		theSignUpUsernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		theSignUpUsernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[theSignUpUsernameTextField addTarget:self action:@selector(signUpUsernameEntered) forControlEvents:UIControlEventEditingDidEndOnExit];
		self.signUpUsernameTextField = theSignUpUsernameTextField;
		[theSignUpUsernameTextField release];
		theSignUpPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0, 0.0, 284.0, 43.0)];
		theSignUpPasswordTextField.placeholder = @"Password";
		theSignUpPasswordTextField.secureTextEntry = YES;
		theSignUpPasswordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		theSignUpPasswordTextField.textColor = BLOGCASTRSTYLEVAR(blueTextColor);
		theSignUpPasswordTextField.returnKeyType = UIReturnKeyNext;
		theSignUpPasswordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		theSignUpPasswordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[theSignUpPasswordTextField addTarget:self action:@selector(signUpPasswordEntered) forControlEvents:UIControlEventEditingDidEndOnExit];
		self.signUpPasswordTextField = theSignUpPasswordTextField;
		[theSignUpPasswordTextField release];
		theSignUpEmailTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0, 0.0, 284.0, 43.0)];
		theSignUpEmailTextField.placeholder = @"Email";
		theSignUpEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
		theSignUpEmailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		theSignUpEmailTextField.textColor = BLOGCASTRSTYLEVAR(blueTextColor);
		theSignUpEmailTextField.returnKeyType = UIReturnKeyGo;
		theSignUpEmailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		theSignUpEmailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[theSignUpEmailTextField addTarget:self action:@selector(signUp) forControlEvents:UIControlEventEditingDidEndOnExit];
		self.signUpEmailTextField = theSignUpEmailTextField;
		[theSignUpEmailTextField release];
    }

    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
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
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0)
		return 2;
	else
		return 4;
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
			[cell.contentView addSubview:signInUsernameTextField];
		else
			[cell.contentView addSubview:signInPasswordTextField];
    } else {
		if (indexPath.row == 0)
			[cell.contentView addSubview:signUpFullNameTextField];
		else if (indexPath.row == 1)
			[cell.contentView addSubview:signUpUsernameTextField];
		else if (indexPath.row == 2)
			[cell.contentView addSubview:signUpPasswordTextField];
		else
			[cell.contentView addSubview:signUpEmailTextField];
	}

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0)
		return @"Sign In";
	else
		return @"Sign Up";
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

/*
- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}
*/


- (void)dealloc {
	[managedObjectContext release];
	[session release];
	[signInUsernameTextField release];
	[signInPasswordTextField release];
	[signUpFullNameTextField release];
	[signUpUsernameTextField release];
	[signUpPasswordTextField release];
	[signUpEmailTextField release];
	[_alertView release];
	[_progressHud release];
	[super dealloc];
}

- (MBProgressHUD *)progressHud {
	if (!_progressHud) {
		//MVR - use superview to handle a display bug
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
#pragma mark ASIHTTPRequest delegate

- (void)authenticationTokenRequestFinished:(ASIHTTPRequest *)request {
	int statusCode;
	UserParser *parser;
	
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
		[self errorAlertWithTitle:@"Authentication error" message:@"Oops! We couldn't sign you in. Invalid username and password."];
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
	parser.user.password = signInPasswordTextField.text;
	//MVR - update the session with authenticated user
	session.user = parser.user;
	if (![self save])
		NSLog(@"Error saving user and session on sign in");
	[parser release];
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

- (void)signUpRequestFinished:(ASIHTTPRequest *)request {
	int statusCode;
	UserParser *userParser;
	
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	statusCode = [request responseStatusCode];
	//MVR - Unprocessable entity status may return an error response
	if (statusCode == 422 && [request responseData]) {
		ErrorsParser *errorsParser;
		NSMutableString *errorList;
		
		errorsParser = [[ErrorsParser alloc] init];
		errorsParser.data = [request responseData];
		if (![errorsParser parse]) {
			[errorsParser release];
			NSLog(@"Error parsing sign up response errors");
			[self errorAlertWithTitle:@"Sign up error" message:@"Oops! We couldn't sign you up."];
			return;
		}
		//MVR - create the error message
		errorList = [NSMutableString stringWithCapacity:100];
		[errorList appendString:@"Oops!"];
		if (errorsParser.errors.count > 0) {
			for (NSString *error in errorsParser.errors)
				[errorList appendString:[NSString stringWithFormat:@" %@.", error]];
		} else {
			NSLog(@"Sign up parser error list was empty");
			[errorList appendString:@" We couldn't sign you up."];
		}
		[self errorAlertWithTitle:@"Sign up failed" message:errorList];
		[errorsParser release];
		return;
	} else if (statusCode != 200) {
		[self errorAlertWithTitle:@"Sign up failed" message:@"Oops! We couldn't sign you up."];
		return;
	}
	//MVR - parse response
	userParser = [[UserParser alloc] init];
	userParser.data = [request responseData];
	userParser.managedObjectContext = managedObjectContext;
	if (![userParser parse]) {
		NSLog(@"Error parsing sign up response");
		[self errorAlertWithTitle:@"Parse error" message:@"Oops! We couldn't sign you up."];
		[userParser release];
		return;
	}
	//MVR - need to save password for XMPP client
	userParser.user.password = signUpPasswordTextField.text;
	//MVR - update the session with authenticated user
	session.user = userParser.user;
	if (![self save])
		NSLog(@"Error saving user and session on sign up");
	[userParser release];
	//MVR - sign in to the root view controller
	//AS DESIGNED: use delegate to avoid compiler warning
	[delegate signIn];
	//MVR - this message gets forwarded to the parent 
	[self dismissModalViewControllerAnimated:YES];
}

- (void)signUpRequestFailed:(ASIHTTPRequest *)request {
	NSError *error;
	
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
	error = [request error];
	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Sign up request error: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection failure" message:@"Oops! We couldn't sign you up."];
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Sign up request error: request timed out");
			[self errorAlertWithTitle:@"Request timed out" message:@"Oops! We couldn't sign you up."];
			break;
		case ASIRequestCancelledErrorType:
			NSLog(@"Sign up request cancelled");
			break;
		default:
			NSLog(@"Sign up request error");
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

- (void)signInUsernameEntered {
	NSIndexPath *indexPath;
	
	indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	[signInPasswordTextField becomeFirstResponder];
}

- (void)signIn {
	ASIHTTPRequest *request;

	//AS DESIGNED: do not check validations here only that both fields were entered
	if (!signInUsernameTextField.text || !signInPasswordTextField.text || [signInUsernameTextField.text isEqualToString:@""] || [signInPasswordTextField.text isEqualToString:@""]) {
		[self errorAlertWithTitle:@"Empty field" message:@"Oops! Please enter your username and password."];
        return;
	}
	[signInPasswordTextField resignFirstResponder];
	[self showProgressHudWithLabelText:@"Signing in..." animated:YES animationType:MBProgressHUDAnimationZoom];
	request = [ASIHTTPRequest requestWithURL:[self authenticationTokenUrl]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(authenticationTokenRequestFinished:)];
	[request setDidFailSelector:@selector(authenticationTokenRequestFailed:)];
	[request startAsynchronous];
}

- (void)signUpFullNameEntered {
	NSIndexPath *indexPath;

	indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	[signUpUsernameTextField becomeFirstResponder];
}

- (void)signUpUsernameEntered {
	NSIndexPath *indexPath;
	
	indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	[signUpPasswordTextField becomeFirstResponder];
}

- (void)signUpPasswordEntered {
	NSIndexPath *indexPath;
	
	indexPath = [NSIndexPath indexPathForRow:3 inSection:1];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	[signUpEmailTextField becomeFirstResponder];
}

- (void)signUp {
	ASIFormDataRequest *request;
	NSMutableString *errorList;
	BOOL hasErrors = NO;
	BOOL hasMultipleErrors = NO;
	NSInteger utcOffset;
	
	[signUpEmailTextField resignFirstResponder];
	errorList = [NSMutableString stringWithCapacity:100];
	[errorList appendString:@"Oops! We couldn't sign you up."];
	if (!signUpFullNameTextField.text || [signUpFullNameTextField.text isEqualToString:@""]) {
		[errorList appendString:@" You must enter your full name."];
		hasErrors = YES;
	}
	if (!signUpUsernameTextField.text || [signUpUsernameTextField.text isEqualToString:@""]) {
		[errorList appendString:@" You must enter a username."];
		if (hasErrors)
			hasMultipleErrors = YES;
		hasErrors = YES;
	} else if (![signUpUsernameTextField.text isValidUsername]) {
		[errorList appendString:@" Your username must be between 4 and 15 characters and can only contain letters, numbers and underscores."];
		if (hasErrors)
			hasMultipleErrors = YES;
		hasErrors = YES;	
	}
	if (!signUpPasswordTextField.text || [signUpPasswordTextField.text isEqualToString:@""]) {
		[errorList appendString:@" You must enter a password."];
		if (hasErrors)
			hasMultipleErrors = YES;
		hasErrors = YES;	
	} else if (![signUpPasswordTextField.text isValidPassword]) {
		[errorList appendString:@" Your password must be at least 6 characters."];
		if (hasErrors)
			hasMultipleErrors = YES;
		hasErrors = YES;
	}
	if (!signUpEmailTextField.text || [signUpEmailTextField.text isEqualToString:@""]) {
		[errorList appendString:@" You must enter your email."];
		if (hasErrors)
			hasMultipleErrors = YES;
		hasErrors = YES;	
	} else if (![signUpEmailTextField.text isValidEmail]) {
		[errorList appendString:@" Your email is invalid."];
		if (hasErrors)
			hasMultipleErrors = YES;
		hasErrors = YES;	
	}
	if (hasErrors) {
		NSString *errorTitle;

		if (hasMultipleErrors)
			errorTitle = @"Invalid fields";
		else
			errorTitle = @"Invalid field";
		[self errorAlertWithTitle:errorTitle message:errorList];
        return;		
	}
	[self showProgressHudWithLabelText:@"Signing up..." animated:YES animationType:MBProgressHUDAnimationZoom];
	request = [ASIFormDataRequest requestWithURL:[self signUpUrl]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(signUpRequestFinished:)];
	[request setDidFailSelector:@selector(signUpRequestFailed:)];
	[request addPostValue:signUpFullNameTextField.text forKey:@"setting[full_name]"];
	[request addPostValue:signUpUsernameTextField.text forKey:@"blogcastr_user[username]"];
	[request addPostValue:signUpPasswordTextField.text forKey:@"blogcastr_user[password]"];
	[request addPostValue:signUpEmailTextField.text forKey:@"blogcastr_user[email]"];
	//MVR - the utc offset is in seconds and used to set the user's timezone
	utcOffset = [[NSTimeZone systemTimeZone] secondsFromGMT] / 60;
	[request addPostValue:[NSString stringWithFormat:@"%d", utcOffset] forKey:@"utc_offset"];
	[request startAsynchronous];
}

#pragma mark -
#pragma mark Helpers

- (NSURL *)authenticationTokenUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [[NSString stringWithFormat:@"http://sandbox.blogcastr.com/authentication_token.xml?username=%@&password=%@", signInUsernameTextField.text, signInPasswordTextField.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else //DEVEL
	string = [[NSString stringWithFormat:@"https://blogcastr.com/authentication_token.xml?username=%@&password=%@", signInUsernameTextField.text, signInPasswordTextField.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#endif //DEVEL
	url = [NSURL URLWithString:string];
	
	return url;
}

- (NSURL *)signUpUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = @"http://sandbox.blogcastr.com/users.xml";
#else //DEVEL
	string = @"https://blogcastr.com/users.xml";
#endif //DEVEL
	url = [NSURL URLWithString:string];
	
	return url;
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

