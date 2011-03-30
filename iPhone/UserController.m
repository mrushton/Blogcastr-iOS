//
//  UserController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 3/5/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "UserController.h"
#import "ImageViewerController.h"


@implementation UserController


@synthesize managedObjectContext;
@synthesize session;
@synthesize user;
@synthesize tabToolbarController;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.backgroundColor = [UIColor colorWithRed:0.914 green:0.914 blue:0.914 alpha:1.0];
	self.tableView.tableFooterView = [self footerView];
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
	if (user.bio)
		return 2;
	else
		return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			if (user.web)
				return 2;
			else
				return 1;
		case 1:
			return 1;
		default:
			return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0){
		if (indexPath.row == 0)
			return 86.0;
		else if (indexPath.row == 1)
			return 44.0;
	} else if (indexPath.section == 1) {
		CGSize size;
		
		size = [user.bio sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(282.0, 100.0) lineBreakMode:UILineBreakModeWordWrap];
		return size.height + 19.0;
	}

	return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
	
    // Configure the cell...
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			CGRect rect;
			UILabel *label;

			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			TTButton *avatarButton = [TTButton buttonWithStyle:@"roundedAvatar:"];
			rect = CGRectMake(18.0, 9.0, 69.0, 69.0);
			avatarButton.frame = rect;
			[avatarButton addTarget:self action:@selector(pressAvatar:) forControlEvents:UIControlEventTouchUpInside];
			//MVR - image url based on screen resolution
			if ([[UIScreen mainScreen] scale] > 1.0)
				[avatarButton setImage:[self avatarUrlForSize:@"super"] forState:UIControlStateNormal];
			else
				[avatarButton setImage:[self avatarUrlForSize:@"large"] forState:UIControlStateNormal];
			[cell addSubview:avatarButton];
			rect = CGRectMake(95.0, 14.0, 207.0, 20.0);
			label = [[UILabel alloc] initWithFrame:rect];
			label.text = user.fullName;
			label.textColor = [UIColor colorWithRed:0.176 green:0.322 blue:0.408 alpha:1.0];
			label.font = [UIFont boldSystemFontOfSize:20.0];
			[cell addSubview:label];
			[label release];
			if (user.location) {
				rect = CGRectMake(95.0, 37.0, 207.0, 18.0);
				label = [[UILabel alloc] initWithFrame:rect];
				label.text = user.location;
				label.textColor = [UIColor colorWithRed:0.31 green:0.31 blue:0.31 alpha:1.0];
				label.font = [UIFont fontWithName:@"Georgia-Italic" size:15.0];
				[cell addSubview:label];
				[label release];
			}
		} else if (indexPath.row == 1) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
			cell.textLabel.text = @"Web";
			cell.detailTextLabel.text = user.web;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	} else if (indexPath.section == 1) {
		CGSize size;
		CGRect rect;
		UILabel *label;
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		//MVR - determine the height of the bio
		size = [user.bio sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(282.0, 100.0) lineBreakMode:UILineBreakModeWordWrap];
		rect = CGRectMake(19.0, 10.0, 282.0, size.height);
		label = [[UILabel alloc] initWithFrame:rect];
		label.text = user.bio;
		label.font = [UIFont systemFontOfSize:14.0];
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.numberOfLines = 0;
		[cell addSubview:label];
	}

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 1)
		return @"Bio";
	else
		return nil;
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
	if (indexPath.section == 0) {
		if (indexPath.row == 1) {
			TTWebController *webController;

			webController = [[TTWebController alloc] init];
			[webController openURL:[NSURL URLWithString:user.web]];
			[self.tabToolbarController.navigationController pushViewController:webController animated:YES];
		}
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (NSString *)avatarUrlForSize:(NSString *)size {
	NSString *avatarUrl;
	NSRange range;
	
#ifdef DEVEL
	avatarUrl = [NSString stringWithFormat:@"http://sandbox.blogcastr.com%@", user.avatarUrl];
#else //DEVEL
	avatarUrl = [[user.avatarUrl copy] autorelease];
#endif //DEVEL
	range = [avatarUrl rangeOfString:@"small"];
	if (range.location != NSNotFound) {
		return [avatarUrl stringByReplacingCharactersInRange:range withString:size];
	} else {
		NSLog(@"Error replacing size in avatar url: %@", avatarUrl);
		return avatarUrl;
	}
}

- (TTView *)statViewFor:(NSString *)name value:(NSNumber *)value {
	TTStyleSheet *styleSheet;
	TTView *statView;
	UILabel *statValueLabel;
	UILabel *statNameLabel;
	
	styleSheet = [TTStyleSheet globalStyleSheet];
	statView = [[[TTView alloc] initWithFrame:CGRectMake(0.0, 0.0, 146.0, 36.0)] autorelease];
	statView.backgroundColor = [UIColor clearColor];
	statView.style = [styleSheet styleWithSelector:(NSString *)@"statView:"];
	statValueLabel = [[UILabel alloc] init];
	statValueLabel.text = [NSString stringWithFormat:@"%d", [value intValue]];
	statValueLabel.font = [UIFont boldSystemFontOfSize:15.0];
	statValueLabel.textColor = [UIColor colorWithRed:0.176 green:0.322 blue:0.408 alpha:1.0];
	statValueLabel.backgroundColor = [UIColor clearColor];
	statValueLabel.center = CGPointMake(8.0, 6.0);
	[statValueLabel sizeToFit];
	[statView addSubview:statValueLabel];
	statNameLabel = [[UILabel alloc] init];
	statNameLabel.text = name;
	statNameLabel.font = [UIFont boldSystemFontOfSize:10.0];
	statNameLabel.textColor = [UIColor colorWithRed:0.565 green:0.565 blue:0.565 alpha:1.0];
	statNameLabel.shadowColor = [UIColor whiteColor];
	statNameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	statNameLabel.backgroundColor = [UIColor clearColor];
	statNameLabel.center = CGPointMake(statValueLabel.bounds.size.width + 12.0, 9.0);
	[statNameLabel sizeToFit];
	[statValueLabel release];
	[statView addSubview:statNameLabel];
	[statNameLabel release];
	
	return statView;
}

- (UIView *)footerView {
	TTStyleSheet *styleSheet;
	UIView *footerView;
	UILabel *statsLabel;
	TTView *statView;
	
	styleSheet = [TTStyleSheet globalStyleSheet];
	footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 161.0)] autorelease];
	//MVR - set up stat views
	statsLabel = [[UILabel alloc] init];
	statsLabel.text = @"Stats";
	statsLabel.font = [UIFont boldSystemFontOfSize:17.0];
	statsLabel.textColor = [UIColor colorWithRed:0.298 green:0.337 blue:0.421 alpha:1.0];
	statsLabel.shadowColor = [UIColor whiteColor];
	statsLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	statsLabel.backgroundColor = [UIColor clearColor];
	statsLabel.center = CGPointMake(19.0, 6.0);
	[statsLabel sizeToFit];
	[footerView addSubview:statsLabel];
	[statsLabel release];
	//MVR - blogcasts
	statView = [self statViewFor:@"BLOGCASTS" value:user.numBlogcasts];
	statView.frame = CGRectOffset(statView.frame, 9.0, 36.0);
	[footerView addSubview:statView];
	//MVR - subscriptions
	statView = [self statViewFor:@"SUBSCRIPTIONS" value:user.numSubscriptions];
	statView.frame = CGRectOffset(statView.frame, 165.0, 36.0);
	[footerView addSubview:statView];
	//MVR - subscribers
	statView = [self statViewFor:@"SUBSCRIBERS" value:user.numSubscribers];
	statView.frame = CGRectOffset(statView.frame, 9.0, 76.0);
	[footerView addSubview:statView];
	//MVR - posts
	statView = [self statViewFor:@"POSTS" value:user.numPosts];
	statView.frame = CGRectOffset(statView.frame, 165.0, 76.0);
	[footerView addSubview:statView];
	//MVR - comments
	statView = [self statViewFor:@"COMMENTS" value:user.numComments];
	statView.frame = CGRectOffset(statView.frame, 9.0, 116.0);
	[footerView addSubview:statView];
	//MVR - likes
	statView = [self statViewFor:@"LIKES" value:user.numLikes];
	statView.frame = CGRectOffset(statView.frame, 165.0, 116.0);
	[footerView addSubview:statView];
	
	return footerView;
}

#pragma mark -
#pragma mark Avatar

- (void)pressAvatar:(id)object {
	TTImageView *imageView;
	ImageViewerController *imageViewerController;
	
	imageView = [[TTImageView alloc] init];
	[imageView setUrlPath:[self avatarUrlForSize:@"original"]];
	imageViewerController = [[ImageViewerController alloc] initWithImageView:imageView];
	[imageView release];
	[self.tabToolbarController.navigationController pushViewController:imageViewerController animated:YES];
}

@end

