    //
//  PostsController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/30/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "PostsController.h"
#import "NewTextPostController.h"
#import "NewImagePostController.h"
#import "PostController.h"
#import "BlogcastrTableViewCell.h"
#import "BlogcastrStyleSheet.h"
#import "PostsParser.h"
#import "Post.h"
#import "Comment.h"
#import "PostStreamCell.h"
#import "BlogcastrStyleSheet.h"
#import "NSDate+Timestamp.h"
#import "NSXMLElementAdditions.h"
#import "XMPPMessage+XEP0045.h"
#import "Timer.h"


@implementation PostsController

@synthesize tabToolbarController;
@synthesize managedObjectContext;
@synthesize session;
@synthesize blogcast;
@synthesize xmppStream;
@synthesize tableView;
@synthesize infiniteScrollView;
@synthesize postMessages;
@synthesize postsRequest;
@synthesize streamCellRequests;
@synthesize fastTimer;
@synthesize slowTimer;

static const CGFloat kPostBarViewHeight = 40.0;
static const CGFloat kInfiniteScrollViewHeight = 40.0;
static const CGFloat kScrollCellHeight = 40.0;
static const CGFloat kCommentIconWidth = 16;
static const NSInteger kPostsRequestCount = 20;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	TTView *topBar;
	TTButton *newTextPostButton;
	TTButton *newImagePostButton;
	TTStyleSheet *styleSheet;
	TTStyle *style;
	UITableView *theTableView;
	CGRect frame;
	TTTableFooterInfiniteScrollView *theInfiniteScrollView;
	UIView *footerBorderView;
	NSError *error;

	[super viewDidLoad];
	topBar = [[TTView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, kPostBarViewHeight)];
	styleSheet = [TTStyleSheet globalStyleSheet];
	style = [styleSheet styleWithSelector:@"topBar" forState:UIControlStateNormal];
	topBar.style = style;
	//MVR - set up the post buttons
	newTextPostButton = [TTButton buttonWithStyle:@"blueButtonWithImage:" title:@"New Text Post"];
	//MVR - image url based on screen resolution
	//if ([[UIScreen mainScreen] scale] > 1.0)
	//[textPostButton setImage:@"bundle://logo~iphone.png" forState:UIControlStateNormal];
	[newTextPostButton addTarget:self action:@selector(newTextPost:) forControlEvents:UIControlEventTouchUpInside]; 
	newTextPostButton.frame = CGRectMake(5.0, 6.0, 150.0, 28.0);
	[topBar addSubview:newTextPostButton];
	newImagePostButton = [TTButton buttonWithStyle:@"orangeButtonWithImage:" title:@"New Image Post"];
	//MVR - image url based on screen resolution
	//if ([[UIScreen mainScreen] scale] > 1.0)
	//[textPostButton setImage:@"bundle://logo~iphone.png" forState:UIControlStateNormal];
	[newImagePostButton addTarget:self action:@selector(newImagePost:) forControlEvents:UIControlEventTouchUpInside]; 
	newImagePostButton.frame = CGRectMake(165.0, 6.0, 150.0, 28.0);
	[topBar addSubview:newImagePostButton];
	[self.view addSubview:topBar];
	[topBar release];
	frame = CGRectMake(0.0, kPostBarViewHeight, self.view.bounds.size.width, self.view.bounds.size.height - kPostBarViewHeight);
	theTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	theTableView.backgroundColor = TTSTYLEVAR(backgroundColor);
	theTableView.separatorColor = BLOGCASTRSTYLEVAR(tableViewSeperatorColor);
	theTableView.delegate = self;
	theTableView.dataSource = self;
	theTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:theTableView];
	self.tableView = theTableView;
	[theTableView release];
	//MVR - set footer view to infinite scroll view
	theInfiniteScrollView = [[TTTableFooterInfiniteScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, kInfiniteScrollViewHeight)];
	theInfiniteScrollView.backgroundColor = TTSTYLEVAR(backgroundColor);
	if (![blogcast.postsAtEnd boolValue])
		[theInfiniteScrollView setLoading:YES];
	footerBorderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, theInfiniteScrollView.bounds.size.width, 1.0)];
	footerBorderView.backgroundColor = BLOGCASTRSTYLEVAR(lightBackgroundColor);
	[theInfiniteScrollView addSubview:footerBorderView];
	[footerBorderView release];
	self.tableView.tableFooterView = theInfiniteScrollView;
	self.infiniteScrollView = theInfiniteScrollView;
	[theInfiniteScrollView release];
	//MVR - timers
	fastTimer = [[Timer alloc] initWithTimeInterval:FAST_TIMER_INTERVAL delegate:self];
	slowTimer = [[Timer alloc] initWithTimeInterval:SLOW_TIMER_INTERVAL delegate:self];
	//MVR - now fetch blogcasts
	if (![self.fetchedResultsController performFetch:&error])
		NSLog(@"Perform fetch failed with error: %@", [error localizedDescription]);
}

- (void)viewWillAppear:(BOOL)animated {
	[self setBadgeVal:0];
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:animated];
	[super viewWillAppear:animated];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.tableView = nil;
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
	[tableView release];
	if (postsRequest)
		[postsRequest setDelegate:nil];
	[_postMessages release];
	[postsRequest release];
	[_maxId release];
	[_minId release];
	[fastTimer invalidate];
	[fastTimer release];
	[slowTimer invalidate];
	[slowTimer release];
	[_streamCellRequests release];
	[_alertView release];
    [super dealloc];
}

- (NSMutableArray *)postMessages {
	if (!_postMessages)
		_postMessages = [[NSMutableArray alloc] initWithCapacity:10.0];

	return _postMessages;
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
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	PostStreamCell *streamCell;
	Post *post;

	streamCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
	post = streamCell.post;
	if (!post) {
		return kScrollCellHeight;
	} else if ([post.type isEqual:@"TextPost"]) {
		CGSize usernameLabelSize;
		CGSize textViewSize;
		
		//AS DESIGNED: the username is always going to be one line but calculate the size anyway
		usernameLabelSize = [post.user.username sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(100.0, 100.0) lineBreakMode:UILineBreakModeWordWrap];
		textViewSize = [post.text sizeWithFont:[UIFont boldSystemFontOfSize:12.0] constrainedToSize:CGSizeMake(theTableView.frame.size.width - 10.0, 100.0) lineBreakMode:UILineBreakModeWordWrap];
		return usernameLabelSize.height + textViewSize.height + 11.0;
	} else if ([post.type isEqual:@"ImagePost"]) {
		CGFloat imageWidth;
		CGFloat imageHeight;
		CGSize usernameLabelSize;
		CGSize textViewSize;

		//MVR - image layout
		if ([post.imageWidth intValue] > [post.imageHeight intValue]) {
			if ([post.imageWidth intValue] > 80.0) {
				imageWidth = 80.0;
				imageHeight = 80.0 * [post.imageHeight intValue] / [post.imageWidth intValue];
			} else {
				imageWidth = [post.imageWidth intValue];
				imageHeight = [post.imageHeight intValue];
			}
		} else {
			if ([post.imageHeight intValue] > 80.0) {
				imageWidth = 80.0 * [post.imageWidth intValue] / [post.imageHeight intValue];
				imageHeight = 80.0;
			} else {
				imageWidth = [post.imageWidth intValue];
				imageHeight = [post.imageHeight intValue];
			}
		}
		if (post.text) {
			//AS DESIGNED: the username is always going to be one line but calculate the size anyway
			usernameLabelSize = [post.user.username sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(1000.0, 1000.0) lineBreakMode:UILineBreakModeWordWrap];
			textViewSize = [post.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(theTableView.frame.size.width - imageWidth - 15.0, 1000.0) lineBreakMode:UILineBreakModeWordWrap];
			if (imageHeight < usernameLabelSize.height + textViewSize.height)
				return usernameLabelSize.height + textViewSize.height + 11.0;
		}
		return imageHeight + 11.0;
	} else if ([post.type isEqual:@"CommentPost"]) {
		CGSize usernameLabelSize;
		CGSize textViewSize;

		//AS DESIGNED: the username is always going to be one line but calculate the size anyway
		if ([post.comment.user.type isEqual:@"BlogcastrUser"])
			usernameLabelSize = [post.comment.user.username sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(100.0, 100.0) lineBreakMode:UILineBreakModeWordWrap];
		else if ([post.comment.user.type isEqual:@"FacebookUser"])
			usernameLabelSize = [post.comment.user.facebookFullName sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(100.0, 100.0) lineBreakMode:UILineBreakModeWordWrap];
		else if ([post.comment.user.type isEqual:@"TwitterUser"])
			usernameLabelSize = [post.comment.user.twitterUsername sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(100.0, 100.0) lineBreakMode:UILineBreakModeWordWrap];
		textViewSize = [post.comment.text sizeWithFont:[UIFont boldSystemFontOfSize:12.0] constrainedToSize:CGSizeMake(theTableView.frame.size.width - 15.0 - kCommentIconWidth, 100.0) lineBreakMode:UILineBreakModeWordWrap];
		return usernameLabelSize.height + textViewSize.height + 11.0;
	} else {
		NSLog(@"Error setting cell height for unknown post type %@");
	}
	
	return 0.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    // Return the number of sections.
	return 1;
}


- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo;
	
	// Return the number of rows in the section.
	sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PostStreamCell *streamCell;
	Post *post;
    BlogcastrTableViewCell *cell;
	UILabel *usernameLabel;
	TTStyledTextLabel *timestampLabel;
	UILabel *textView;
	CGSize timestampLabelSize;
	CGSize textSize;

	// Set up the cell...
	streamCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
	post = streamCell.post;
	//MVR - if the post doesn't exist the cell is a place holder to load more
	if (!post) {
		cell = (BlogcastrTableViewCell *)[theTableView dequeueReusableCellWithIdentifier:@"ScrollCell"];
		if (!cell) {	
			//MVR - if cell doesn't exist create it
			if (!cell) {
				UIActivityIndicatorView *activityIndicatorView;

				cell = [[[BlogcastrTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ScrollCell"] autorelease];
				activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
				activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |	UIViewAutoresizingFlexibleRightMargin;
				activityIndicatorView.center = CGPointMake(tableView.bounds.size.width / 2.0, kScrollCellHeight / 2.0);
				[activityIndicatorView startAnimating];
				[cell.contentView insertSubview:activityIndicatorView belowSubview:cell.highlightView];
			}
		}
	} else if ([post.type isEqual:@"TextPost"]) {
		cell = (BlogcastrTableViewCell *)[theTableView dequeueReusableCellWithIdentifier:@"TextPost"];
		//MVR - if cell doesn't exist create it
		if (!cell) {	
			cell = [[[BlogcastrTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextPost"] autorelease];
			usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, 100.0, 20.0)];
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
		} else {
			usernameLabel = (UILabel *)[cell viewWithTag:USERNAME_LABEL_TAG];
			timestampLabel = (TTStyledTextLabel *)[cell viewWithTag:TIMESTAMP_LABEL_TAG];
			textView = (UILabel *)[cell viewWithTag:TEXT_VIEW_TAG];
		}
		//MVR - username label
		usernameLabel.text = post.user.username;
		[usernameLabel sizeToFit];
		//MVR - timestamp label
		timestampLabel.text = [TTStyledText textFromXHTML:[NSString stringWithFormat:@"<span class=\"timestampInWords\">%@<span>", [post.createdAt stringInWords]]];
		timestampLabelSize = [[post.createdAt stringInWords] sizeWithFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:9.0]];
		timestampLabel.frame = CGRectMake(tableView.frame.size.width - timestampLabelSize.width - 11.0, 5.0, timestampLabelSize.width + 6.0, timestampLabelSize.height + 1.0);
		//MVR - text view
		textView.text = post.text;
		//MVR - determine the height of the text
		textSize = [post.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(tableView.frame.size.width - 10.0, 1000.0) lineBreakMode:UILineBreakModeWordWrap];
		textView.frame = CGRectMake(5.0, usernameLabel.frame.size.height + 5.0, textSize.width, textSize.height);
	} else if ([post.type isEqual:@"ImagePost"]) {
		TTImageView *imageView;
		CGFloat imageWidth;
		CGFloat imageHeight;
		NSString *imagePostUrl;

		cell = (BlogcastrTableViewCell *)[theTableView dequeueReusableCellWithIdentifier:@"ImagePost"];
		//MVR - if cell doesn't exist create it
		if (!cell) {
			cell = [[[BlogcastrTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ImagePost"] autorelease];
			imageView = [[TTImageView alloc] init];
			imageView.backgroundColor = [UIColor clearColor];
			imageView.tag = IMAGE_VIEW_TAG;
			[cell.contentView insertSubview:imageView belowSubview:cell.highlightView];
			[imageView release];
			usernameLabel = [[UILabel alloc] init];
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
		} else {
			imageView = (TTImageView *)[cell viewWithTag:IMAGE_VIEW_TAG];
			usernameLabel = (UILabel *)[cell viewWithTag:USERNAME_LABEL_TAG];
			timestampLabel = (TTStyledTextLabel *)[cell viewWithTag:TIMESTAMP_LABEL_TAG];
			textView = (UILabel *)[cell viewWithTag:TEXT_VIEW_TAG];
		}
		//MVR - image view
		imagePostUrl = [self imagePostUrlForPost:post size:@"default"];
		//MVR - unset the image unless it's the same
		if (![imageView.urlPath isEqualToString:imagePostUrl])
			[imageView unsetImage];
		imageView.urlPath = imagePostUrl;
		if ([post.imageWidth intValue] > [post.imageHeight intValue]) {
			if ([post.imageWidth intValue] > 80.0) {
				imageWidth = 80.0;
				imageHeight = 80.0 * [post.imageHeight intValue] / [post.imageWidth intValue];
			} else {
				imageWidth = [post.imageWidth intValue];
				imageHeight = [post.imageHeight intValue];
			}
		} else {
			if ([post.imageHeight intValue] > 80.0) {
				imageWidth = 80.0 * [post.imageWidth intValue] / [post.imageHeight intValue];
				imageHeight = 80.0;
			} else {
				imageWidth = [post.imageWidth intValue];
				imageHeight = [post.imageHeight intValue];
			}
		}
		imageView.frame = CGRectMake(5.0, 5.0, imageWidth, imageHeight);
		//MVR - username label
		usernameLabel.text = post.user.username;
		[usernameLabel sizeToFit];
		usernameLabel.center = CGPointMake(imageWidth + usernameLabel.frame.size.width / 2.0 + 10.0, 5.0 + usernameLabel.frame.size.height / 2.0);
		//MVR - timestamp label
		timestampLabel.text = [TTStyledText textFromXHTML:[NSString stringWithFormat:@"<span class=\"timestampInWords\">%@<span>", [post.createdAt stringInWords]]];
		timestampLabelSize = [[post.createdAt stringInWords] sizeWithFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:9.0]];
		timestampLabel.frame = CGRectMake(tableView.frame.size.width - timestampLabelSize.width - 11.0, 5.0, timestampLabelSize.width + 6.0, timestampLabelSize.height + 1.0);
		//MVR - text view
		if (post.text) {
			textView.text = post.text;
			//MVR - determine the height of the text
			textSize = [post.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(tableView.frame.size.width - imageWidth - 15.0, 1000.0) lineBreakMode:UILineBreakModeWordWrap];
			textView.frame = CGRectMake(imageWidth + 10.0, usernameLabel.frame.size.height + 5.0, tableView.frame.size.width - imageWidth - 15.0, textSize.height);
		} else {
			textView.text = nil;	
		}
	} else if ([post.type isEqual:@"CommentPost"]) {
		cell = (BlogcastrTableViewCell *)[theTableView dequeueReusableCellWithIdentifier:@"CommentPost"];
		//MVR - if cell doesn't exist create it
		if (!cell) {	
			cell = [[[BlogcastrTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CommentPost"] autorelease];
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
		} else {
			usernameLabel = (UILabel *)[cell viewWithTag:USERNAME_LABEL_TAG];
			timestampLabel = (TTStyledTextLabel *)[cell viewWithTag:TIMESTAMP_LABEL_TAG];
			textView = (UILabel *)[cell viewWithTag:TEXT_VIEW_TAG];
		}
		//MVR - username label
		if ([post.comment.user.type isEqual:@"BlogcastrUser"])
			usernameLabel.text = post.comment.user.username;
		else if ([post.comment.user.type isEqual:@"FacebookUser"])
			usernameLabel.text = post.comment.user.facebookFullName;
		else if ([post.comment.user.type isEqual:@"TwitterUser"])
			usernameLabel.text = post.comment.user.twitterUsername;
		[usernameLabel sizeToFit];
		//MVR - timestamp label
		timestampLabel.text = [TTStyledText textFromXHTML:[NSString stringWithFormat:@"<span class=\"timestampInWords\">%@<span>", [post.createdAt stringInWords]]];
		timestampLabelSize = [[post.createdAt stringInWords] sizeWithFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:9.0]];
		timestampLabel.frame = CGRectMake(tableView.frame.size.width - timestampLabelSize.width - 11.0, 5.0, timestampLabelSize.width + 6.0, timestampLabelSize.height + 1.0);
		//MVR - text view
		textView.text = post.comment.text;
		//MVR - determine the height of the text
		textSize = [post.comment.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(tableView.frame.size.width - 15.0 - kCommentIconWidth, 1000.0) lineBreakMode:UILineBreakModeWordWrap];
		textView.frame = CGRectMake(10.0 + kCommentIconWidth, usernameLabel.frame.size.height + 5.0, textSize.width, textSize.height);
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
	PostStreamCell *streamCell;
	Post *post;
	PostController *postController;
	
	streamCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
	post = streamCell.post;
	postController = [[PostController alloc] initWithNibName:nil bundle:nil];
	postController.managedObjectContext = managedObjectContext;
	postController.session = session;
	postController.post = post;
	if ([post.type isEqual:@"TextPost"])
		postController.title = @"Text Post";
	else if ([post.type isEqual:@"ImagePost"])
		postController.title = @"Image Post";
	else if ([post.type isEqual:@"CommentPost"])
		postController.title = @"Comment Post";
	[tabToolbarController.navigationController pushViewController:postController animated:YES];
	[postController release];
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
	if (scrollView.contentOffset.y > scrollView.contentSize.height - kInfiniteScrollViewHeight - scrollView.bounds.size.height && ![blogcast.postsAtEnd boolValue] && !isUpdatingFooter && [self.minId intValue] > 0) {
		isUpdatingFooter = YES;
		[self updatePostsFooter];
	}
}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
	float systemVersion;
	
	//AS DESIGNED: work around 3.* UITableView bug
	systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	if (systemVersion >= 4.0)
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

	[self errorAlertWithTitle:@"Got message" message:@"Oops! We couldn't update the posts."];
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
	if (![type isEqualToString:@"TextPost"] && ![type isEqualToString:@"ImagePost"] && ![type isEqualToString:@"CommentPost"])
		return;
	//MVR - if we aren't in sync queue up the message to be parsed after we are
	if (isSynced) {
		if ([self addMessage:message]) {
			if (![self save])
				NSLog(@"Error saving post");
			if (self.view.window == nil)
				[self setBadgeVal:[blogcast.postsBadgeVal integerValue] + 1];
		} else {
			NSLog(@"Could not add post to stream");
		}
	} else {
		//MVR - add the message after we sync up
		[self.postMessages addObject:message];
	}
}

#pragma mark -
#pragma mark ASIHTTPRequest callbacks

- (void)updatePostsFinished:(ASIHTTPRequest *)request {
	int statusCode;
	NSInteger numAdded = 0;
	PostsParser *parser;
	Post *post;

	self.postsRequest = nil;
	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Update posts received status code %i", statusCode);
		[self errorAlertWithTitle:@"Update failed" message:@"Oops! We couldn't update the posts."];
		return;
	}
	//MVR - parse xml
	parser = [[PostsParser alloc] init];
	parser.data = [request responseData];
	parser.managedObjectContext = managedObjectContext;
	parser.blogcast = blogcast;
	if (![parser parse]) {
		NSLog(@"Error parsing update posts response");
		[self errorAlertWithTitle:@"Parse error" message:@"Oops! We couldn't update the posts."];
		[parser release];
		return;
	}
	//MVR - add posts above max id
	for (int i = 0; i < parser.posts.count; i++) {
		Post *post;
		
		post = [parser.posts objectAtIndex:i];
		if ([post.id intValue] > [self.maxId intValue]) {
			PostStreamCell *streamCell;
			
			streamCell = [NSEntityDescription insertNewObjectForEntityForName:@"PostStreamCell" inManagedObjectContext:managedObjectContext];
			streamCell.id = post.id;
			streamCell.post = post;
			streamCell.blogcast = blogcast;
			numAdded++;
		}
	}
	//MVR - handle either the footer scroll or cell scroll
	if ([self.maxId intValue] == 0) {
		if (numAdded < kPostsRequestCount) {
			blogcast.postsAtEnd = [NSNumber numberWithBool:YES];
			[infiniteScrollView setLoading:NO];
		} else {
			//MVR - update min id if there may be more to load
			post = [parser.posts objectAtIndex:numAdded - 1];
			self.minId = post.id;
		}
	} else if (numAdded == kPostsRequestCount) {
		post = [parser.posts objectAtIndex:kPostsRequestCount - 1];
		//MVR - add one to make sure there is actually a gap
		if (post.id > self.maxId + 1) {
			PostStreamCell *streamCell;

			streamCell = [NSEntityDescription insertNewObjectForEntityForName:@"PostStreamCell" inManagedObjectContext:managedObjectContext];
			streamCell.id = [NSNumber numberWithInteger:[self.maxId integerValue] + 1];
			streamCell.maxId = [NSNumber numberWithInteger:[post.id integerValue] - 1];
			streamCell.blogcast = blogcast;
		}
	}
	if (numAdded > 0) {
		post = [parser.posts objectAtIndex:0];
		self.maxId = post.id;
	}
	[parser release];
	//MVR - if the array hasn't been allocated yet there is no need to allocate and check it
	if (_postMessages) {
		for (XMPPMessage *message in self.postMessages) {
			if ([self addMessage:message])
				numAdded++;
			else
				NSLog(@"Could not add post to stream");
		}
		[self.postMessages removeAllObjects];
	}
	if (![self save])
		NSLog(@"Error saving posts");
	isSynced = YES;
	//MVR - update the badge value
	if (self.view.window == nil)
		[self setBadgeVal:[blogcast.postsBadgeVal integerValue] + numAdded];
}

- (void)updatePostsFailed:(ASIHTTPRequest *)request {
	NSError *error;
	
	self.postsRequest = nil;
	error = [request error];
	switch ([error code]) {
		case ASIConnectionFailureErrorType:
			NSLog(@"Error updating posts: connection failed %@", [[error userInfo] objectForKey:NSUnderlyingErrorKey]);
			[self errorAlertWithTitle:@"Connection failure" message:@"Oops! We couldn't update the posts."];
			break;
		case ASIRequestTimedOutErrorType:
			NSLog(@"Error updating posts: request timed out");
			[self errorAlertWithTitle:@"Request timed out" message:@"Oops! We couldn't update the posts."];
			break;
		case ASIRequestCancelledErrorType:
			NSLog(@"Update posts request cancelled");
			break;
		default:
			NSLog(@"Error updating posts");
			break;
	}	
}

- (void)updatePostsStreamCellFinished:(ASIHTTPRequest *)request {
	PostStreamCell *streamCell;
	int statusCode;
	PostsParser *parser;
	NSInteger numAdded = 0;
	Post *post;

	[self.streamCellRequests removeObject:request];
	streamCell = (PostStreamCell *)[request.userInfo objectForKey:@"PostStreamCell"];
	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error update posts footer received status code %i", statusCode);
		[self errorAlertWithTitle:@"Update failed" message:@"Oops! We couldn't update your posts."];
		return;
	}
	//MVR - parse response
	parser = [[PostsParser alloc] init];
	parser.data = [request responseData];
	parser.managedObjectContext = managedObjectContext;
	parser.blogcast = blogcast;
	if (![parser parse]) {
		NSLog(@"Error parsing update footer posts response");
		[self errorAlertWithTitle:@"Parse error" message:@"Oops! We couldn't update your posts."];
		[parser release];
		return;
	}
	//MVR - assume all posts are below the stream cell id so add posts above the min id
	for (Post *thePost in parser.posts) {
		if ([thePost.id intValue] >= [streamCell.id intValue]) {
			PostStreamCell *streamCell;
			
			streamCell = [NSEntityDescription insertNewObjectForEntityForName:@"PostStreamCell" inManagedObjectContext:managedObjectContext];
			streamCell.id = thePost.id;
			streamCell.post = thePost;
			streamCell.blogcast = blogcast;
			numAdded++;
		}
	}
	post = [parser.posts lastObject];
	if (numAdded == kPostsRequestCount && post.id != streamCell.id) {
		//MVR - adjust stream cell
		post = [parser.posts objectAtIndex:kPostsRequestCount - 1];
		streamCell.maxId = [NSNumber numberWithInteger:[post.id integerValue] - 1];
	} else {
		//MVR - delete the scroll cell
		[self.managedObjectContext deleteObject:streamCell];
	}
	[parser release];
	if (![self save])
		NSLog(@"Error saving posts");
	//MVR - update the badge value
	if (self.view.window == nil)
		[self setBadgeVal:[blogcast.postsBadgeVal integerValue] + numAdded];
}

- (void)updatePostsStreamCellFailed:(ASIHTTPRequest *)request {
	NSLog(@"Update posts stream cell failed");
	[self.streamCellRequests removeObject:request];
	[self errorAlertWithTitle:@"Update failed" message:@"Oops! We couldn't update the posts."];
}

- (void)updatePostsFooterFinished:(ASIHTTPRequest *)request {
	int statusCode;
	NSInteger numAdded = 0;
	PostsParser *parser;

	isUpdatingFooter = NO;
	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
		NSLog(@"Error update posts footer received status code %i", statusCode);
		[self errorAlertWithTitle:@"Update failed" message:@"Oops! We couldn't update your posts."];
		return;
	}
	//MVR - parse response
	parser = [[PostsParser alloc] init];
	parser.data = [request responseData];
	parser.managedObjectContext = managedObjectContext;
	parser.blogcast = blogcast;
	if (![parser parse]) {
		NSLog(@"Error parsing update footer posts response");
		[self errorAlertWithTitle:@"Parse error" message:@"Oops! We couldn't update your posts."];
		[parser release];
		return;
	}
	//MVR - add posts below min id
	for (Post *post in parser.posts) {
		if ([post.id intValue] < [self.minId intValue]) {
			PostStreamCell *streamCell;
			
			streamCell = [NSEntityDescription insertNewObjectForEntityForName:@"PostStreamCell" inManagedObjectContext:managedObjectContext];
			streamCell.id = post.id;
			streamCell.post = post;
			streamCell.blogcast = blogcast;
			numAdded++;
		}
	}
	//MVR - handle the footer scroll
	if (numAdded < kPostsRequestCount) {
		blogcast.postsAtEnd = [NSNumber numberWithBool:YES];
		[infiniteScrollView setLoading:NO];
	} else {
		Post *post;
		
		post = [parser.posts objectAtIndex:kPostsRequestCount - 1];
		self.minId = post.id;
	}
	[parser release];
	if (![self save])
		NSLog(@"Error saving posts");
	//MVR - update the badge value
	if (self.view.window == nil)
		[self setBadgeVal:[blogcast.postsBadgeVal integerValue] + numAdded];
}

- (void)updatePostsFooterFailed:(ASIHTTPRequest *)request {
	isUpdatingFooter = NO;
	NSLog(@"Error update posts footer failed");
	[self errorAlertWithTitle:@"Update failed" message:@"Oops! We couldn't update your posts."];
}

#pragma mark -
#pragma mark Dashboard notifications

- (void)joinedRoom {
	NSLog(@"MVR - JOINED ROOM!!!");
	isSynced = NO;
	//MVR - if another request has been made cancel it
	if (postsRequest)
		[postsRequest cancel];
	[self updatePosts];
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
	entityDescription = [NSEntityDescription entityForName:@"PostStreamCell" inManagedObjectContext:managedObjectContext];
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
#pragma mark Post stream

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
	entity = [NSEntityDescription entityForName:@"PostStreamCell" inManagedObjectContext:managedObjectContext];
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
	entity = [NSEntityDescription entityForName:@"PostStreamCell" inManagedObjectContext:managedObjectContext];
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

- (void)newTextPost:(id)object {
	UINavigationController *theNavigationController;
	NewTextPostController *newTextPostController;

	newTextPostController = [[NewTextPostController alloc] initWithStyle:UITableViewStyleGrouped];
	newTextPostController.managedObjectContext = managedObjectContext;
	newTextPostController.session = session;
	newTextPostController.blogcast = blogcast;
	theNavigationController = [[UINavigationController alloc] initWithRootViewController:newTextPostController];
	[newTextPostController release];
	theNavigationController.navigationBar.tintColor = TTSTYLEVAR(navigationBarTintColor);
	[self.tabToolbarController presentModalViewController:theNavigationController animated:YES];
	[theNavigationController release];
}

- (void)newImagePost:(id)object {
	UINavigationController *theNavigationController;
	NewImagePostController *newImagePostController;
	
	newImagePostController = [[NewImagePostController alloc] initWithStyle:UITableViewStyleGrouped];
	newImagePostController.managedObjectContext = managedObjectContext;
	newImagePostController.session = session;
	newImagePostController.blogcast = blogcast;
	theNavigationController = [[UINavigationController alloc] initWithRootViewController:newImagePostController];
	[newImagePostController release];
	theNavigationController.navigationBar.tintColor = TTSTYLEVAR(navigationBarTintColor);
	[self.tabToolbarController presentModalViewController:theNavigationController animated:YES];
	[theNavigationController release];
}

- (void)timerExpired:(Timer *)timer {
	if (timer == slowTimer) {
		//MVR - reload the entire table to update timestamps since there's no easy way to get the text out of the TTStyledTextLabel
		[tableView reloadData];		
	} else if (timer == fastTimer) {
		//MVR - scroll cell logic
		for (UITableViewCell *cell in tableView.visibleCells) {
			PostStreamCell *streamCell;
			NSIndexPath *indexPath;
			
			indexPath = [tableView indexPathForCell:cell];
			if (!indexPath) {
				NSLog(@"Could not find post stream cell index path");
				continue;
			}
			streamCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
			if (!streamCell.post) {
				if (![self isStreamCellRequested:streamCell])
					[self updatePostsStreamCell:streamCell];
			}
		}
	}
}

#pragma mark -
#pragma mark Helpers

- (void)updatePosts {
	NSURL *url;
	ASIHTTPRequest *request;
	
	url = [self postsUrlWithMaxId:0 count:kPostsRequestCount];	
	request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(updatePostsFinished:)];
	[request setDidFailSelector:@selector(updatePostsFailed:)];
	[request startAsynchronous];
	self.postsRequest = request;
}

- (void)updatePostsStreamCell:(PostStreamCell *)streamCell {
	NSURL *url;
	ASIHTTPRequest *request;
	
	url = [self postsUrlWithMaxId:[streamCell.maxId intValue] count:kPostsRequestCount];	
	request = [ASIHTTPRequest requestWithURL:url];
	request.userInfo = [NSDictionary dictionaryWithObject:streamCell forKey:@"PostStreamCell"];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(updatePostsStreamCellFinished:)];
	[request setDidFailSelector:@selector(updatePostsStreamCellFailed:)];
	[request startAsynchronous];
	//MVR - add to stream cell request array
	[self.streamCellRequests addObject:request];
}

- (void)updatePostsFooter {
	NSURL *url;
	ASIHTTPRequest *request;
	
	url = [self postsUrlWithMaxId:[self.minId intValue] - 1 count:kPostsRequestCount];	
	request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(updatePostsFooterFinished:)];
	[request setDidFailSelector:@selector(updatePostsFooterFailed:)];
	[request startAsynchronous];
	isUpdatingFooter = YES;
}

- (NSURL *)postsUrlWithMaxId:(NSInteger)maxId count:(NSInteger)count {
	NSString *string;
	NSURL *url;
	
#ifdef DEVEL
	string = [[NSString stringWithFormat:@"http://sandbox.blogcastr.com/blogcasts/%d/posts.xml?count=%d", [blogcast.id intValue], count] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else //DEVEL
	string = [[NSString stringWithFormat:@"http://blogcastr.com/blogcasts/%d/posts.xml?count=%d", [blogcast.id intValue], count] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#endif //DEVEL
	//MVR - add a max id if set
	if (maxId)
		string = [string stringByAppendingString:[[NSString stringWithFormat:@"&max_id=%d", maxId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	url = [NSURL URLWithString:string];
	
	return url;
}

- (NSString *)imagePostUrlForPost:(Post *)post size:(NSString *)size {
	NSString *imagePostUrl;
	NSRange range;
	
#ifdef DEVEL
	imagePostUrl = [NSString stringWithFormat:@"http://sandbox.blogcastr.com%@", post.imageUrl];
#else //DEVEL
	imagePostUrl = [[post.imageUrl copy] autorelease];
#endif //DEVEL
	range = [imagePostUrl rangeOfString:@"original"];
	if (range.location != NSNotFound) {
		return [imagePostUrl stringByReplacingCharactersInRange:range withString:size];
	} else {
		NSLog(@"Error replacing size in image post url: %@", imagePostUrl);
		return imagePostUrl;
	}
}

- (BOOL)isStreamCellRequested:(PostStreamCell *)streamCell {
	for (ASIHTTPRequest *request in self.streamCellRequests) {
		PostStreamCell *theStreamCell;

		theStreamCell = (PostStreamCell *)[request.userInfo objectForKey:@"PostStreamCell"];
		if (theStreamCell == streamCell)
			return YES;
	}
	
	return NO;
}

- (Post *)parseMessage:(XMPPMessage *)message {
	NSXMLElement *bodyElement;
	NSString *postType;
	NSString *postId;
	NSString *postCreatedAt;
	NSString *string;
	NSDate *date;
	NSString *postText;
	NSString *postImageUrl;
	NSString *postImageWidth;
	NSString *postImageHeight;
	NSXMLElement *postUserElement;
	NSString *postUserId;
	NSString *postUserUsername;
	NSString *postUserAvatarUrl;
	NSString *commentId;
	NSString *commentCreatedAt;
	NSString *commentUserId;
	NSString *commentUserType;
	NSString *commentUserUsername;
	NSString *commentUserUrl;
	NSString *commentUserAvatarUrl;
	NSFetchRequest *request;
	NSEntityDescription *entity;
	NSPredicate *predicate;
	NSArray *array;
	Post *post;
	User *postUser;
	NSError *error;
	
	//MVR - we know the body and post type exist
	bodyElement = [message elementForName:@"body"];
	postType = [[bodyElement elementForName:@"type"] stringValue];
	postId = [[bodyElement elementForName:@"id"] stringValue];
	if (!postId) {
		NSLog(@"Error finding post id in XMPP message");
		return nil;
	}
	postCreatedAt = [[bodyElement elementForName:@"created-at"] stringValue];
	if (!postCreatedAt) {
		NSLog(@"Error finding post created at in XMPP message");
		return nil;
	}
	if ([postType isEqual:@"TextPost"]) {
		postText = [[bodyElement elementForName:@"text"] stringValue];
		if (!postText) {
			NSLog(@"Error finding post text in XMPP message");
			return nil;
		}
	} else if ([postType isEqual:@"ImagePost"]) {
		postText = [[bodyElement elementForName:@"text"] stringValue];
		postImageUrl = [[bodyElement elementForName:@"image-url"] stringValue];
		if (!postImageUrl) {
			NSLog(@"Error finding post image url in XMPP message");
			return nil;
		}
		postImageWidth = [[bodyElement elementForName:@"image-width"] stringValue];
		if (!postImageWidth) {
			NSLog(@"Error finding post image width in XMPP message");
			return nil;
		}
		postImageHeight = [[bodyElement elementForName:@"image-height"] stringValue];
		if (!postImageHeight) {
			NSLog(@"Error finding post image height in XMPP message");
			return nil;
		}
	} else if ([postType isEqual:@"CommentPost"]) {
		NSXMLElement *commentElement;
		NSXMLElement *commentUserElement;

		commentElement = [bodyElement elementForName:@"comment"];
		if (!commentElement) {
			NSLog(@"Error finding comment element in XMPP message");
			return nil;
		}
		commentId = [[commentElement elementForName:@"id"] stringValue];
		if (!commentId) {
			NSLog(@"Error finding comment id in XMPP message");
			return nil;
		}
		commentCreatedAt = [[commentElement elementForName:@"created-at"] stringValue];
		if (!commentCreatedAt) {
			NSLog(@"Error finding comment created at in XMPP message");
			return nil;
		}
		postText = [[commentElement elementForName:@"text"] stringValue];
		if (!postText) {
			NSLog(@"Error finding comment text in XMPP message");
			return nil;
		}
		commentUserElement = [commentElement elementForName:@"user"];
		if (!commentUserElement) {
			NSLog(@"Error finding comment user element in XMPP message");
			return nil;
		}
		commentUserId = [[commentUserElement elementForName:@"id"] stringValue];
		if (!commentUserId) {
			NSLog(@"Error finding comment user id in XMPP message");
			return nil;
		}
		commentUserType = [[commentUserElement elementForName:@"type"] stringValue];
		if (!commentUserType) {
			NSLog(@"Error finding comment user type in XMPP message");
			return nil;
		}
		commentUserUsername = [[commentUserElement elementForName:@"username"] stringValue];
		if (!commentUserUsername) {
			NSLog(@"Error finding comment user username in XMPP message");
			return nil;
		}
		commentUserUrl = [[commentUserElement elementForName:@"url"] stringValue];
		if (!commentUserUrl) {
			NSLog(@"Error finding comment user url in XMPP message");
			return nil;
		}
		commentUserAvatarUrl = [[commentUserElement elementForName:@"avatar-url"] stringValue];
		if (!commentUserAvatarUrl) {
			NSLog(@"Error finding comment user avatar url in XMPP message");
			return nil;
		}
	}
	postUserElement = [bodyElement elementForName:@"user"];
	if (!postUserElement) {
		NSLog(@"Error finding post user element in XMPP message");
		return nil;
	}
	postUserId = [[postUserElement elementForName:@"id"] stringValue];
	if (!postUserId) {
		NSLog(@"Error finding post user id in XMPP message");
		return nil;
	}
	postUserUsername = [[postUserElement elementForName:@"username"] stringValue];
	if (!postUserUsername) {
		NSLog(@"Error finding post user username in XMPP message");
		return nil;
	}
	postUserAvatarUrl = [[postUserElement elementForName:@"avatar-url"] stringValue];
	if (!postUserAvatarUrl) {
		NSLog(@"Error finding post user avatar url in XMPP message");
		return nil;
	}
	//MVR - find post user if they exist
	request = [[NSFetchRequest alloc] init];
	entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	predicate = [NSPredicate predicateWithFormat:@"id = %d", [postUserId intValue]];
	[request setPredicate:predicate];
	//MVR - execute the fetch
	array = [managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	//MVR - create post user if they don't exist
	if ([array count] > 0) {
		postUser = [array objectAtIndex:0];
	} else {
		postUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
		postUser.id = [NSNumber numberWithInteger:[postUserId integerValue]];
		//MVR - only Blogcastr users can make posts
		postUser.type = @"BlogcastrUser";
		postUser.username = postUserUsername;
		postUser.avatarUrl = postUserAvatarUrl;
	}
	//MVR - parsing done create the post
	post = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:managedObjectContext];
	post.id = [NSNumber numberWithInteger:[postId integerValue]];
	post.blogcast = blogcast;
	post.type = postType;
	//MVR - convert date string
	string = [NSString stringWithFormat:@"%@ %@ %@%@", [postCreatedAt substringToIndex:10], [postCreatedAt substringWithRange:NSMakeRange(11, 8)], [postCreatedAt substringWithRange:NSMakeRange(19, 3)], [postCreatedAt substringWithRange:NSMakeRange(23, 2)]];
	date = [[NSDate alloc] initWithString:string];
	post.createdAt = date;
	[date release];
	post.user = postUser;
	if ([postType isEqual:@"TextPost"]) {
		post.text = postText;
	} else if ([postType isEqual:@"ImagePost"]) {
		if (postText)
			post.text = postText;
		post.imageUrl = postImageUrl;
		post.imageWidth = [NSNumber numberWithInteger:[postImageWidth integerValue]];
		post.imageHeight = [NSNumber numberWithInteger:[postImageHeight integerValue]];
	} else if ([postType isEqual:@"CommentPost"]) {
		User *commentUser;
		Comment *comment;

		//MVR - find comment user if they exist
		request = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];
		predicate = [NSPredicate predicateWithFormat:@"id = %d", [commentUserId intValue]];
		[request setPredicate:predicate];
		//MVR - execute the fetch
		array = [managedObjectContext executeFetchRequest:request error:&error];
		[request release];
		//MVR - create user if they don't exist
		if ([array count] > 0) {
			commentUser = [array objectAtIndex:0];
		} else {
			commentUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
			commentUser.id = [NSNumber numberWithInteger:[commentUserId integerValue]];
			commentUser.type = commentUserType;
			if ([commentUserType isEqual:@"BlogcastrUser"]) {
				commentUser.username = commentUserUsername;
			} else if ([commentUserType isEqual:@"FacebookUser"]) {
				commentUser.facebookFullName = commentUserUsername;
				commentUser.facebookLink = commentUserUrl;
			} else if ([commentUserType isEqual:@"TwitterUser"]) {
				commentUser.twitterUsername = commentUserUsername;
			}
			commentUser.avatarUrl = commentUserAvatarUrl;
		}
		//MVR - find comment if it exists
		request = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];
		predicate = [NSPredicate predicateWithFormat:@"id = %d", [commentId intValue]];
		[request setPredicate:predicate];
		//MVR - execute the fetch
		array = [managedObjectContext executeFetchRequest:request error:&error];
		[request release];
		//MVR - create comment if it doesn't exist
		if ([array count] > 0) {
			comment = [array objectAtIndex:0];
		} else {
			comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:managedObjectContext];
			comment.id = [NSNumber numberWithInteger:[commentId integerValue]];
			comment.blogcast = blogcast;
			//AS DESIGNED: use the post equivalent variable
			comment.text = postText;
			comment.user = commentUser;
			string = [NSString stringWithFormat:@"%@ %@ %@%@", [commentCreatedAt substringToIndex:10], [commentCreatedAt substringWithRange:NSMakeRange(11, 8)], [commentCreatedAt substringWithRange:NSMakeRange(19, 3)], [commentCreatedAt substringWithRange:NSMakeRange(23, 2)]];
			date = [[NSDate alloc] initWithString:string];
			comment.createdAt = date;
			[date release];
		}
		post.comment = comment;
	}

	return post;
}

- (BOOL)addMessage:(XMPPMessage *)message {
	Post *post;

	post = [self parseMessage:message];
	if (!post) {
		NSLog(@"Error parsing XMPP post message");
		[self errorAlertWithTitle:@"Parse error" message:@"Oops! We couldn't parse the post."];
		return NO;
	}
	//MVR - now add the stream cell
	if ([post.id intValue] > [self.maxId intValue]) {
		PostStreamCell *streamCell;
	
		streamCell = [NSEntityDescription insertNewObjectForEntityForName:@"PostStreamCell" inManagedObjectContext:managedObjectContext];
		streamCell.id = post.id;
		streamCell.post = post;
		streamCell.blogcast = blogcast;
		self.maxId = post.id;
	}

	return YES;
}

- (void)setBadgeVal:(NSInteger)val {
	//MVR - update and save the badge value
	blogcast.postsBadgeVal = [NSNumber numberWithInteger:val];
	if (![self save])
		NSLog(@"Error saving posts badge value");
	if (val)
		self.tabBarItem.badgeValue = [blogcast.postsBadgeVal stringValue];
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
