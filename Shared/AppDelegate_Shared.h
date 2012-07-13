//
//  AppDelegate_Shared.h
//  Blogcastr
//
//  Created by Matthew Rushton on 2/21/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Session.h"
#import "ASIFormDataRequest.h"
#import "FBConnect.h"

#define VERSION_MAJOR 2
#define VERSION_MINOR 1

@protocol FacebookConnectDelegate <NSObject>

- (void)facebookIsConnecting;
- (void)facebookDidConnect;
- (void)facebookDidNotConnect:(BOOL)cancelled;
- (void)facebookConnectFailed:(NSError *)error;

@end

@interface AppDelegate_Shared : NSObject <UIApplicationDelegate, FBSessionDelegate> {
    
    UIWindow *window;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	Session *_session;
    Facebook *_facebook;
    id<FacebookConnectDelegate> facebookConnectDelegate;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) Session *session;
@property (nonatomic, retain, readonly) Facebook *facebook;
@property (nonatomic, assign) id<FacebookConnectDelegate> facebookConnectDelegate;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;
- (NSURL *)facebookConnectUrl;
- (ASIFormDataRequest *)facebookConnectRequest;
- (NSURL *)facebookExtendUrl;
- (NSURL *)facebookInvalidateUrl;

@end

