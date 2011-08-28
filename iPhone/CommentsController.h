//
//  CommentsController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 6/4/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Three20/Three20.h>
#import "TabToolbarController.h"
#import "Session.h"
#import "Blogcast.h"
#import "CommentStreamCell.h"
#import "XMPPStream.h"
#import "ASIHTTPRequest.h"
#import "Timer.h"

#define FAST_TIMER_INTERVAL 2.0
#define SLOW_TIMER_INTERVAL 30.0

@interface CommentsController : UITableViewController <TabToolbarControllerProtocol, NSFetchedResultsControllerDelegate, TimerProtocol> {
	TabToolbarController *tabToolbarController;
	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *_fetchedResultsController;
	Session *session;
	Blogcast *blogcast;
	XMPPStream *xmppStream;
	TTTableFooterInfiniteScrollView *infiniteScrollView;
	NSMutableArray *_commentMessages;
	ASIHTTPRequest *commentsRequest;
	ASIHTTPRequest *commentsFooterRequest;
	NSMutableArray *_streamCellRequests;
	BOOL isSynced;
	BOOL isUpdatingFooter;
	BOOL isTableViewRendered;
	BOOL retryUpdate;
	NSNumber *_maxId;
	NSNumber *_minId;
	Timer *slowTimer;
	Timer *fastTimer;
	UIAlertView *_alertView;
}

//AS DESIGNED: keep a weak reference to avoid retian cycles
@property (nonatomic, assign) TabToolbarController *tabToolbarController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) Blogcast *blogcast;
@property (nonatomic, retain) XMPPStream *xmppStream;
@property (nonatomic, retain) TTTableFooterInfiniteScrollView *infiniteScrollView;
@property (nonatomic, readonly) NSMutableArray *commentMessages;
@property (nonatomic, readonly) NSMutableArray *streamCellRequests;
@property (nonatomic, retain) ASIHTTPRequest *commentsRequest;
@property (nonatomic, retain) ASIHTTPRequest *commentsFooterRequest;
@property (nonatomic, retain) NSNumber *maxId;
@property (nonatomic, retain) NSNumber *minId;
@property (nonatomic, readonly) UIAlertView *alertView;
@property (nonatomic, retain) Timer *fastTimer;
@property (nonatomic, retain) Timer *slowTimer;

- (void)updateComments;
- (void)updateCommentsStreamCell:(CommentStreamCell *)streamCell;
- (void)updateCommentsFooter;
- (NSURL *)commentsUrlWithMaxId:(NSInteger)maxId count:(NSInteger)count;
- (BOOL)save;
- (BOOL)isStreamCellRequested:(CommentStreamCell *)streamCell;
- (Comment *)parseMessage:(XMPPMessage *)message;
- (BOOL)addMessage:(XMPPMessage *)message;
- (void)setBadgeVal:(NSInteger)val;
- (TTStyledTextLabel *)timestampLabel;
- (void)timerExpired:(Timer *)timer;
- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
