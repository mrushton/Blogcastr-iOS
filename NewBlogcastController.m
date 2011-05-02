//
//  NewBlogcastController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/23/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "NewBlogcastController.h"
#import "BlogcastrStyleSheet.h"
#import "DatePickerController.h"
#import "TextViewWithPlaceholder.h"
#import "ASIFormDataRequest.h"


@implementation NewBlogcastController


@synthesize managedObjectContext;
@synthesize session;
@synthesize titleTextField;
@synthesize startingAt;
@synthesize descriptionTextView;
@synthesize tagsTextView;
@synthesize progressHud;
@synthesize alertView;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
		UIBarButtonItem *cancelButton;
		UIBarButtonItem *createButton;
        
		// Custom initialization.
		self.navigationItem.title = @"New Blogcast";
		cancelButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
		cancelButton.title = @"Cancel";
		self.navigationItem.leftBarButtonItem = cancelButton;
		[cancelButton release];
		createButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(create)];
		createButton.title = @"Create";
		self.navigationItem.rightBarButtonItem = createButton;
		[createButton release];
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	UITextField *theTitleTextField;
	TextViewWithPlaceholder *theDescriptionTextView;
	TextViewWithPlaceholder *theTagsTextView;
	
    [super viewDidLoad];
	self.tableView.backgroundColor = TTSTYLEVAR(backgroundColor);
	theTitleTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0, 0.0, 284.0, 43.0)];
	theTitleTextField.placeholder = @"Title";
	theTitleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	theTitleTextField.textColor = TTSTYLEVAR(blueTextColor);
	theTitleTextField.returnKeyType = UIReturnKeyNext;
	[theTitleTextField addTarget:self action:@selector(titleEntered:) forControlEvents:UIControlEventEditingDidEndOnExit];
	self.titleTextField = theTitleTextField;
	[theTitleTextField release];
	theDescriptionTextView = [[TextViewWithPlaceholder alloc] initWithFrame:CGRectMake(2.0, 4.0, 296.0, 92.0)];
	//MVR - slight hack with insets to make the top align a little nicer
	theDescriptionTextView.contentInset = UIEdgeInsetsMake(-4.0, 0.0, 0.0, 0.0);
	theDescriptionTextView.backgroundColor = [UIColor clearColor];	
	theDescriptionTextView.font = [UIFont systemFontOfSize:15.0];
	theDescriptionTextView.textColor = BLOGCASTRSTYLEVAR(blueTextColor);
	theDescriptionTextView.placeholder = @"(optional)";
	self.descriptionTextView = theDescriptionTextView;
	[theDescriptionTextView release];
	theTagsTextView = [[TextViewWithPlaceholder alloc] initWithFrame:CGRectMake(2.0, 4.0, 296.0, 72.0)];
	theTagsTextView.contentInset = UIEdgeInsetsMake(-4.0, 0.0, 0.0, 0.0);
	theTagsTextView.backgroundColor = [UIColor clearColor];	
	theTagsTextView.font = [UIFont systemFontOfSize:15.0];
	theTagsTextView.textColor = BLOGCASTRSTYLEVAR(blueTextColor);
	theTagsTextView.placeholder = @"(optional) comma separated";
	theTagsTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	theTagsTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.tagsTextView = theTagsTextView;
	[theTagsTextView release];
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
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 2;
		case 1:
			return 1;
		case 2:
			return 1;
		default:
			return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0)
		return 44.0;
	else if (indexPath.section == 1)
		return 100.0;
	else if (indexPath.section == 2)
		return 80.0;
	
	return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
	
    // Configure the cell...
    
	//AS DESIGNED: only a few cells no need to make them reusable
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell.contentView addSubview:titleTextField];
		} else if (indexPath.row == 1) {			
			cell.textLabel.text = @"Starting";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			//MVR - cascade of possible values
			if (startingAt) {
				NSDateFormatter *dateFormatter;

				dateFormatter = [[NSDateFormatter alloc] init];
				[dateFormatter setDateFormat:@"E, MMM d h:mm a"];
				cell.detailTextLabel.text = [dateFormatter stringFromDate:startingAt];
				[dateFormatter release];
			} else {
				cell.detailTextLabel.text = @"Now";
			}
		}
	} else if (indexPath.section == 1) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell.contentView addSubview:descriptionTextView];
	} else if (indexPath.section == 2) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell.contentView addSubview:tagsTextView];
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
		return @"Description";
	else if (section == 2)
		return @"Tags";

	return nil;
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
	if (indexPath.section == 0 && indexPath.row == 1) {
		DatePickerController *datePickerController;
		
		datePickerController = [[DatePickerController alloc] init];
		if (startingAt)
			datePickerController.date = startingAt;
		datePickerController.delegate = self;
		[self.navigationController pushViewController:datePickerController animated:YES];
	}
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
	self.titleTextField = nil;
	self.descriptionTextView = nil;
	self.tagsTextView = nil;
}

- (UIAlertView *)alertView {
	if (!_alertView) {
		_alertView = [[UIAlertView alloc] init];
		[_alertView addButtonWithTitle:@"Ok"];
	}
	
	return _alertView;
}

- (MBProgressHUD *)progressHud {
	if (!_progressHud) {
		//MVR - use superview to handle a display bug
		_progressHud = [[MBProgressHUD alloc] initWithView:self.view.superview];
		_progressHud.delegate = self;
	}
	
	return _progressHud;
}


- (void)dealloc {
	[_progressHud release];
	[_alertView release];
    [super dealloc];
}

#pragma mark -
#pragma mark DatePickerController delegate

- (void)dateSelected:(NSDate *)date {
	UITableViewCell *cell;
	
	self.startingAt = date;
	//MVR - only update the cell, some strange bug involving the keyboard occurs on full reload
	cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
	if (cell) {
		NSDateFormatter *dateFormatter;
		
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"E, MMM d h:mm a"];
		cell.detailTextLabel.text = [dateFormatter stringFromDate:startingAt];
		[dateFormatter release];
	}		
}

#pragma mark -
#pragma mark Actions


- (void)newBlogcastFinished:(ASIHTTPRequest *)request {
	NSLog(@"MVR - new blogcast finished");
}


- (void)newBlogcastFailed:(ASIHTTPRequest *)request {
	NSLog(@"MVR - new blogcast failed");

}

- (void)create {
	NSString *string;
	NSURL *url;
	ASIFormDataRequest *request;

	//MVR - check for errors
	if (!titleTextField.text || [titleTextField.text compare:@""] == NSOrderedSame) {
		[self errorAlertWithTitle:@"Enter title" message:@"Oops! You need to enter a title."];
		return;
	}
	//MVR - dismiss keyboard
	if (titleTextField.isFirstResponder)
		[titleTextField resignFirstResponder];
	else if (descriptionTextView.isFirstResponder)
		[descriptionTextView resignFirstResponder];
	else if (tagsTextView.isFirstResponder)
		[tagsTextView resignFirstResponder];
	[self showProgressHudWithLabelText:@"Creating blogcast..." animated:YES animationType:MBProgressHUDAnimationZoom];
	request = [ASIFormDataRequest requestWithURL:[self newBlogcastUrl]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(newBlogcastFinished:)];
	[request setDidFailSelector:@selector(newBlogcastFailed:)];
	[request addPostValue:session.authenticationToken forKey:@"authentication_token"];
	[request addPostValue:titleTextField.text forKey:@"blogcast[title]"];
	if (startingAt) {
		NSDateFormatter *dateFormatter;
		
		dateFormatter = [[NSDateFormatter alloc] init];
		//MVR - year
		[dateFormatter setDateFormat:@"y"];
		[request addPostValue:[dateFormatter stringFromDate:startingAt] forKey:@"blogcast[starting_at(1i)]"];
		//MVR - month
		[dateFormatter setDateFormat:@"M"];
		[request addPostValue:[dateFormatter stringFromDate:startingAt] forKey:@"blogcast[starting_at(2i)]"];
		//MVR - day
		[dateFormatter setDateFormat:@"d"];
		[request addPostValue:[dateFormatter stringFromDate:startingAt] forKey:@"blogcast[starting_at(3i)]"];
		//MVR - hour (1-24)
		[dateFormatter setDateFormat:@"k"];
		[request addPostValue:[dateFormatter stringFromDate:startingAt] forKey:@"blogcast[starting_at(4i)]"];
		//MVR - minute
		[dateFormatter setDateFormat:@"m"];
		[request addPostValue:[dateFormatter stringFromDate:startingAt] forKey:@"blogcast[starting_at(5i)]"];
		[dateFormatter release];
	}
	if (descriptionTextView.text && [descriptionTextView.text compare:@""] != NSOrderedSame)
		[request addPostValue:descriptionTextView.text forKey:@"blogcast[description]"];
	if (tagsTextView.text && [tagsTextView.text compare:@""] != NSOrderedSame)
		[request addPostValue:tagsTextView.text forKey:@"tags"];
	[request startAsynchronous];
}

- (void)cancel {
	//TODO: need to cancel request as well
	[self dismissModalViewControllerAnimated:YES];
}

- (void)titleEntered:(id)object {
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES scrollPosition:UITableViewScrollPositionTop];
	//MVR - make description text view the first responder
	[descriptionTextView becomeFirstResponder];
}

#pragma mark -
#pragma mark Helpers

- (NSURL *)newBlogcastUrl {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [NSString stringWithFormat:@"http://sandbox.blogcastr.com/blogcasts.xml"];
#else //DEVEL
	string = [NSString stringWithFormat:@"http://blogcastr.com/blogcasts.xml"];
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

