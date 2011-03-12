//
//  SignInController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 2/26/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "SignInController.h"
#import "MBProgressHUD.h"


@implementation SignInController

@synthesize managedObjectContext;
@synthesize session;
@synthesize username;
@synthesize password;
@synthesize xmlParserMutableString;
@synthesize xmlParserAuthenticationToken;
@synthesize xmlParserId;
@synthesize xmlParserUsername;
@synthesize xmlParserAvatarFileName;
@synthesize xmlParserBio;
@synthesize xmlParserFullName;
@synthesize xmlParserLocation;
@synthesize xmlParserWeb;
@synthesize delegate;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize progressHUD;
@synthesize alertView;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	NSArray *nibArray;
	UIView *signInView;

    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

 	//MVR - load Sign In View nib
	//AS DESIGNED: nib loading uses the setter methods so the retain count does not need to be incremented
	nibArray = [[NSBundle mainBundle] loadNibNamed:@"SignInView_iPhone" owner:self options:nil];
	signInView = [nibArray objectAtIndex:0];
	[self.view addSubview:signInView];
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
	UITextField *textField;
	CGRect rect;
	
	// Set up the cell...

	//AS DESIGNED: only 2 cells no need to make them reusable
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.textColor = [UIColor colorWithRed:0.318 green:0.345 blue:0.439 alpha:1.0];
	rect = CGRectMake(106.0, 11.0, 190.0, 30.0);
	textField = [[UITextField alloc] initWithFrame:rect];
	textField.textColor = [UIColor colorWithRed:0.31 green:0.31 blue:0.31 alpha:1.0];
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	//textField.font = [UIFont systemFontOfSize:17.0];
	if (indexPath.row == 0) {
		cell.textLabel.text = @"Username";
		textField.keyboardType = UIKeyboardTypeEmailAddress;
		textField.returnKeyType = UIReturnKeyNext;
		[textField addTarget:self action:@selector(usernameEntered:) forControlEvents:UIControlEventEditingDidEndOnExit];
		self.usernameTextField = textField;
	}
	else {
		cell.textLabel.text = @"Password";
		textField.secureTextEntry = YES;
		textField.returnKeyType = UIReturnKeyGo;
		[textField addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventEditingDidEndOnExit];
		self.passwordTextField = textField;
	}
	[cell.contentView addSubview:textField];
    
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
	if (alertView)
		self.alertView = nil;
	if (progressHUD)
		self.progressHUD = nil;
}


- (void)dealloc {
	[managedObjectContext release];
	[session release];

	//MVR - free dictonary
	if (urlConnectionDataMutableDictionaryRef_)
		CFRelease(urlConnectionDataMutableDictionaryRef_);
	[super dealloc];
}

- (CFMutableDictionaryRef)urlConnectionDataMutableDictionaryRef {
	//MVR - lazily load
	if (!urlConnectionDataMutableDictionaryRef_)
		urlConnectionDataMutableDictionaryRef_ = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);	
	
	return urlConnectionDataMutableDictionaryRef_;
}

#pragma mark -
#pragma mark User interface

- (void)usernameEntered:(id)object {
	//MVR - make password text field the first responder
	[passwordTextField becomeFirstResponder];
}

- (void)signIn:(id)object {
	NSString *string;
	NSURL *url;
	NSURLRequest *urlRequest;
    NSMutableData *mutableData;
	NSURLConnection *urlConnection;

	//MVR - store username and password
	self.username = usernameTextField.text;
	self.password = passwordTextField.text;
	//MVR - make sure the text fields were filled in
	//TODO: check to make sure username and password are well formed
	if (!username || !password || [username isEqualToString:@""] || [password isEqualToString:@""]) {
		[self errorAlert:@"Authentication failed"];
        return;
	}
	[passwordTextField resignFirstResponder];
    //MVR - get authentication token
#ifdef DEVEL
	string = [[NSString stringWithFormat:@"http://sandbox.blogcastr.com/authentication_token.xml?username=%@&password=%@", username, password] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else //DEVEL
	string = [[NSString stringWithFormat:@"https://blogcastr.com/authentication_token.xml?username=%@&password=%@", username, password] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#endif //DEVEL
    url = [NSURL URLWithString:string];
	urlRequest = [NSURLRequest requestWithURL:url];
	urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
	mutableData = [[NSMutableData alloc] initWithCapacity:1024];
	//MVR - add data to dictionary
	CFDictionaryAddValue(self.urlConnectionDataMutableDictionaryRef, urlConnection, mutableData);
	//MVR - progress HUD
	if (!progressHUD) {
		MBProgressHUD *theProgressHUD;
		
		theProgressHUD = [[MBProgressHUD alloc] initWithView:self.view];
		theProgressHUD.delegate = self;
		theProgressHUD.labelText = @"Authenticating";
		theProgressHUD.animationType = MBProgressHUDAnimationZoom;
		self.progressHUD = theProgressHUD;
		[theProgressHUD release];
	}
	else {
		progressHUD.labelText = @"Authenticating";
	}
	[self.view addSubview:progressHUD];
    [progressHUD show:YES];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)urlConnection didReceiveResponse:(NSURLResponse *)urlResponse {
	int statusCode;
	NSMutableData *mutableData;

	//MVR - check for errors
	statusCode = [(NSHTTPURLResponse*)urlResponse statusCode];
	if (statusCode != 200) {
		NSLog(@"URL connection received status code %i", statusCode);
		//MVR - remove data from dictionaries
		CFDictionaryRemoveValue(self.urlConnectionDataMutableDictionaryRef, urlConnection);
		[urlConnection cancel];
		[urlConnection release];
		if (progressHUD)
			[progressHUD hide:YES];
		[self errorAlert:@"Authentication failed"];
		return;
	}
    //MVR - get data
	mutableData = (NSMutableData *)CFDictionaryGetValue(self.urlConnectionDataMutableDictionaryRef, urlConnection);
	//MVR - may receive multiple messages
    [mutableData setLength:0];
}

- (void)connection:(NSURLConnection *)urlConnection didReceiveData:(NSData *)data {
	NSMutableData *mutableData;
	
	//MVR - get data
	mutableData = (NSMutableData *)CFDictionaryGetValue(self.urlConnectionDataMutableDictionaryRef, urlConnection);
	//MVR - append data
    [mutableData appendData:data];
}

- (void)connection:(NSURLConnection *)urlConnection didFailWithError:(NSError *)error {
    //MVR - remove data from dictionary
	CFDictionaryRemoveValue(self.urlConnectionDataMutableDictionaryRef, urlConnection);
    [urlConnection release];
	NSLog(@"URL connection failed with error: %@", [error localizedDescription]);
	if (progressHUD)
		[progressHUD hide:YES];
	[self errorAlert:@"Authentication failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)urlConnection {
	NSMutableData *mutableData;
	NSXMLParser *parser;
	
	//MVR - get data from dicitionary
	mutableData = (NSMutableData *)CFDictionaryGetValue(self.urlConnectionDataMutableDictionaryRef, urlConnection);
    //MVR - parse xml
	parser = [[NSXMLParser alloc] initWithData:mutableData];
	[parser setDelegate:self];
	[parser parse];
	[parser release];
	//MVR - remove data from dictionary
	CFDictionaryRemoveValue(self.urlConnectionDataMutableDictionaryRef, urlConnection);
	[urlConnection release];
	if (progressHUD)
		[progressHUD hide:YES];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	User *user;
	Settings *settings;
	NSNumberFormatter *numberFormatter;
	NSNumber *number;
	NSError *error;
	
	//MVR - save Session, User and Settings objects
	if (!xmlParserAuthenticationToken) {
		NSLog(@"Error parsing authentication token");
		[self errorAlert:@"Parse error"];
		return;
	}
	session.authenticationToken = xmlParserAuthenticationToken;
	user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
	if (!xmlParserId) {
		NSLog(@"Error parsing id");
		[self errorAlert:@"Parse error"];
		return;
	}
	numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	number = [numberFormatter numberFromString:xmlParserId];
	[numberFormatter release];
	user.id = number;
	if (!xmlParserUsername) {
		NSLog(@"Error parsing username");
		[self errorAlert:@"Parse error"];
		return;
	}
	user.username = xmlParserUsername;
	user.avatarFileName = xmlParserAvatarFileName;
	user.bio = xmlParserBio;
	if (!xmlParserFullName) {
		NSLog(@"Error parsing full name");
		[self errorAlert:@"Parse error"];
		return;
	}
	user.fullName = xmlParserFullName;
	user.location = xmlParserLocation;
	user.web = xmlParserWeb;
	session.user = user;
	settings = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:managedObjectContext];
	session.settings = settings;
	if (![managedObjectContext save:&error]) {
		NSLog(@"Error saving managed object context: %@", [error localizedDescription]);
		[self errorAlert:@"Save error"];
		return;
	}
	//MVR - free xml parser strings
	self.xmlParserMutableString = nil;
	self.xmlParserAuthenticationToken = nil;
	self.xmlParserId = nil;
	self.xmlParserUsername = nil;
	self.xmlParserAvatarFileName = nil;
	self.xmlParserBio = nil;
	self.xmlParserFullName = nil;
	self.xmlParserLocation = nil;
	self.xmlParserWeb = nil;
	//MVR - sign in to the root view controller
	//AS DESIGNED: use delegate to avoid compiler warning
	[delegate signIn];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	xmlParserInBlogcastrUser = NO;
	xmlParserInSetting = NO;
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqual:@"blogcastr-user"]) {
		xmlParserInBlogcastrUser = YES;	
	}
	else if (xmlParserInBlogcastrUser && [elementName isEqual:@"setting"]) {
		xmlParserInSetting = YES;		 
	}
	//AS DESIGNED: no need to use a stack to save state this works
	self.xmlParserMutableString = nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (xmlParserInBlogcastrUser) {
		if (xmlParserInSetting) {
			if ([elementName isEqual:@"setting"])
				xmlParserInSetting = NO;
			else if ([elementName isEqual:@"avatar-file-name"])
				self.xmlParserAvatarFileName = xmlParserMutableString;
			else if ([elementName isEqual:@"bio"])
				self.xmlParserBio = xmlParserMutableString;
			else if ([elementName isEqual:@"full-name"])
				self.xmlParserFullName = xmlParserMutableString;
			else if ([elementName isEqual:@"location"])
				self.xmlParserLocation = xmlParserMutableString;
			else if ([elementName isEqual:@"web"])
				self.xmlParserWeb = xmlParserMutableString;
		}
		else {
			if ([elementName isEqual:@"blogcastr-user"])
				xmlParserInBlogcastrUser = NO;
			else if ([elementName isEqual:@"authentication-token"])
				self.xmlParserAuthenticationToken = xmlParserMutableString;
			else if ([elementName isEqual:@"id"])
				self.xmlParserId = xmlParserMutableString;
			else if ([elementName isEqual:@"username"])
				self.xmlParserUsername = xmlParserMutableString;
		}
	}
	NSLog(@"retain before inside %d",[xmlParserMutableString retainCount]);
	self.xmlParserMutableString = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!xmlParserMutableString)
        xmlParserMutableString = [[NSMutableString alloc] init];
    [xmlParserMutableString appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Error parsing XML: %@", [parseError localizedDescription]);
	[self errorAlert:@"Parse error"];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)theProgressHUD {
	//MVR - remove HUD from screen when the HUD was hidden
	[theProgressHUD removeFromSuperview];
}

#pragma mark -
#pragma mark Error handling

- (void)errorAlert:(NSString *)error {
	//MVR - display the alert view
	if (!alertView) {
		alertView = [[UIAlertView alloc] initWithTitle:error message:@"Oops! We couldn't sign you in." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	}
	else {
		alertView.title = error;
		alertView.message = @"Oops! We couldn't sign you in.";
	}
	[alertView show];
}

@end

