//
//  AppDelegate_iPhone.m
//  Blogcastr
//
//  Created by Matthew Rushton on 2/21/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "SettingsController.h"
#import "HomeController.h"
#import "UserController.h"
#import "SignInController.h"

@implementation AppDelegate_iPhone


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	UIViewController *blogcastsController;
	UserController *userController;
	SettingsController *settingsController;
	HomeController *homeController;
	Session *session;

    // Override point for customization after application launch.
	//MVR - always add the root controller and present the session controller modally if not signed in
	//MVR - create the home controller at the bottom of the navigation controller stack
	session = self.session;
	if (!session) {
		NSLog(@"Unable to get session");
		return NO;
	}
	homeController = [[HomeController alloc] init];
	userController = [[UserController alloc] initWithStyle:UITableViewStylePlain];
	userController.tabBarItem.title = @"Profile";
	settingsController = [[SettingsController alloc] initWithStyle:UITableViewStyleGrouped];
	settingsController.managedObjectContext = self.managedObjectContext;
	settingsController.session = session;
	homeController.viewControllers = [NSArray arrayWithObjects:userController, settingsController, nil];
	rootController = [[RootController_iPhone alloc] initWithRootViewController:homeController]; 
	rootController.managedObjectContext = self.managedObjectContext;
	rootController.session = session;
	[window addSubview:rootController.view];
	if (!session.authenticationToken) {
		SignInController *signInController;
		
		signInController = [[SignInController alloc] init];
		signInController.managedObjectContext = self.managedObjectContext;
		signInController.session = session;
		signInController.delegate = rootController;
		[rootController presentModalViewController:signInController animated:NO];
		[signInController release];
	}
	else {
		homeController.title = session.user.username;
	}

	[session release];
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.

     Superclass implementation saves changes in the application's managed object context before the application terminates.
     */
	[super applicationDidEnterBackground:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 Superclass implementation saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[super applicationWillTerminate:application];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    [super applicationDidReceiveMemoryWarning:application];
}


- (void)dealloc {
	
	[super dealloc];
}


@end

