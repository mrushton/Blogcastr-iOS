//
//  BlogcastsController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/2/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "TabToolbarController.h"
#import "Session.h"
#import "User.h"
#import "BlogcastStreamCell.h"
#import "XMPPStream.h"
#import "ASIHTTPRequest.h"
#import "Timer.h"
#import "FBConnect.h"

#define SLOW_TIMER_INTERVAL 30.0
#define FAST_TIMER_INTERVAL 2.0

@interface BlogcastsController : UITableViewController <TabToolbarControllerProtocol, NSFetchedResultsControllerDelegate, TimerProtocol> {
	TabToolbarController *tabToolbarController;
	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *_fetchedResultsController;
	Session *session;
    Facebook *facebook;
	XMPPStream *xmppStream;
	TTTableHeaderDragRefreshView *dragRefreshView;
	TTTableFooterInfiniteScrollView *infiniteScrollView;
	ASIHTTPRequest *blogcastsRequest;
	ASIHTTPRequest *blogcastsFooterRequest;
	NSMutableArray *_streamCellRequests;
	Timer *slowTimer;
	Timer *fastTimer;
	//MVR - for the drag refresh view
	BOOL isRefreshing;
	BOOL isUpdating;
	BOOL isUpdatingFooter;
	NSNumber *_maxId;
	NSNumber *_minId;
	UIAlertView *_alertView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) XMPPStream *xmppStream;
//AS DESIGNED: keep a weak reference to avoid retian cycles
@property (nonatomic, assign) TabToolbarController *tabToolbarController;
@property (nonatomic, retain) TTTableHeaderDragRefreshView *dragRefreshView;
@property (nonatomic, retain) TTTableFooterInfiniteScrollView *infiniteScrollView;
@property (nonatomic, readonly) NSMutableArray *streamCellRequests;
@property (nonatomic, retain) ASIHTTPRequest *blogcastsRequest;
@property (nonatomic, retain) ASIHTTPRequest *blogcastsFooterRequest;
@property (nonatomic, retain) Timer *slowTimer;
@property (nonatomic, retain) Timer *fastTimer;
@property (nonatomic, retain) NSNumber *maxId;
@property (nonatomic, retain) NSNumber *minId;
@property (nonatomic, readonly) UIAlertView *alertView;

- (void)updateBlogcasts;
- (void)updateBlogcastsStreamCell:(BlogcastStreamCell *)streamCell;
- (void)updateBlogcastsFooter;
- (BOOL)save;
- (NSURL *)blogcastsUrlWithMaxId:(NSInteger)maxId count:(NSInteger)count;
- (NSString *)imageUrl:(NSString *)string forSize:(NSString *)size;
- (BOOL)isStreamCellRequested:(BlogcastStreamCell *)streamCell;
- (TTStyledTextLabel *)timestampLabel;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
