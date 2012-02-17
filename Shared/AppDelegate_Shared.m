//
//  AppDelegate_Shared.m
//  Blogcastr
//
//  Created by Matthew Rushton on 2/21/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "AppDelegate_Shared.h"
#import "ASIFormDataRequest.h"
#import "UserParser.h"
#import "NSDate+Format.h"


@implementation AppDelegate_Shared

@synthesize window;
@synthesize facebookConnectDelegate;


#pragma mark -
#pragma mark Application lifecycle

/**
 Save changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self saveContext];
}


- (void)saveContext {
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    
    


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Blogcastr" withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Blogcastr.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    //MVR - added for lightweight migrations
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark -
#pragma mark URL management

// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url]; 
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    [_session release];
    [_facebook release];
    [window release];
    [super dealloc];
}

- (Session *)session {
	NSFetchRequest *fetchRequest;
	NSEntityDescription *entityDescription;
	NSArray *array;
	NSError *error;
	
	//MVR - get Session
	if (_session)
		return _session;
	fetchRequest = [[NSFetchRequest alloc] init];
	entityDescription = [NSEntityDescription entityForName:@"Session" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entityDescription];
	array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	//MVR - if array is nil there was an error
	if (!array) {
		NSLog(@"Error fetching Session: %@", [error localizedDescription]);
		return nil;
	}
	if ([array count] > 0)
		_session = [array objectAtIndex:0];
	else
		_session = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:self.managedObjectContext];

	return _session;
}

- (Facebook *)facebook {
    if (!_facebook)
        _facebook = [[Facebook alloc] initWithAppId:@"130902392002" andDelegate:self];
    
    return _facebook;
}

#pragma mark -
#pragma mark FBSessionDelegate methods

- (void)fbDidLogin {
    ASIFormDataRequest *request;

    [facebookConnectDelegate facebookIsConnecting];
    request = [self facebookConnectRequest];
    [request startAsynchronous];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    [facebookConnectDelegate facebookDidNotConnect:cancelled];
}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt {
    ASIFormDataRequest *request;
    
    //MVR - extend the Facebook token
    request = [ASIFormDataRequest requestWithURL:[self facebookExtendUrl]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(facebookExtendFinished:)];
	[request setDidFailSelector:@selector(facebookExtendFailed:)];
	[request addPostValue:self.session.user.authenticationToken forKey:@"authentication_token"];
	[request addPostValue:self.facebook.accessToken forKey:@"blogcastr_user[facebook_access_token]"];
    [request addPostValue:[self.facebook.expirationDate iso8601] forKey:@"blogcastr_user[facebook_expires_at]"];  
    [request startAsynchronous];
}

- (void)fbDidLogout {
    
}

- (void)fbSessionInvalidated {
    ASIFormDataRequest *request;
    
    //MVR - invalidate the Facebook token
    request = [ASIFormDataRequest requestWithURL:[self facebookInvalidateUrl]];
    [request setRequestMethod:@"DELETE"];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(facebookInvalidateFinished:)];
	[request setDidFailSelector:@selector(facebookInvalidateFailed:)];
    [request startAsynchronous];
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate

- (void)facebookConnectFinished:(ASIHTTPRequest *)request {
	int statusCode;
	UserParser *userParser;

	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
        NSLog(@"Facebook connect received status %d", statusCode);
        if (facebookConnectDelegate)
            [facebookConnectDelegate facebookConnectFailed:nil];
        [self.facebook logout];
		return;
	}
	//MVR - parse response
	userParser = [[UserParser alloc] init];
	userParser.data = [request responseData];
	userParser.managedObjectContext = [self managedObjectContext];
	if (![userParser parse]) {
		NSLog(@"Error parsing Facebook connect response");
        [userParser release];
        if (facebookConnectDelegate)
            [facebookConnectDelegate facebookConnectFailed:nil];
        [self.facebook logout];
		return;
	}
	userParser.user.updatedAt = [NSDate date];
	[self saveContext];
	[userParser release];
    if (facebookConnectDelegate)
        [facebookConnectDelegate facebookDidConnect];
    //MVR - send settings updated notification
	[[NSNotificationCenter defaultCenter] postNotificationName:@"updatedSettings" object:self];
    //MVR - always update the token to work around a bug in the Facebook library
    [self.facebook extendAccessToken];
}

- (void)facebookConnectFailed:(ASIHTTPRequest *)request {
    NSLog(@"Facebook connect failed");
    if (facebookConnectDelegate)
        [facebookConnectDelegate facebookConnectFailed:[request error]];
    [self.facebook logout];
}

- (void)facebookExtendFinished:(ASIHTTPRequest *)request {
    int statusCode;
    
	statusCode = [request responseStatusCode];
	if (statusCode != 200) {
        NSLog(@"Facebook extend received status %d", statusCode);
        return;
    }
    //MVR - save the updated expiration
    self.session.user.facebookExpiresAt = self.facebook.expirationDate;
    [self saveContext];
}

- (void)facebookExtendFailed:(ASIHTTPRequest *)request {
    NSLog(@"Facebook extend failed");
}

- (void)facebookInvalidateFinished:(ASIHTTPRequest *)request {
    int statusCode;

	statusCode = [request responseStatusCode];
	if (statusCode != 200)
        NSLog(@"Facebook invalidate received status %d", statusCode);
}

- (void)facebookInvalidateFailed:(ASIHTTPRequest *)request {
    NSLog(@"Facebook invalidate failed");
}

#pragma mark -
#pragma mark Helpers
     
- (NSURL *)facebookConnectUrl {
    NSString *string;
    NSURL *url;
         
#ifdef DEVEL
    string = @"http://sandbox.blogcastr.com/facebook_connect.xml";
#else //DEVEL
    string = @"http://blogcastr.com/facebook_connect.xml";
#endif //DEVEL
    url = [NSURL URLWithString:string];
         
    return url;
}

- (ASIFormDataRequest *)facebookConnectRequest {
    ASIFormDataRequest *request;
    
    //MVR - save to server and get Facebook info
    request = [ASIFormDataRequest requestWithURL:[self facebookConnectUrl]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(facebookConnectFinished:)];
	[request setDidFailSelector:@selector(facebookConnectFailed:)];
	[request addPostValue:self.session.user.authenticationToken forKey:@"authentication_token"];
	[request addPostValue:self.facebook.accessToken forKey:@"blogcastr_user[facebook_access_token]"];
    [request addPostValue:[self.facebook.expirationDate iso8601] forKey:@"blogcastr_user[facebook_expires_at]"];  
    
    return request;
}

- (NSURL *)facebookExtendUrl {
    NSString *string;
    NSURL *url;
    
#ifdef DEVEL
    string = @"http://sandbox.blogcastr.com/facebook_extend.xml";
#else //DEVEL
    string = @"http://blogcastr.com/facebook_extend.xml";
#endif //DEVEL
    url = [NSURL URLWithString:string];
    
    return url;
}

- (NSURL *)facebookInvalidateUrl {
    NSString *string;
    NSURL *url;
    
#ifdef DEVEL
	string = [NSString stringWithFormat:@"http://sandbox.blogcastr.com/facebook_invalidate.xml?authentication_token=%@", self.session.user.authenticationToken];
#else //DEVEL
	string = [NSString stringWithFormat:@"http://blogcastr.com/facebook_invalidate.xml?authentication_token=%@", self.session.user.authenticationToken];
#endif //DEVEL
    url = [NSURL URLWithString:string];
    
    return url;
}

@end

