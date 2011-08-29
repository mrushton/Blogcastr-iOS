//
//  DatePickerController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/25/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "DatePickerController.h"
#import "BlogcastrStyleSheet.h"


@implementation DatePickerController


@synthesize tableView;
@synthesize date;
@synthesize delegate;
@synthesize datePicker;

//MVR - height when printed is 216.0 but it appears to be incorrect
static const CGFloat kDatePickerHeight = 260.0;

#pragma mark -
#pragma mark Init

- (id)init {
    self = [super init];
    if (self)
		self.navigationItem.title = @"Starting";

    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	UITableView *theTableView;
	UIDatePicker *theDatePicker;
	
    [super viewDidLoad];
	//MVR - table view
	theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - kDatePickerHeight) style:UITableViewStyleGrouped];
	theTableView.dataSource = self;
	theTableView.delegate = self;	
	theTableView.backgroundColor = TTSTYLEVAR(backgroundColor);
	[self.view addSubview:theTableView];
	self.tableView = theTableView;
	[theTableView release];
	//MVR - date picker
	theDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height - kDatePickerHeight, self.view.bounds.size.width, kDatePickerHeight)];
	[theDatePicker addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventValueChanged];
	if (date)
		theDatePicker.date = date;
	[self.view addSubview:theDatePicker];
	self.datePicker = theDatePicker;
	[theDatePicker release];
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
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
    // Configure the cell...
    
	//AS DESIGNED: only one no need to make it reusable
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
	if (indexPath.section == 0 && indexPath.row == 0) {
			cell.textLabel.text = @"Starting";
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		if (date) {
			NSDateFormatter *dateFormatter;
			
			dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"E, MMM d h:mm a"];
			cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
		} else {
			cell.detailTextLabel.text = @"Now";
		}
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
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (void)dateSelected:(id)object {
	self.date = datePicker.date;
	[tableView reloadData];
	if ([delegate respondsToSelector:@selector(dateSelected:)])
		[delegate dateSelected:date];
}

@end

