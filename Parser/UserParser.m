//
//  UserParser.m
//  Blogcastr
//
//  Created by Matthew Rushton on 7/17/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "UserParser.h"
#import "User.h"


@implementation UserParser

@synthesize managedObjectContext;
@synthesize data;
@synthesize subscription;
@synthesize mutableString;
@synthesize userId;
@synthesize username;
@synthesize location;
@synthesize bio;
@synthesize fullName;
@synthesize web;
@synthesize avatarUrl;
@synthesize authenticationToken;
@synthesize numBlogcasts;
@synthesize numSubscriptions;
@synthesize numSubscribers;
@synthesize numPosts;
@synthesize numComments;
@synthesize numLikes;
@synthesize user;

#pragma mark -
#pragma mark Methods

- (BOOL)parse {
	NSXMLParser *parser;
	
    //MVR - parse xml
	parser = [[NSXMLParser alloc] initWithData:data];
	[parser setDelegate:self];
	if ([parser parse]) {
		[parser release];
		return TRUE;
	} else {
		[parser release];
		return FALSE;	
	}
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[data release];
	[managedObjectContext release];
    [mutableString release];
	[userId release];
	[username release];
	[location release];
	[bio release];
	[web release];
	[avatarUrl release];
	[authenticationToken release];
	[numBlogcasts release];
	[numSubscriptions release];
	[numSubscribers release];
	[numPosts release];
	[numComments release];
	[numLikes release];
	[user release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	self.mutableString = nil;
	self.userId = nil;
	self.username = nil;
	self.location = nil;
	self.bio = nil;
	self.web = nil;
	self.avatarUrl = nil;
	self.authenticationToken = nil;
	self.numBlogcasts = nil;
	self.numSubscriptions = nil;
	self.numSubscribers = nil;
	self.numPosts = nil;
	self.numComments = nil;
	self.numLikes = nil;
	self.user = nil;
	inStats = NO;
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqual:@"stats"])
		inStats = YES;
	//MVR - need to reset string here to handle white space
    self.mutableString = nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqual:@"user"]) {
		NSFetchRequest *request;
		NSEntityDescription *entity;
		NSPredicate *predicate;
		NSArray *array;
		User *theUser;
		NSError *error;
		
		//MVR - find user if they exists
		request = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];	
		predicate = [NSPredicate predicateWithFormat:@"id = %d", [userId intValue]];
		[request setPredicate:predicate];
		//MVR - execute the fetch
		array = [managedObjectContext executeFetchRequest:request error:&error];
		[request release];
		//MVR - create post if it doesn't exist
		if ([array count] > 0)
			theUser = [array objectAtIndex:0];
		else
			theUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
		theUser.id = userId;
		self.userId = nil;
		//MVR - parser only handles Blogcastr users
		theUser.type = @"BlogcastrUser";
		theUser.username = username;
		self.username = nil;
		theUser.fullName = fullName;
		self.fullName = nil;
		theUser.location = location;
		self.location = nil;
		theUser.bio = bio;
		self.bio = nil;
		theUser.web = web;
		self.web = nil;
		theUser.avatarUrl = avatarUrl;
		self.avatarUrl = nil;
		//MVR - do not clear the authentication token
		if (authenticationToken)
			theUser.authenticationToken = authenticationToken;
		self.authenticationToken = nil;
		theUser.numBlogcasts = numBlogcasts;
		self.numBlogcasts = nil;
		theUser.numSubscriptions = numSubscriptions;
		self.numSubscriptions = nil;
		theUser.numSubscribers = numSubscribers;
		self.numSubscribers = nil;
		theUser.numPosts = numPosts;
		self.numPosts = nil;
		theUser.numComments = numComments;
		self.numComments = nil;
		theUser.numLikes = numLikes;
		self.numLikes = nil;
		self.user = theUser;
	} else if ([elementName isEqual:@"id"]) {
		self.userId = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"username"]) {
		self.username = mutableString;
	} else if ([elementName isEqual:@"avatar-url"]) {
		self.avatarUrl = mutableString;
	} else if ([elementName isEqual:@"full-name"]) {
		self.fullName = mutableString;
	} else if ([elementName isEqual:@"location"]) {
		self.location = mutableString;
	} else if ([elementName isEqual:@"web"]) {
		self.web = mutableString;
	} else if ([elementName isEqual:@"bio"]) {
		self.bio = mutableString;
	} else if ([elementName isEqual:@"authentication-token"]) {
		self.authenticationToken = mutableString;
	} else if ([elementName isEqual:@"blogcasts"]) {
		if (inStats)
			self.numBlogcasts = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"subscriptions"]) {
		if (inStats)
			self.numSubscriptions = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"subscribers"]) {
		if (inStats)
			self.numSubscribers = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"posts"]) {
		if (inStats)
			self.numPosts = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"comments"]) {
		if (inStats)
			self.numComments = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"likes"]) {
		if (inStats)
			self.numLikes = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"subscription"]) {
		if (subscription) {
			if ([mutableString isEqual:@"true"])
				subscription.isSubscribed = [NSNumber numberWithBool:YES];
			else
				subscription.isSubscribed = [NSNumber numberWithBool:NO];
		}
	} else if ([elementName isEqual:@"stats"]) {
		inStats = NO;
	} 
	//MVR - release string here to handle potential memory leak
    self.mutableString = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!mutableString) {
		NSMutableString *theMutableString;
		
		theMutableString = [[NSMutableString alloc] init];
		self.mutableString = theMutableString;
		[theMutableString release];
	}
	[mutableString appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Error parsing user: %@", [parseError localizedDescription]);
}

@end
