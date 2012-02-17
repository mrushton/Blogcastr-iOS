//
//  CommentsController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 6/4/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import <Three20/Three20.h>
#import "CommentsController.h"
#import "CommentController.h"
#import "NewTextPostController.h"
#import "NewImagePostController.h"
#import "BlogcastrTableViewCell.h"
#import "BlogcastrStyleSheet.h"
#import "CommentsParser.h"
#import "Comment.h"
#import "CommentStreamCell.h"
#import "BlogcastrStyleSheet.h"
#import "NSDate+Format.h"
#import "NSXMLElementAdditions.h"
#import "XMPPMessage+XEP0045.h"
#import "Timer.h"

@implementation CommentsController

@synthesize tabToolbarController;
@synthesize managedObjectContext;
@synthesize session;
@synthesize blogcast;
@synthesize xmppStream;
@synthesize infiniteScrollView;
@synthesize commentMessages;
@synthesize commentsRequest;
@synthesize commentsFooterRequest;
@synthesize streamCellRequests;
@synthesize slowTimer;
@synthesize fastTimer;

static const CGFloat kInfiniteScrollViewHeight = 40.0;
static const CGFloat kScrollCellHeight = 40.0;
static const CGFloat kCommentIconWidth = 15.0;
static const CGFloat kCommentIconHeight = 14.0;
static const CGFloat kRightArrowIconWidth = 9.0;
static const CGFloat kRightArrowIconHeight = 14.0;
static const NSInteger kCommentsRequestCount = 20;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
		UIImage *image;
		UITabBarItem *theTabBarItem;
		
        // Custom initialization.
		image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"comments" ofType:@"png"]];
		theTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Comments" image:image tag:0];
		self.tabBarItem = theTabBarItem;
		[theTabBarItem release];
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	TTTableFooterInfiniteScrollView *theInfiniteScrollView;
	UIView *footerBorderView;
	Timer *theSlowTimer;
	Timer *theFastTimer;
	NSError *error;
	
	[super viewDidLoad];
	self.tableView.backgroundColor = TTSTYLEVAR(backgroundColor);
	self.tableView.separatorColor = BLOGCASTRSTYLEVAR(tableViewSeperatorColor);
	//MVR - set footer view to infinite scroll view
	theInfiniteScrollView = [[TTTableFooterInfiniteScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, kInfiniteScrollViewHeight)];
	theInfiniteScrollView.backgroundColor = TTSTYLEVAR(backgroundColor);
	if (![blogcast.commentsAtEnd boolValue])
		[theInfiniteScrollView setLoading:YES];
	footerBorderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, theInfiniteScrollView.bounds.size.width, 1.0)];
	footerBorderView.backgroundColor = BLOGCASTRSTYLEVAR(lightBackgroundColor);
	[theInfiniteScrollView addSubview:footerBorderView];
	[footerBorderView release];
	self.tableView.tableFooterView = theInfiniteScrollView;
	self.infiniteScrollView = theInfiniteScrollView;
	[theInfiniteScrollView release];
	//MVR - timers
	theSlowTimer = [[Timer alloc] initWithTimeInterval:SLOW_TIMER_INTERVAL delegate:self];
	self.slowTimer = theSlowTimer;
	[theSlowTimer release];
	theFastTimer = [[Timer alloc] initWithTimeInterval:FAST_TIMER_INTERVAL delegate:self];
	self.fastTimer = theFastTimer;
	[theFastTimer release];
	//MVR - now fetch blogcasts
	if (![self.fetchedResultsController performFetch:&error])
		NSLog(@"Perform fetch failed with error: %@", [error localizedDescription]);
	//AS DESIGNED: we know the comment view will not be visible when loaded so set the badge value here
	[self setBadgeVal:[blogcast.commentsBadgeVal integerValue]];
}

- (void)viewWillAppear:(BOOL)animated {
	isTableViewRendered = YES;
	[self setBadgeVal:0];
    [super viewWillAppear:animated];
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

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CommentStreamCell *streamCell;
	Comment *comment;

	streamCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
	comment = streamCell.comment;
	if (!comment) {
		return kScrollCellHeight;
	} else {
		CGSize usernameLabelSize;
		CGSize textViewSize;
	
		//AS DESIGNED: the username is always going to be one line but calculate the size anyway
		if ([comment.user.type isEqual:@"BlogcastrUser"])
			usernameLabelSize = [comment.user.username sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(100.0, 100.0) lineBreakMode:UILineBreakModeWordWrap];
		else if ([comment.user.type isEqual:@"FacebookUser"])
			usernameLabelSize = [comment.user.facebookFullName sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(100.0, 100.0) lineBreakMode:UILineBreakModeWordWrap];
		else if ([comment.user.type isEqual:@"TwitterUser"])
			usernameLabelSize = [comment.user.twitterUsername sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(100.0, 100.0) lineBreakMode:UILineBreakModeWordWrap];
		textViewSize = [comment.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(theTableView.frame.size.width - 20.0 - kCommentIconWidth - kRightArrowIconWidth, 1000.0) lineBreakMode:UILineBreakModeWordWrap];
		return usernameLabelSize.height + textViewSize.height + 12.0;
	}
	
	return 0.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo;

	// Return the number of rows in the section.
	sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	
	return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CommentStreamCell *streamCell;
	Comment *comment;
    BlogcastrTableViewCell *cell;
	UILabel *usernameLabel;
	TTStyledTextLabel *timestampLabel;
	UILabel *textView;
	UIImage *rightArrowImage;
	UIImageView *rightArrowView;
	CGSize timestampLabelSize;
	CGSize textSize;

	// Configure the cell...
	streamCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
	comment = streamCell.comment;
	//MVR - if the comment doesn't exist the cell is a place holder to load more
	if (!comment) {
		cell = (BlogcastrTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ScrollCell"];
		//MVR - if cell doesn't exist create it
		if (!cell) {
			UIActivityIndicatorView *activityIndicatorView;

			cell = [[[BlogcastrTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ScrollCell"] autorelease];
			activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |	UIViewAutoresizingFlexibleRightMargin;
			activityIndicatorView.center = CGPointMake(tableView.bounds.size.width / 2.0, kScrollCellHeight / 2.0);
			[activityIndicatorView startAnimating];
			[cell.contentView insertSubview:activityIndicatorView belowSubview:cell.highlightView];
			[activityIndicatorView release];
		}
	} else {
		cell = (BlogcastrTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Comment"];
		//MVR - if cell doesn't exist create it
		if (!cell) {
			UIImage *image;
			UIImageView *imageView;

			cell = [[[BlogcastrTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Comment"] autorelease];
			image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"comment" ofType:@"png"]]; 
			imageView = [[UIImageView alloc] initWithImage:image];
			imageView.frame = CGRectMake(5.0, 5.0, kCommentIconWidth, kCommentIconHeight);
			[cell.contentView insertSubview:imageView belowSubview:cell.highlightView];
			[imageView release];
			usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0 + kCommentIconWidth, 5.0, 100.0, 20.0)];
			usernameLabel.font = [UIFont boldSystemFontOfSize:12.0];
			usernameLabel.backgroundColor = [UIColor clearColor];
			usernameLabel.tag = USERNAME_LABEL_TAG;
			[cell.contentView insertSubview:usernameLabel belowSubview:cell.highlightView];
			[usernameLabel release];
			timestampLabel = [self timestampLabel];
			[cell.contentView insertSubview:timestampLabel belowSubview:cell.highlightView];
			//MVR - add the text label whether it needs to or not
			textView = [[UILabel alloc] init];
			textView.font = [UIFont systemFontOfSize:12.0];
			textView.textColor = BLOGCASTRSTYLEVAR(blueGrayTextColor);
			textView.backgroundColor = [UIColor clearColor];
			textView.lineBreakMode = UILineBreakModeWordWrap;
			textView.numberOfLines = 0;
			textView.tag = TEXT_VIEW_TAG;
			[cell.contentView insertSubview:textView belowSubview:cell.highlightView];
			[textView release];
			rightArrowImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"right-arrow" ofType:@"png"]]; 
			rightArrowView = [[UIImageView alloc] initWithImage:rightArrowImage];
			rightArrowView.tag = RIGHT_ARROW_VIEW_TAG;
			[cell.contentView insertSubview:rightArrowView belowSubview:cell.highlightView];
			[rightArrowView release];
		} else {
			usernameLabel = (UILabel *)[cell viewWithTag:USERNAME_LABEL_TAG];
			timestampLabel = (TTStyledTextLabel *)[cell viewWithTag:TIMESTAMP_LABEL_TAG];
			textView = (UILabel *)[cell viewWithTag:TEXT_VIEW_TAG];
			rightArrowView = (UIImageView *)[cell viewWithTag:RIGHT_ARROW_VIEW_TAG];
		}
		//MVR - username label
		if ([comment.user.type isEqual:@"BlogcastrUser"])
			usernameLabel.text = comment.user.username;
		else if ([comment.user.type isEqual:@"FacebookUser"])
			usernameLabel.text = comment.user.facebookFullName;
		else if ([comment.user.type isEqual:@"TwitterUser"])
			usernameLabel.text = comment.user.twitterUsername;
		[usernameLabel sizeToFit];
		//MVR - timestamp label
		timestampLabel.text = [TTStyledText textFromXHTML:[NSString stringWithFormat:@"<span class=\"timestampInWords\">%@<span>", [comment.createdAt stringInWords]]];
		timestampLabelSize = [[comment.createdAt stringInWords] sizeWithFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:9.0]];
		timestampLabel.frame = CGRectMake(15.0 + kCommentIconWidth + usernameLabel.frame.size.width, 6.0, timestampLabelSize.width + 6.0, timestampLabelSize.height + 1.0);
		//MVR - text view
		textView.text = comment.text;
		//MVR - determine the height of the text
		textSize = [comment.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0 - kCommentIconWidth - kRightArrowIconWidth, 1000.0) lineBreakMode:UILineBreakModeWordWrap];
		textView.frame = CGRectMake(10.0 + kCommentIconWidth, usernameLabel.frame.size.height + 6.0, textSize.width, textSize.height);
		rightArrowView.frame = CGRectMake(self.tableView.frame.size.width - kRightArrowIconWidth - 5.0, ([self tableView:tableView heightForRowAtIndexPath:indexPath] / 2.0 ) - (kRightArrowIconHeight / 2.0), kRightArrowIconWidth, kRightArrowIconHeight);
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
	CommentStreamCell *streamCell;
	Comment *comment;
	CommentController *commentController;
	
	streamCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
	comment = streamCell.comment;
	commentController = [[CommentController alloc] initWithNibName:nil bundle:nil];
	commentController.managedObjectContext = managedObjectContext;
	commentController.session = session;
	commentController.comment = comment;
	commentController.title = @"Comment";
	[tabToolbarController.navigationController pushViewController:commentController animated:YES];
	[commentController release];
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
	[super viewDidUnload];
	self.infiniteScrollView = nil;
	[fastTimer invalidate];
	self.fastTimer = nil;
	[slowTimer invalidate];
	self.slowTimer = nil;
}


- (void)dealloc {
	[_fetchedResultsController release];
	[managedObjectContext release];
	[session release];
	[blogcast release];
	[xmppStream removeDelegate:self];
	[xmppStream release];
	[infiniteScrollView release];
	[commentsRequest clearDelegatesAndCancel];
	[commentsRequest release];
	[commentsFooterRequest clearDelegatesAndCancel];
	[commentsFooterRequest release];
	[_commentMessages release];
	[_maxId release];
	[_minId release];
	[fastTimer invalidate];
	[fastTimer release];
	[slowTimer invalidate];
	[slowTimer release];
	//AS DESIGNED: if not allocated that is ok
	for (ASIHTTPRequest *request in _streamCellRequests)
		[request clearDelegatesAndCancel];
	[_streamCellRequests release];
	[_alertView release];
    [super dealloc];
}

- (NSMutableArray *)commentMessages {
	if (!_commentMessages)
		_commentMessages = [[NSMutableArray alloc] initWithCapacity:10.0];
	
	return _commentMessages;
}

- (NSMutableArray *)streamCellRequests {
	if (!_streamCellRequests)
		_streamCellRequests = [[NSMutableArray alloc] initWithCapacity:10.0];
	
	return _streamCellRequests;
}

- (UIAlertView *)alertView {
	if (!_alertView) {
		_alertView = [[UIAlertView alloc] init];
		[_alertView addButtonWithTitle:@"Ok"];
	}
	
	return _alertView;
}

#pragma mark -
#pragma mark Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	NSIndexPath *indexPath;

	//MVR - deselect highlighted table cells
	indexPath = [self.tableView indexPathForSelectedRow];
	if (indexPath)
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	//MVR - footer logic
	if (scrollView.contentOffset.y > scrollView.contentSize.height - kInfiniteScrollViewHeight - scrollView.bounds.size.height && ![blogcast.commentsAtEnd boolValue] && !isUpdatingFooter && [self.minId intValue] > 0)
		[self updateCommentsFooter];
}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
	float systemVersion;

	//AS DESIGNED: work around 3.* UITableView bug
	systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	//AS DESIGNED: second work around for not being able to insert rows before the table view has been rendered
	if (systemVersion >= 4.0 && isTableViewRendered)
		[[self tableView] beginUpdates];
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
	//AS DESIGNED: second work around for not being able to insert rows before the table view has been rendered
	if (systemVersion >= 4.0 && isTableViewRendered) {
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
	//AS DESIGNED: second work around for not being able to insert rows before the table view has been rendered
	if (systemVersion >= 4.0 && isTableViewRendered) {
		[[self tableView] endUpdates];
	} else {
		//AS DESIGNED: this will not be animated but it's the easiest work around for the 3.x UITableView bug
		[[self tableView] reloadData];
	}
}

#pragma mark -
#pragma mark XMPPStream delegate

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
	NSXMLElement *bodyElement;
	NSString *type;
	
	//MVR - filter for posts to this blogcast
	if (![message isGroupChatMessageWithBody]) {
		NSLog(@"Received a non-group chat XMPP message");
		return;
	}
	if (![[[message from] user] isEqualToString:[NSString stringWithFormat:@"blogcast.%d", [blogcast.id intValue]]]) {
		NSLog(@"Received a group chat XMPP message not for us from %@", [[message from] user]);
		return;
	}
	//MVR - we know the body element exists
	bodyElement = [message elementForName:@"body"];
	type = [[bodyElement elementForName:@"type"] stringValue];
	if (![type isEqualToString:@"Comment"])
		return;
	//MVR - if we aren't in sync queue up the message to be parsed after we are
	if (isSynced) {
		if ([self addMessage:message]) {
			if (![self save])
				NSLog(@"Error saving comment");
			if (self.view.window == nil)
				[self setBadgeVal:[blogcast.commentsBadgeVal integerValue] + 1];
			//MVR - vibrate the phone
			if ([session.user.vibrate boolValue])
				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		} else {
			NSLog(@"Could not add comment to stream");
		}
	} else {
		//MVR - add the message after we sync up
		[self.commentMessages addObject:message];
	}
}

#pragma mark -
#pragma mark ASIHTTPRequest callbacks

- (void)updateCommentsFinished:(ASIHTTPRequest *)request {
	int statusCode;
	NSInteger numAdded = 0;
	CommentsParser *parser;

	self.commentsRequest = nil;
	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Update comments received status code %i", statusCode);
		[self errorAlertWithTitle:@"Update Failed" message:@"Oops! We couldn't update the comments."];
		retryUpdate = YES;
		return;
	}
	//MVR - parse xml
	parser = [[CommentsParser alloc] init];
	parser.data = [request responseData];
	parser.managedObjectContext = managedObjectContext;
	parser.blogcast = blogcast;
	if (![parser parse]) {
		NSLog(@"Error parsing update comments response");
		[self errorAlertWithTitle:@"Parse Error" message:@"Oops! We couldn't update the comments."];
		[parser release];
		retryUpdate = YES;
		return;
	}
	//MVR - add comments above max id
	for (Comment *comment in parser.comments) {
		if ([comment.id intValue] > [self.maxId intValue]) {
			CommentStreamCell *streamCell;
			
			streamCell = [NSEntityDescription insertNewObjectForEntityForName:@"CommentStreamCell" inManagedObjectContext:managedObjectContext];
			streamCell.id = comment.id;
			streamCell.comment = comment;
			streamCell.blogcast = blogcast;
			numAdded++;
		}
	}
	//MVR - handle either the footer scroll or cell scroll
	if ([self.maxId intValue] == 0) {
		if (numAdded < kCommentsRequestCount) {
			blogcast.commentsAtEnd = [NSNumber numberWithBool:YES];
			[infiniteScrollView setLoading:NO];
		} else {
			Comment *comment;

			//MVR - update min id if there may be more to load
			comment = [parser.comments objectAtIndex:numAdded - 1];
			self.minId = comment.id;
		}
	} else if (numAdded == kCommentsRequestCount) {
		Comment *comment;

		comment = [parser.comments objectAtIndex:kCommentsRequestCount - 1];
		//MVR - add one to make sure there is actually a gap
		if ([comment.id intValue] > [self.maxId intValue] + 1) {
			CommentStreamCell *streamCell;
			
			streamCell = [NSEntityDescription insertNewObjectForEntityForName:@"CommentStreamCell" inManagedObjectContext:managedObjectContext];
			streamCell.id = [NSNumber numberWithInteger:[self.maxId integerValue] + 1];
			streamCell.maxId = [NSNumber numberWithInteger:[comment.id integerValue] - 1];
			streamCell.blogcast = blogcast;
		}
	}
	if (numAdded > 0) {
		Comment *comment;

		comment = [parser.comments objectAtIndex:0];
		self.maxId = comment.id;
	}
	[parser release];
	//MVR - if the array hasn't been allocated yet there is no need to allocate and check it
	if (_commentMessages) {
		for (XMPPMessage *message in self.commentMessages) {
			if ([self addMessage:message])
				numAdded++;
			else
				NSLog(@"Could not add comment to stream");
		}
		[self.commentMessages removeAllObjects];
	}
	if (![self save])
		NSLog(@"Error saving comments");
	isSynced = YES;
	//MVR - update the badge value
	if (self.view.window == nil)
		[self setBadgeVal:[blogcast.commentsBadgeVal integerValue] + numAdded];
	//MVR - vibrate the phone
	if ([session.user.vibrate boolValue] && numAdded > 0)
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)updateCommentsFailed:(ASIHTTPRequest *)request {
	NSError *error;

	self.commentsRequest = nil;
	error = [request error];
	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Error updating comments: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection Failure" message:@"Oops! We couldn't update the comments."];
			retryUpdate = YES;
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Error updating comments: request timed out");
			[self errorAlertWithTitle:@"Request Timed Out" message:@"Oops! We couldn't update the comments."];
			retryUpdate = YES;
			break;
		case ASIRequestCancelledErrorType:
			NSLog(@"Update comments request cancelled");
			break;
		default:
			NSLog(@"Error updating comments");
			retryUpdate = YES;
			break;
	}
}

- (void)updateCommentsStreamCellFinished:(ASIHTTPRequest *)request {
	CommentStreamCell *streamCell;
	int statusCode;
	CommentsParser *parser;
	NSInteger numAdded = 0;
	Comment *comment;
	
	[self.streamCellRequests removeObject:request];
	streamCell = (CommentStreamCell *)[request.userInfo objectForKey:@"CommentStreamCell"];
	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error update comments stream cell received status code %i", statusCode);
		[self errorAlertWithTitle:@"Update Failed" message:@"Oops! We couldn't update your comments."];
		return;
	}
	//MVR - parse response
	parser = [[CommentsParser alloc] init];
	parser.data = [request responseData];
	parser.managedObjectContext = managedObjectContext;
	parser.blogcast = blogcast;
	if (![parser parse]) {
		NSLog(@"Error parsing update stream cell comments response");
		[self errorAlertWithTitle:@"Parse Error" message:@"Oops! We couldn't update your comments."];
		[parser release];
		return;
	}
	//MVR - assume all comments are below the stream cell id so add posts above the min id
	for (Comment *theComment in parser.comments) {
		if ([theComment.id intValue] >= [streamCell.id intValue]) {
			CommentStreamCell *theStreamCell;
			
			theStreamCell = [NSEntityDescription insertNewObjectForEntityForName:@"CommentStreamCell" inManagedObjectContext:managedObjectContext];
			theStreamCell.id = theComment.id;
			theStreamCell.comment = theComment;
			theStreamCell.blogcast = blogcast;
			numAdded++;
		}
	}
	comment = [parser.comments lastObject];
	//MVR - adjust stream cell or delete it
	if (numAdded == kCommentsRequestCount && [comment.id intValue] != [streamCell.id intValue])
		streamCell.maxId = [NSNumber numberWithInteger:[comment.id integerValue] - 1];
	else
		[self.managedObjectContext deleteObject:streamCell];
	[parser release];
	if (![self save])
		NSLog(@"Error saving comments");
	//MVR - update the badge value
	if (self.view.window == nil)
		[self setBadgeVal:[blogcast.commentsBadgeVal integerValue] + numAdded];
	//MVR - vibrate the phone
	if ([session.user.vibrate boolValue] && numAdded > 0)
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)updateCommentsStreamCellFailed:(ASIHTTPRequest *)request {
	NSLog(@"Update comments stream cell failed");
	[self.streamCellRequests removeObject:request];
	[self errorAlertWithTitle:@"Update Failed" message:@"Oops! We couldn't update the comments."];
}

- (void)updateCommentsFooterFinished:(ASIHTTPRequest *)request {
	int statusCode;
	NSInteger numAdded = 0;
	CommentsParser *parser;

	self.commentsFooterRequest = nil;
	isUpdatingFooter = NO;
	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error update comments footer received status code %i", statusCode);
		[self errorAlertWithTitle:@"Update Failed" message:@"Oops! We couldn't update your comments."];
		return;
	}
	//MVR - parse response
	parser = [[CommentsParser alloc] init];
	parser.data = [request responseData];
	parser.managedObjectContext = managedObjectContext;
	parser.blogcast = blogcast;
	if (![parser parse]) {
		NSLog(@"Error parsing update footer comments response");
		[self errorAlertWithTitle:@"Parse Error" message:@"Oops! We couldn't update your comments."];
		[parser release];
		return;
	}
	//MVR - add posts below min id
	for (Comment *comment in parser.comments) {
		if ([comment.id intValue] < [self.minId intValue]) {
			CommentStreamCell *streamCell;
			
			streamCell = [NSEntityDescription insertNewObjectForEntityForName:@"CommentStreamCell" inManagedObjectContext:managedObjectContext];
			streamCell.id = comment.id;
			streamCell.comment = comment;
			streamCell.blogcast = blogcast;
			numAdded++;
		}
	}
	//MVR - handle the footer scroll
	if (numAdded < kCommentsRequestCount) {
		blogcast.commentsAtEnd = [NSNumber numberWithBool:YES];
		[infiniteScrollView setLoading:NO];
	} else {
		Comment *comment;
		
		comment = [parser.comments objectAtIndex:kCommentsRequestCount - 1];
		self.minId = comment.id;
	}
	[parser release];
	if (![self save])
		NSLog(@"Error saving comments");
	//MVR - update the badge value
	if (self.view.window == nil)
		[self setBadgeVal:[blogcast.commentsBadgeVal integerValue] + numAdded];
	//MVR - vibrate the phone
	if ([session.user.vibrate boolValue] && numAdded > 0)
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)updatePostsFooterFailed:(ASIHTTPRequest *)request {
	self.commentsFooterRequest = nil;
	isUpdatingFooter = NO;
	NSLog(@"Error update comments footer failed");
	[self errorAlertWithTitle:@"Update Failed" message:@"Oops! We couldn't update your comments."];
}

#pragma mark -
#pragma mark Dashboard notifications

- (void)joinedRoom {
	isSynced = NO;
	//MVR - if another request has been made cancel it
	[commentsRequest clearDelegatesAndCancel];
	self.commentsRequest = nil;
	[self updateComments];
}

- (void)leftRoom {
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
	entityDescription = [NSEntityDescription entityForName:@"CommentStreamCell" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entityDescription];
	predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"blogcast.id == %d", [blogcast.id intValue]]];
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
	
    if (![managedObjectContext save:&error]) {
	    NSLog(@"Error saving managed object context: %@", [error localizedDescription]);
		return FALSE;
	}
	
	return TRUE;
}

#pragma mark -
#pragma mark Comment stream

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
	entity = [NSEntityDescription entityForName:@"CommentStreamCell" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	//MVR - set predicate
	predicate = [NSPredicate predicateWithFormat:@"blogcast.id == %d", [blogcast.id intValue]];
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
	entity = [NSEntityDescription entityForName:@"CommentStreamCell" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	//MVR - set predicate
	predicate = [NSPredicate predicateWithFormat:@"blogcast.id == %d", [blogcast.id intValue]];
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
#pragma mark Actions

- (void)timerExpired:(Timer *)timer {
	if (timer == slowTimer) {
		//MVR - reload the entire table to update timestamps since there's no easy way to get the text out of the TTStyledTextLabel
		[self.tableView reloadData];
		//MVR - the update may have failed so retry
		if (retryUpdate)
			[self updateComments];
	} else if (timer == fastTimer) {
		//MVR - scroll cell logic
		for (UITableViewCell *cell in self.tableView.visibleCells) {
			CommentStreamCell *streamCell;
			NSIndexPath *indexPath;
			
			indexPath = [self.tableView indexPathForCell:cell];
			if (!indexPath) {
				NSLog(@"Could not find post stream cell index path");
				continue;
			}
			streamCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
			if (!streamCell.comment) {
				if (![self isStreamCellRequested:streamCell])
					[self updateCommentsStreamCell:streamCell];
			}
		}
	}
}

#pragma mark -
#pragma mark Helpers

- (void)updateComments {
	NSURL *url;
	ASIHTTPRequest *request;

	//MVR - clear retry flag before making request
	retryUpdate = NO;
	url = [self commentsUrlWithMaxId:0 count:kCommentsRequestCount];	
	request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(updateCommentsFinished:)];
	[request setDidFailSelector:@selector(updateCommentsFailed:)];
	[request startAsynchronous];
	self.commentsRequest = request;
}

- (void)updateCommentsStreamCell:(CommentStreamCell *)streamCell {
	NSURL *url;
	ASIHTTPRequest *request;
	
	url = [self commentsUrlWithMaxId:[streamCell.maxId intValue] count:kCommentsRequestCount];	
	request = [ASIHTTPRequest requestWithURL:url];
	request.userInfo = [NSDictionary dictionaryWithObject:streamCell forKey:@"CommentStreamCell"];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(updateCommentsStreamCellFinished:)];
	[request setDidFailSelector:@selector(updateCommentsStreamCellFailed:)];
	[request startAsynchronous];
	//MVR - add to stream cell request array
	[self.streamCellRequests addObject:request];
}

- (void)updateCommentsFooter {
	NSURL *url;
	ASIHTTPRequest *request;
	
	url = [self commentsUrlWithMaxId:[self.minId intValue] - 1 count:kCommentsRequestCount];	
	request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(updateCommentsFooterFinished:)];
	[request setDidFailSelector:@selector(updateCommentsFooterFailed:)];
	[request startAsynchronous];
	isUpdatingFooter = YES;
	self.commentsFooterRequest = request;
}

- (NSURL *)commentsUrlWithMaxId:(NSInteger)maxId count:(NSInteger)count {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [[NSString stringWithFormat:@"http://sandbox.blogcastr.com/blogcasts/%d/comments.xml?count=%d", [blogcast.id intValue], count] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else //DEVEL
	string = [[NSString stringWithFormat:@"http://blogcastr.com/blogcasts/%d/comments.xml?count=%d", [blogcast.id intValue], count] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#endif //DEVEL
	//MVR - add a max id if set
	if (maxId)
		string = [string stringByAppendingString:[[NSString stringWithFormat:@"&max_id=%d", maxId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	url = [NSURL URLWithString:string];
	
	return url;
}

- (BOOL)isStreamCellRequested:(CommentStreamCell *)streamCell {
	for (ASIHTTPRequest *request in self.streamCellRequests) {
		CommentStreamCell *theStreamCell;
		
		theStreamCell = (CommentStreamCell *)[request.userInfo objectForKey:@"CommentStreamCell"];
		if (theStreamCell == streamCell)
			return YES;
	}
	
	return NO;
}

- (Comment *)parseMessage:(XMPPMessage *)message {
	NSXMLElement *bodyElement;
	NSString *commentId;
	NSString *commentCreatedAt;
	NSString *commentText;
	NSXMLElement *userElement;
	NSString *userId;
	NSString *userType;
	NSString *userUsername;
	NSString *userUrl;
	NSString *userAvatarUrl;
	NSFetchRequest *request;
	NSEntityDescription *entity;
	NSPredicate *predicate;
	NSArray *array;
	Comment *comment;
	User *user;
	NSError *error;
	
	//MVR - we know the body exists
	bodyElement = [message elementForName:@"body"];
	//MVR - do all the parsing
	commentId = [[bodyElement elementForName:@"id"] stringValue];
	if (!commentId) {
		NSLog(@"Error finding comment id in XMPP message");
		return nil;
	}
	commentCreatedAt = [[bodyElement elementForName:@"created-at"] stringValue];
	if (!commentCreatedAt) {
		NSLog(@"Error finding comment created at in XMPP message");
		return nil;
	}
	commentText = [[bodyElement elementForName:@"text"] stringValue];
	if (!commentText) {
		NSLog(@"Error finding comment text in XMPP message");
		return nil;
	}
	userElement = [bodyElement elementForName:@"user"];
	if (!userElement) {
		NSLog(@"Error finding user element in XMPP message");
		return nil;
	}
	userId = [[userElement elementForName:@"id"] stringValue];
	if (!userId) {
		NSLog(@"Error finding user id in XMPP message");
		return nil;
	}
	userType = [[userElement elementForName:@"type"] stringValue];
	if (!userType) {
		NSLog(@"Error finding user type in XMPP message");
		return nil;
	}
	userUsername = [[userElement elementForName:@"username"] stringValue];
	if (!userUsername) {
		NSLog(@"Error finding user username in XMPP message");
		return nil;
	}
	userUrl = [[userElement elementForName:@"url"] stringValue];
	if (!userUrl) {
		NSLog(@"Error finding user url in XMPP message");
		return nil;
	}
	userAvatarUrl = [[userElement elementForName:@"avatar-url"] stringValue];
	if (!userAvatarUrl) {
		NSLog(@"Error finding user avatar url in XMPP message");
		return nil;
	}
	//MVR - find the comment if it exists
	request = [[NSFetchRequest alloc] init];
	entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	predicate = [NSPredicate predicateWithFormat:@"id = %d", [commentId intValue]];
	[request setPredicate:predicate];
	//MVR - execute the fetch
	array = [managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	//MVR - create the comment if it doesn't exist
	if ([array count] > 0) {
		comment = [array objectAtIndex:0];
	} else {
		NSDate *date;

		//MVR - parsing done create the post
		comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:managedObjectContext];
		comment.id = [NSNumber numberWithInteger:[commentId integerValue]];
		comment.blogcast = blogcast;
		//MVR - convert date string
		date = [NSDate dateWithIso8601:commentCreatedAt];
		comment.createdAt = date;
		[date release];
		comment.text = commentText;
		//MVR - find user if they exist
		request = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];
		predicate = [NSPredicate predicateWithFormat:@"id = %d", [userId intValue]];
		[request setPredicate:predicate];
		//MVR - execute the fetch
		array = [managedObjectContext executeFetchRequest:request error:&error];
		[request release];
		//MVR - create user if they don't exist
		if ([array count] > 0) {
			user = [array objectAtIndex:0];
		} else {
			user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
			user.id = [NSNumber numberWithInteger:[userId integerValue]];
			user.type = userType;
			if ([userType isEqual:@"BlogcastrUser"]) {
				user.username = userUsername;
			} else if ([userType isEqual:@"FacebookUser"]) {
				user.facebookFullName = userUsername;
				user.facebookLink = userUrl;
			} else if ([userType isEqual:@"TwitterUser"]) {
				user.twitterUsername = userUsername;
			}
			user.avatarUrl = userAvatarUrl;
		}
		comment.user = user;
	}

	return comment;
}

- (BOOL)addMessage:(XMPPMessage *)message {
	Comment *comment;
	
	comment = [self parseMessage:message];
	if (!comment) {
		NSLog(@"Error parsing XMPP comment message");
		[self errorAlertWithTitle:@"Parse Error" message:@"Oops! We couldn't parse the comment."];
		return NO;
	}
	//MVR - now add the stream cell
	if ([comment.id intValue] > [self.maxId intValue]) {
		CommentStreamCell *streamCell;
		
		streamCell = [NSEntityDescription insertNewObjectForEntityForName:@"CommentStreamCell" inManagedObjectContext:managedObjectContext];
		streamCell.id = comment.id;
		streamCell.comment = comment;
		streamCell.blogcast = blogcast;
		self.maxId = comment.id;
		return YES;
	}
	
	return NO;
}

- (void)setBadgeVal:(NSInteger)val {
	//MVR - update and save the badge value
	blogcast.commentsBadgeVal = [NSNumber numberWithInteger:val];
	if (![self save])
		NSLog(@"Error saving comments badge value");
	if (val)
		self.tabBarItem.badgeValue = [blogcast.commentsBadgeVal stringValue];
	else
		self.tabBarItem.badgeValue = nil;
}

- (TTStyledTextLabel *)timestampLabel {
	TTStyledTextLabel *timestampLabel;

	timestampLabel = [[[TTStyledTextLabel alloc] init] autorelease];
	timestampLabel.contentInset = UIEdgeInsetsMake(0.0, 3.0, 0.0, 0.0);
	timestampLabel.textAlignment = UITextAlignmentRight;
	timestampLabel.font = [UIFont systemFontOfSize:9.0];
	timestampLabel.tag = TIMESTAMP_LABEL_TAG;
	
	return timestampLabel;
}

- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message {
	//MVR - update and display the alert view
	self.alertView.title = title;
	self.alertView.message = message;
	[self.alertView show];
}


@end

