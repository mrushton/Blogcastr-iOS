//
//  BlogcastsController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/2/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "BlogcastsController.h"
#import "DashboardController.h"
#import "PostsController.h"
#import "CommentsController.h"
#import "InfoController.h"
#import "BlogcastrTableViewCell.h"
#import "BlogcastsParser.h"
#import "Blogcast.h"
#import "BlogcastStreamCell.h"
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "BlogcastrStyleSheet.h"
#import "NSDate+Timestamp.h"
#import "XMPPRoom.h"

@implementation BlogcastsController

@synthesize tabToolbarController;
@synthesize managedObjectContext;
@synthesize session;
@synthesize user;
@synthesize xmppStream;
@synthesize dragRefreshView;
@synthesize infiniteScrollView;

//MVR - the number of pixels the table needs to be pulled down by in order to initiate the refresh
static const CGFloat kRefreshDeltaY = -65.0f;
static const CGFloat kInfiniteScrollViewHeight = 40.0;
static const NSInteger kBlogcastsRequestCount = 20;

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	if (self) {
		UIImage *image;
		UITabBarItem *theTabBarItem;
		
        // Custom initialization.
		image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blogcasts" ofType:@"png"]];
		theTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Blogcasts" image:image tag:0];
		self.tabBarItem = theTabBarItem;
		[theTabBarItem release];		
		//MVR - created blogcast notification
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createdBlogcast) name:@"createdBlogcast" object:nil];
	}
	
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	UIView *footerBorderView;
	NSError *error;

    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.backgroundColor = TTSTYLEVAR(backgroundColor);
	self.tableView.separatorColor = BLOGCASTRSTYLEVAR(tableViewSeperatorColor);
	dragRefreshView = [[TTTableHeaderDragRefreshView alloc] initWithFrame:CGRectMake(0, -self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
	//dragRefreshView.backgroundColor = TTSTYLEVAR(tableRefreshHeaderBackgroundColor);
	[dragRefreshView setStatus:TTTableHeaderDragRefreshPullToReload];
    [self.tableView addSubview:dragRefreshView];
	//MVR - set footer view to infinite scroll view
	infiniteScrollView = [[TTTableFooterInfiniteScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, kInfiniteScrollViewHeight)];
	infiniteScrollView.backgroundColor = TTSTYLEVAR(backgroundColor);
	infiniteScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	if (![user.blogcastsAtEnd boolValue])
		[infiniteScrollView setLoading:YES];
	footerBorderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, infiniteScrollView.bounds.size.width, 1.0)];
	footerBorderView.backgroundColor = BLOGCASTRSTYLEVAR(lightBackgroundColor);
	[infiniteScrollView addSubview:footerBorderView];
	[footerBorderView release];
	self.tableView.tableFooterView = infiniteScrollView;
	if (user.blogcastsUpdatedAt)
		[dragRefreshView setUpdateDate:user.blogcastsUpdatedAt];
	//MVR - timer updates table view every 10 seconds
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reloadTableView) userInfo:nil repeats:YES];	
	//MVR - now fetch blogcasts
	if (![self.fetchedResultsController performFetch:&error])
		NSLog(@"Perform fetch failed with error: %@", [error localizedDescription]);
	//TODO: viewDIdUnload
}


- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
	//MVR - update blogcasts if it's the first time or been longer than a day
	if ((!user.blogcastsUpdatedAt || [user.blogcastsUpdatedAt timeIntervalSinceNow] < -86400.0) && isUpdating == NO) {
		isUpdating = YES;
		[self updateBlogcasts];
/*		[dragRefreshView setStatus:TTTableHeaderDragRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
		self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];*/
	}
}

- (void)updateBlogcasts {
	NSURL *url;
	ASIHTTPRequest *request;
	
	url = [self blogcastsUrlWithMaxId:0 count:kBlogcastsRequestCount];	
	request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(updateBlogcastsFinished:)];
	[request setDidFailSelector:@selector(updateBlogcastsFailed:)];
	[request startAsynchronous];
}

- (void)updateBlogcastsFinished:(ASIHTTPRequest *)request {
	int statusCode;
	NSInteger numAdded = 0;
	BlogcastsParser *parser;

	isUpdating = NO;
	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error update blogcasts received status code %i", statusCode);
		[self errorAlertWithTitle:@"Update failed" message:@"Oops! We couldn't update your blogcasts."];
		return;
	}
	//MVR - parse xml
	parser = [[BlogcastsParser alloc] initWithData:[request responseData] managedObjectContext:managedObjectContext];
	if (![parser parse]) {
		NSLog(@"Error parsing update blogcasts response");
		[self errorAlertWithTitle:@"Parse error" message:@"Oops! We couldn't update your blogcasts."];
		[parser release];
		return;
	}
	//MVR - add blogcasts above max id
	for (Blogcast *blogcast in parser.blogcasts) {
		if ([blogcast.id intValue] > [self.maxId intValue]) {
			BlogcastStreamCell *streamCell;
			
			streamCell = [NSEntityDescription insertNewObjectForEntityForName:@"BlogcastStreamCell" inManagedObjectContext:managedObjectContext];
			streamCell.id = blogcast.id;
			streamCell.blogcast = blogcast;
			streamCell.user = user;
			numAdded++;
		}
	}
	//MVR - handle either the footer scroll or cell scroll
	if ([self.maxId intValue] == 0) {
		if (numAdded < kBlogcastsRequestCount) {
			user.blogcastsAtEnd = [NSNumber numberWithBool:YES];
			[infiniteScrollView setLoading:NO];
		} else {
			Blogcast *blogcast;

			//MVR - update min id if there may be more to load
			blogcast = [parser.blogcasts objectAtIndex:numAdded - 1];
			self.minId = blogcast.id;
		}
	} else if (numAdded == kBlogcastsRequestCount) {
		Blogcast *blogcast;

		blogcast = [parser.blogcasts objectAtIndex:kBlogcastsRequestCount - 1];
		//MVR - add one to make sure there is actually a gap
		if (blogcast.id > self.maxId + 1) {
			//TODO: add a scrolling cell
			//id = blogcast.id - 1
			//minId = self.maxId + 1
		}
	}
	//MVR - update max id
	if (numAdded > 0) {
		Blogcast *blogcast;

		blogcast = [parser.blogcasts objectAtIndex:0];
		self.maxId = blogcast.id;
	}
	user.blogcastsUpdatedAt = [NSDate date];
	[dragRefreshView setUpdateDate:user.blogcastsUpdatedAt];
	if (isRefreshing) {
		[dragRefreshView setStatus:TTTableHeaderDragRefreshPullToReload];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
		self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
		isRefreshing = NO;
	}
	//TODO: handle save failure gracefully
	[self save];
}

- (void)updateBlogcastsFailed:(ASIHTTPRequest *)request {
	NSLog(@"Error update blogcasts failed");
	[self errorAlertWithTitle:@"Update failed" message:@"Oops! We couldn't update your blogcasts."];
	isUpdating = NO;
	if (isRefreshing) {
		[dragRefreshView setStatus:TTTableHeaderDragRefreshPullToReload];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
		self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
		isRefreshing = NO;
	}
}

- (void)updateBlogcastsFooter {
	NSURL *url;
	ASIHTTPRequest *request;
	
	isUpdatingFooter = YES;
	url = [self blogcastsUrlWithMaxId:[self.minId intValue] - 1 count:kBlogcastsRequestCount];	
	request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(updateBlogcastsFooterFinished:)];
	[request setDidFailSelector:@selector(updateBlogcastsFooterFailed:)];
	[request startAsynchronous];
}

- (void)updateBlogcastsFooterFinished:(ASIHTTPRequest *)request {
	int statusCode;
	NSInteger numAdded = 0;
	BlogcastsParser *parser;
	
	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error update blogcasts footer received status code %i", statusCode);
		[self errorAlertWithTitle:@"Update failed" message:@"Oops! We couldn't update your blogcasts."];
		return;
	}
	//MVR - parse response
	parser = [[BlogcastsParser alloc] initWithData:[request responseData] managedObjectContext:managedObjectContext];
	if (![parser parse]) {
		NSLog(@"Error parsing update blogcasts response");
		[self errorAlertWithTitle:@"Parse error" message:@"Oops! We couldn't update your blogcasts."];
		[parser release];
		return;
	}
	//MVR - add blogcasts above max id
	for (Blogcast *blogcast in parser.blogcasts) {
		if ([blogcast.id integerValue] < [self.minId integerValue]) {
			BlogcastStreamCell *streamCell;
			
			streamCell = [NSEntityDescription insertNewObjectForEntityForName:@"BlogcastStreamCell" inManagedObjectContext:managedObjectContext];
			streamCell.id = blogcast.id;
			streamCell.blogcast = blogcast;
			streamCell.user = user;
			numAdded++;
		}
	}
	//MVR - handle the footer scroll
	if (numAdded < kBlogcastsRequestCount) {
		user.blogcastsAtEnd = [NSNumber numberWithBool:YES];
		[infiniteScrollView setLoading:NO];
	} else {
		Blogcast *blogcast;

		blogcast = [parser.blogcasts objectAtIndex:kBlogcastsRequestCount - 1];
		self.minId = blogcast.id;
	}
	isUpdatingFooter = NO;
	[self save];
	[parser release];
}

- (void)updateBlogcastsFooterFailed:(ASIHTTPRequest *)request {
	
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	BlogcastStreamCell *streamCell;
	Blogcast *blogcast;
	
	streamCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
	blogcast = streamCell.blogcast;	
	if (blogcast.theDescription) {
		NSString *text;
		TTStyledTextLabel *styledText;

		text = [NSString stringWithFormat:@"<b>%@</b> <span class=\"blueText\">%@</span>  <span class=\"timestampInWords\">%@<span>", user.username, blogcast.theDescription, [blogcast.startingAt stringInWords]]; 
		styledText = [[[TTStyledTextLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 275.0, 0.0)] autorelease];
		styledText.contentInset = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0);
		styledText.textAlignment = UITextAlignmentLeft;
		styledText.font = [UIFont systemFontOfSize:13.0];
		styledText.text = [TTStyledText textFromXHTML:text lineBreaks:YES URLs:NO];
		[styledText sizeToFit];
		if (styledText.bounds.size.height > 20.0)
			return styledText.bounds.size.height + 31.0;		
	}

	return 50.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo;

	// Return the number of rows in the section.
	sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];

	return [sectionInfo numberOfObjects];
}

#define TITLE_LABEL_TAG 7
#define IMAGE_VIEW_TAG 1
#define STYLED_TEXT_TAG 8
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	BlogcastStreamCell *streamCell;
	Blogcast *blogcast;
    BlogcastrTableViewCell *cell;
	TTImageView *imageView;
	UILabel *titleLabel;
	NSString *text;
	TTStyledTextLabel *styledText;

//	NSLog(@"MVR - setting up table view cell");
	// Set up the cell...
	streamCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
	blogcast = streamCell.blogcast;
    cell = (BlogcastrTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Blogcast"];
	//MVR - if cell doesn't exist create it
    if (!cell) {	
		cell = [[[BlogcastrTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Blogcast"] autorelease];
		imageView = [[TTImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 40.0, 40.0)];
		imageView.tag = IMAGE_VIEW_TAG;
		[cell.contentView insertSubview:imageView belowSubview:cell.highlightView];
		[imageView release];
		
		

		
		
		/*@"This is a test of styled labels.  Styled labels support \
		<b>bold text</b>, <i>italic text</i>, <span class=\"blueText\">colored text</span>, \
		<span class=\"largeText\">font sizes</span>, \
		<span class=\"blueBox\">spans with backgrounds</span>, inline images \
		<img src=\"bundle://smiley.png\"/>, and <a href=\"http://www.google.com\">hyperlinks</a> you can \
		actually touch. URLs are automatically converted into links, like this: http://www.foo.com\
		<div>You can enclose blocks within an HTML div.</div>\
		Both line break characters\n\nand HTML line breaks<br/>are respected.";*/
		
		styledText = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(45.0, 25.0, 275.0, 0.0)];
		styledText.contentInset = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0);
		styledText.textAlignment = UITextAlignmentLeft;
		styledText.font = [UIFont systemFontOfSize:13.0];
		styledText.tag = STYLED_TEXT_TAG;
		//styledText.backgroundColor = [UIColor grayColor];
		[cell.contentView insertSubview:styledText belowSubview:cell.highlightView];

		[styledText release];

		
		//MVR - set up the cell
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 5.0, 252.0, 20.0)];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = [UIColor colorWithRed:0.159 green:0.226 blue:0.311 alpha:1.0];//[UIColor colorWithRed:0.176 green:0.322 blue:0.408 alpha:1.0];
		titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
		titleLabel.tag = TITLE_LABEL_TAG;
		titleLabel.text = [NSString stringWithFormat:@"%@", blogcast.title];

		[cell.contentView insertSubview:titleLabel belowSubview:cell.highlightView];


		[titleLabel release];
	/*	if (blogcast.description) {
			description = [[UILabel alloc] initWithFrame:CGRectMake(52.0, 22.0, 264.0, 20)];
			description.tag = DESCRIPTION_VIEW_TAG;
			description.font = [description.font fontWithSize:12.0];
			description.backgroundColor = [UIColor clearColor];
			description.highlightedTextColor = [UIColor whiteColor];
			description.lineBreakMode = UILineBreakModeWordWrap;
			description.numberOfLines = 0;
			[cell.contentView addSubview:description];
		} else {
			description = nil;
		}
	*/
		//MVR - add to cell
	} else {
		NSLog(@"MVR - FINDGIN TITLE");
		titleLabel = (UILabel *)[cell viewWithTag:TITLE_LABEL_TAG];
		imageView = (TTImageView *)[cell viewWithTag:IMAGE_VIEW_TAG];
		styledText = (TTStyledTextLabel *)[cell viewWithTag:STYLED_TEXT_TAG];
		//description = (UILabel *)[cell viewWithTag:DESCRIPTION_VIEW_TAG];

	}
	//MVR - image url based on screen resolution
	if ([[UIScreen mainScreen] scale] > 1.0)
		imageView.urlPath = [self avatarUrlForSize:@"super"];
	else
		imageView.urlPath = [self avatarUrlForSize:@"small"];
	if (!titleLabel)
		NSLog(@"TITLE IS NIL!");
	titleLabel.text = [NSString stringWithFormat:@"%@", blogcast.title];
	NSLog(@"MVR - BLOGCAST TITEL IN CELL %@ %@",titleLabel.text,blogcast.title);
	if ([titleLabel isDescendantOfView:cell])
		NSLog(@"MVR - IS DESCENDANT");
	else
		NSLog(@"MVR - IS NOT DESCENDANT");

	if (blogcast.theDescription)
		text = [NSString stringWithFormat:@"<b>%@</b> <span class=\"blueText\">%@</span>  <span class=\"timestampInWords\">%@<span>", user.username, blogcast.theDescription, [blogcast.startingAt stringInWords]]; 
	else
		
		text = [NSString stringWithFormat:@"<b>%@</b>  <span class=\"timestampInWords\">%@<span>", user.username, [blogcast.startingAt stringInWords]]; 

	styledText.text = [TTStyledText textFromXHTML:text lineBreaks:YES URLs:NO];

	[styledText sizeToFit];


	//if (description)
	//	description.text = [NSString stringWithFormat:@"%@", blogcast.description];
	
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
	BlogcastStreamCell *streamCell;
	Blogcast *blogcast;
	DashboardController *dashboardController;
	PostsController *postsController;
	CommentsController *commentsController;
	InfoController *infoController;
	XMPPRoom *xmppRoom;
	NSString *roomName;
	NSString *nickname;

    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
	streamCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
	blogcast = streamCell.blogcast;
	dashboardController = [[DashboardController alloc] init];
	dashboardController.session = session;
	dashboardController.blogcast = blogcast;
	dashboardController.xmppStream = xmppStream;
	[xmppStream addDelegate:dashboardController];
	dashboardController.title = blogcast.title;
	//MVR - set up MUC room
#ifdef DEVEL
	roomName = [NSString stringWithFormat:@"blogcast.%d@conference.sandbox.blogcastr.com", [blogcast.id intValue]];
#else //DEVEL
	roomName = [NSString stringWithFormat:@"blogcast.%d@conference.blogcastr.com", [blogcast.id intValue]];
#endif //DEVEL
	//MVR - add a timestamp to the nickname to make it unique and work around reconnect issues
	nickname = xmppStream.myJID.resource;
	xmppRoom = [[XMPPRoom alloc] initWithStream:xmppStream roomName:roomName nickName:nickname];
	xmppRoom.delegate = dashboardController;
	dashboardController.xmppRoom = xmppRoom;
	[xmppRoom release];
	//MVR - create each tab
	postsController = [[PostsController alloc] initWithNibName:nil bundle:nil];
	postsController.managedObjectContext = self.managedObjectContext;
	postsController.session = session;
	postsController.blogcast = blogcast;
	postsController.xmppStream = xmppStream;
	[xmppStream addDelegate:postsController];
	//MVR - XMPP notifications
	[[NSNotificationCenter defaultCenter] addObserver:postsController selector:@selector(joinedRoom) name:@"joinedRoom" object:dashboardController];
	[[NSNotificationCenter defaultCenter] addObserver:postsController selector:@selector(leftRoom) name:@"leftRoom" object:dashboardController];
	//postsController.tabBarItem.title = @"Posts";
	commentsController = [[CommentsController alloc] initWithStyle:UITableViewStylePlain];
	commentsController.managedObjectContext = self.managedObjectContext;
	commentsController.session = session;
	commentsController.blogcast = blogcast;
	commentsController.xmppStream = xmppStream;
	[xmppStream addDelegate:commentsController];
	commentsController.tabBarItem.title = @"Comments";
	//MVR - XMPP notifications
	[[NSNotificationCenter defaultCenter] addObserver:commentsController selector:@selector(joinedRoom) name:@"joinedRoom" object:dashboardController];
	[[NSNotificationCenter defaultCenter] addObserver:commentsController selector:@selector(leftRoom) name:@"leftRoom" object:dashboardController];
	infoController = [[InfoController alloc] initWithStyle:UITableViewStyleGrouped];
	infoController.managedObjectContext = self.managedObjectContext;
	infoController.session = session;
	infoController.blogcast = blogcast;
	infoController.tabBarItem.title = @"Info";
	dashboardController.viewControllers = [NSArray arrayWithObjects:postsController, commentsController, infoController, nil];
	[postsController release];
	[commentsController release];
	[infoController release];
	[tabToolbarController.navigationController pushViewController:dashboardController animated:YES];
	//MVR - connect to MUC room
	[dashboardController connect];
	[dashboardController release];
}


#pragma mark -
#pragma mark Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	NSIndexPath *indexPath;

	//MVR - deselect highlighted table cells
	indexPath = [self.tableView indexPathForSelectedRow];
	if (indexPath)
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	if (scrollView.dragging && !isRefreshing) {
		if (scrollView.contentOffset.y > kRefreshDeltaY && scrollView.contentOffset.y < 0.0)
			[dragRefreshView setStatus:TTTableHeaderDragRefreshPullToReload];
		else if (scrollView.contentOffset.y < kRefreshDeltaY)
			[dragRefreshView setStatus:TTTableHeaderDragRefreshReleaseToReload];
	}
	//MVR - footer logic
	if (scrollView.contentOffset.y > scrollView.contentSize.height - kInfiniteScrollViewHeight - scrollView.bounds.size.height && ![user.blogcastsAtEnd boolValue] && !isUpdatingFooter && self.minId > 0)
		[self updateBlogcastsFooter];
}	

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	// If dragging ends and we are far enough to be fully showing the header view trigger a
	// load as long as we arent loading already
	if (scrollView.contentOffset.y <= kRefreshDeltaY) {
		//MVR - decouple the drag refresh and the actual update since updates can happen on their own
		if (!isRefreshing) {
			isRefreshing = YES;
			[dragRefreshView setStatus:TTTableHeaderDragRefreshLoading];
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
			self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
			[UIView commitAnimations];
		}
		if (!isUpdating) {
			isUpdating = YES;
			[self updateBlogcasts];
		}
	}
}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
	float systemVersion;
	
	//AS DESIGNED: work around 3.* UITableView bug
	systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	if (systemVersion >= 4.0) {
		[[self tableView] beginUpdates];
	}
}

- (void)controller:(NSFetchedResultsController*)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
	float systemVersion;
	
	//AS DESIGNED: work around 3.* UITableView bug
	systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	if (systemVersion >= 4.0) {
		switch(type) {
			case NSFetchedResultsChangeInsert:
				[[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
								withRowAnimation:UITableViewRowAnimationFade];
				break;
			case NSFetchedResultsChangeDelete:
				[[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
								withRowAnimation:UITableViewRowAnimationFade];
				break;
		}
	}
}

- (void)controller:(NSFetchedResultsController*)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath*)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath*)newIndexPath
{
	float systemVersion;
	
	//AS DESIGNED: work around 3.* UITableView bug
	systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	if (systemVersion >= 4.0) {
		switch(type) {
			case NSFetchedResultsChangeInsert:
				[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
										withRowAnimation:UITableViewRowAnimationFade];
				break;
			case NSFetchedResultsChangeDelete:
				[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
										withRowAnimation:UITableViewRowAnimationFade];
				break;
			case NSFetchedResultsChangeUpdate:
				//[self configureCell:[[self tableView] cellForRowAtIndexPath:indexPath]
				//						atIndexPath:indexPath];
				break;
			case NSFetchedResultsChangeMove:
				[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
										withRowAnimation:UITableViewRowAnimationFade];
				[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
										withRowAnimation:UITableViewRowAnimationFade];
				break;
		}
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
	float systemVersion;
	
	//AS DESIGNED: work around 3.* UITableView bug
	systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	if (systemVersion >= 4.0) {
		[[self tableView] endUpdates];
	}
	else
	{
		//AS DESIGNED: this will not be animated but it's the easiest work around for the 3.x UITableView bug
		[[self tableView] reloadData];
	}
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)theProgressHUD {
	//MVR - remove HUD from screen when the HUD was hidden
	[theProgressHUD removeFromSuperview];
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
	[dragRefreshView release];
}


- (void)dealloc {
	[managedObjectContext release];
	[_fetchedResultsController release];
	[session release];
	[user release];
	[xmppStream release];
	[_maxId release];
	[_minId release];
	[_alertView release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (UIAlertView *)alertView {
	if (!_alertView) {
		_alertView = [[UIAlertView alloc] init];
		[_alertView addButtonWithTitle:@"Ok"];
	}
	
	return _alertView;
}

#pragma mark -
#pragma mark Core Data

- (NSFetchedResultsController *)fetchedResultsController {
	NSFetchRequest *fetchRequest;
	NSEntityDescription *entityDescription;
	NSPredicate *predicate;
	NSSortDescriptor *sortDescriptor;
	NSArray *array;
	
	//MVR - lazily load
	if (_fetchedResultsController)
		return _fetchedResultsController;
	fetchRequest = [[NSFetchRequest alloc] init];
	entityDescription = [NSEntityDescription entityForName:@"BlogcastStreamCell" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entityDescription];
	predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"user.id == %d", [user.id intValue]]];
	fetchRequest.predicate = predicate;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
	array = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:array];
	[sortDescriptor release];
	[array release];
	_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	[_fetchedResultsController setDelegate:self];
	[fetchRequest release];

	return _fetchedResultsController;
}

- (BOOL)save {
	NSError *error;

	NSLog(@"MVR - saving blogcasts");
    if (![managedObjectContext save:&error]) {
	    NSLog(@"Error saving managed object context: %@", [error localizedDescription]);
		return FALSE;
	}
	
	return TRUE;
}

#pragma mark -
#pragma mark Blogcast stream

- (NSNumber *)maxId {
	NSFetchRequest *request;
	NSEntityDescription *entity;
	NSPredicate *predicate;
	NSExpression *expression;
	NSExpression *maxExpression;
	NSExpressionDescription *expressionDescription;
	NSError *error;
	NSArray *objects;
	
	if (_maxId)
		return _maxId;
	//MVR - get the max blogcast stream cell id
	request = [[NSFetchRequest alloc] init];
	entity = [NSEntityDescription entityForName:@"BlogcastStreamCell" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	//MVR - set predicate
	predicate = [NSPredicate predicateWithFormat:@"user.id == %d", [user.id intValue]];
	[request setPredicate:predicate];		
	//MVR - specify that the request should return dictionaries	
	[request setResultType:NSDictionaryResultType];	
	expression = [NSExpression expressionForKeyPath:@"id"];
	//MVR - expression for the max id	
	maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:expression]];
	//MVR - create an expression description using the max id
	expressionDescription = [[NSExpressionDescription alloc] init];
	[expressionDescription setName:@"maxId"];
	[expressionDescription setExpression:maxExpression];
	[expressionDescription setExpressionResultType:NSInteger32AttributeType];
	//MVR - set the request's properties to fetch just the properties represented by the expressions	
	[request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];	
	//MVR - execute the fetch
	objects = [managedObjectContext executeFetchRequest:request error:&error];
	if (!objects) {
		NSLog(@"Execute fetch request failed with error: %@", [error localizedDescription]);
		self.maxId = [NSNumber numberWithInt:0];
	} else {
		if ([objects count] > 0)
			self.maxId = [[objects objectAtIndex:0] valueForKey:@"maxId"];
		else
			self.maxId = [NSNumber numberWithInt:0];
	}
	[expressionDescription release];
	[request release];
	
	return _maxId;
}

- (void)setMaxId:(NSNumber *)maxId {
	[_maxId release];
	_maxId = maxId;
	[_maxId retain];
}

- (NSNumber *)minId {
	NSFetchRequest *request;
	NSEntityDescription *entity;
	NSPredicate *predicate;
	NSExpression *expression;
	NSExpression *minExpression;
	NSExpressionDescription *expressionDescription;
	NSError *error;
	NSArray *objects;
	
	if (_minId)
		return _minId;
	//MVR - get the max blogcast stream cell id
	request = [[NSFetchRequest alloc] init];
	entity = [NSEntityDescription entityForName:@"BlogcastStreamCell" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	//MVR - set predicate
	predicate = [NSPredicate predicateWithFormat:@"user.id == %d", [user.id intValue]];
	[request setPredicate:predicate];		
	//MVR - specify that the request should return dictionaries	
	[request setResultType:NSDictionaryResultType];	
	expression = [NSExpression expressionForKeyPath:@"id"];
	//MVR - expression for the max id	
	minExpression = [NSExpression expressionForFunction:@"min:" arguments:[NSArray arrayWithObject:expression]];
	//MVR - create an expression description using the max id
	expressionDescription = [[NSExpressionDescription alloc] init];
	[expressionDescription setName:@"minId"];
	[expressionDescription setExpression:minExpression];
	[expressionDescription setExpressionResultType:NSInteger32AttributeType];
	//MVR - set the request's properties to fetch just the properties represented by the expressions	
	[request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];	
	//MVR - execute the fetch
	objects = [managedObjectContext executeFetchRequest:request error:&error];
	if (!objects) {
		NSLog(@"Execute fetch request failed with error: %@", [error localizedDescription]);
		self.minId = [NSNumber numberWithInt:0];
	} else {
		if ([objects count] > 0)
			self.minId = [[objects objectAtIndex:0] valueForKey:@"minId"];
		else
			self.minId = [NSNumber numberWithInt:0];
	}
	[expressionDescription release];
	[request release];
	
	return _minId;
}

- (void)setMinId:(NSNumber *)minId {
	[_minId release];
	_minId = minId;
	[_minId retain];
}

#pragma mark -
#pragma mark Progress HUD
/*
- (MBProgressHUD *)progressHUD {
	if (!_progressHUD)
		_progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
	
	return _progressHUD;
}

- (void)showProgressHudWithLabelText:(NSString *)labelText animationType:(MBProgressHUDAnimation)animationType{
	self.progressHUD.labelText = labelText;
	self.progressHUD.animationType = animationType;
	[self.view addSubview:self.progressHUD];
	[self.progressHUD show:NO];
}
*/
#pragma mark -
#pragma mark Network

- (NSURLConnection *)getUrl:(NSString *)url {
	NSURL *theUrl;
	NSURLRequest *urlRequest;
	NSMutableData *mutableData;
	NSURLConnection *urlConnection;
	
	theUrl = [NSURL URLWithString:url];
	urlRequest = [NSURLRequest requestWithURL:theUrl];
	urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
	mutableData = [[NSMutableData alloc] initWithCapacity:1024];

	return urlConnection;
}

#pragma mark -
#pragma mark Timer

- (void)reloadTableView {
//	NSLog(@"MVR - reload data vview");
//	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Actions

- (void)createdBlogcast {
	if (isUpdating == NO) {
		isUpdating = YES;
		[self updateBlogcasts];
	}
}

#pragma mark -
#pragma mark Helpers

- (NSURL *)blogcastsUrlWithMaxId:(NSInteger)maxId count:(NSInteger)count {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [[NSString stringWithFormat:@"http://sandbox.blogcastr.com/users/%d/blogcasts.xml?count=%d", [user.id intValue], count] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else //DEVEL
	string = [[NSString stringWithFormat:@"http://blogcastr.com/users/%d/blogcasts.xml?count=%d", [user.id intValue], count] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#endif //DEVEL
	
	
	
	//MVR - add a max id if set
	if (maxId)
		string = [string stringByAppendingString:[[NSString stringWithFormat:@"&max_id=%d", maxId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSLog(@"MVR - BLOGCASTS URL %@",string);

	url = [NSURL URLWithString:string];
	
	return url;
}

- (NSString *)avatarUrlForSize:(NSString *)size {
	NSString *avatarUrl;
	NSRange range;
	
#ifdef DEVEL
	avatarUrl = [NSString stringWithFormat:@"http://sandbox.blogcastr.com%@", user.avatarUrl];
#else //DEVEL
	avatarUrl = [[user.avatarUrl copy] autorelease];
#endif //DEVEL
	range = [avatarUrl rangeOfString:@"original"];
	if (range.location != NSNotFound) {
		return [avatarUrl stringByReplacingCharactersInRange:range withString:size];
	} else {
		NSLog(@"Error replacing size in avatar url: %@", avatarUrl);
		return avatarUrl;
	}
}

- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message {
	//MVR - update and display the alert view
	self.alertView.title = title;
	self.alertView.message = message;
	[self.alertView show];
}

@end

