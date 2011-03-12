//
//  SettingsController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 2/22/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "SettingsController.h"
#import "AppDelegate_Shared.h"
#import "Session.h"


@implementation SettingsController


@synthesize managedObjectContext;
@synthesize session;
@synthesize alertView;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
		self.tabBarItem.title = @"Settings";
		self.tableView.backgroundColor = [UIColor colorWithRed:0.914 green:0.914 blue:0.914 alpha:1.0];
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

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
			return 2;
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
			[theSwitch setOn:[session.settings.saveOriginalImages boolValue] animated:NO];
			[theSwitch addTarget:self action:@selector(saveOriginalImages:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = theSwitch;
		}
		else {
			cell.textLabel.text = @"Change avatar";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else {
		cell.textLabel.text = @"Version";
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d.%d", VERSION_MAJOR, VERSION_MINOR];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	//cell.backgroundColor = [UIColor whiteColor];
	//cell.detailTextLabel.text = [NSString stringWithFormat:@"%d.%d", VERSION_MAJOR, VERSION_MINOR];


	/*
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
    */
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
	if (indexPath.section == 0 && indexPath.row == 1) {
			
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
	if (alertView)
		self.alertView = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Settings

- (void)saveOriginalImages:(UISwitch *)theSwitch {
	NSError *error;

	NSLog(@"MVR - saving settings %i",[session.settings.saveOriginalImages intValue]);
	session.settings.saveOriginalImages = [NSNumber numberWithBool:theSwitch.on];
	if (![managedObjectContext save:&error]) {
		NSLog(@"Error saving managed object context: %@", [error localizedDescription]);
		[self errorAlert:@"Save error"];
		return;
	}
}

#pragma mark -
#pragma mark Error handling

- (void)errorAlert:(NSString *)error {
	//MVR - display the alert view
	if (!alertView) {
		alertView = [[UIAlertView alloc] initWithTitle:error message:@"Oops! We couldn't save your settings." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	}
	else {
		alertView.title = error;
		alertView.message = @"Oops! We couldn't save your settings.";
	}
	[alertView show];
}

@end

