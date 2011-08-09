//
//  PostsController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/30/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Three20/Three20.h>
#import "TabToolbarController.h"
#import "Session.h"
#import "Blogcast.h"
#import "PostStreamCell.h"
#import "XMPPStream.h"
#import "ASIHTTPRequest.h"
#import "Timer.h"

#define USERNAME_LABEL_TAG 1
#define TIMESTAMP_LABEL_TAG 2
#define TEXT_VIEW_TAG 3
#define IMAGE_VIEW_TAG 4
#define FAST_TIMER_INTERVAL 2.0
#define SLOW_TIMER_INTERVAL 30.0

@interface PostsController : UIViewController <TabToolbarControllerProtocol, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, TimerProtocol> {
	TabToolbarController *tabToolbarController;
	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *_fetchedResultsController;
	Session *session;
	Blogcast *blogcast;
	XMPPStream *xmppStream;
	UITableView *tableView;
	TTTableFooterInfiniteScrollView *infiniteScrollView;
	NSMutableArray *_postMessages;
	ASIHTTPRequest *postsRequest;
	ASIHTTPRequest *postsFooterRequest;
	NSMutableArray *_streamCellRequests;
	BOOL isSynced;
	BOOL isUpdatingFooter;
	NSNumber *_maxId;
	NSNumber *_minId;
	Timer *fastTimer;
	Timer *slowTimer;
	UIAlertView *_alertView;
}

//AS DESIGNED: keep a weak reference to avoid retian cycles
@property (nonatomic, assign) TabToolbarController *tabToolbarController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Blogcast *blogcast;
@property (nonatomic, retain) XMPPStream *xmppStream;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) TTTableFooterInfiniteScrollView *infiniteScrollView;
@property (nonatomic, readonly) NSMutableArray *postMessages;
@property (nonatomic, readonly) NSMutableArray *streamCellRequests;
@property (nonatomic, retain) ASIHTTPRequest *postsRequest;
@property (nonatomic, retain) ASIHTTPRequest *postsFooterRequest;
@property (nonatomic, retain) NSNumber *maxId;
@property (nonatomic, retain) NSNumber *minId;
@property (nonatomic, retain) Timer *fastTimer;
@property (nonatomic, retain) Timer *slowTimer;
@property (nonatomic, readonly) UIAlertView *alertView;

- (void)updatePosts;
- (void)updatePostsStreamCell:(PostStreamCell *)streamCell;
- (void)updatePostsFooter;
- (NSURL *)postsUrlWithMaxId:(NSInteger)maxId count:(NSInteger)count;
- (BOOL)save;
- (NSString *)imagePostUrlForPost:(Post *)post size:(NSString *)size;
- (BOOL)isStreamCellRequested:(PostStreamCell *)streamCell;
- (Post *)parseMessage:(XMPPMessage *)message;
- (BOOL)addMessage:(XMPPMessage *)message;
- (void)setBadgeVal:(NSInteger)val;
- (TTStyledTextLabel *)timestampLabel;
- (void)timerExpired:(Timer *)timer;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
