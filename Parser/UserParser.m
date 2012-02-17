//
//  UserParser.m
//  Blogcastr
//
//  Created by Matthew Rushton on 7/17/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "UserParser.h"
#import "User.h"
#import "NSDate+Format.h"


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
@synthesize facebookId;
@synthesize facebookFullName;
@synthesize facebookLink;
@synthesize facebookAccessToken;
@synthesize facebookExpiresAt;
@synthesize hasFacebookPublishStream;
@synthesize twitterUsername;
@synthesize twitterAccessToken;
@synthesize twitterTokenSecret;
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
    [facebookId release];
    [facebookFullName release];
    [facebookLink release];
    [facebookAccessToken release];
    [facebookExpiresAt release];
    [hasFacebookPublishStream release];
    [twitterUsername release];
    [twitterAccessToken release];
    [twitterTokenSecret release];
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
    self.facebookId = nil;
    self.facebookFullName = nil;
    self.facebookLink = nil;
    self.facebookAccessToken = nil;
    self.hasFacebookPublishStream = nil;
    self.twitterUsername = nil;
    self.twitterAccessToken = nil;
    self.facebookExpiresAt = nil;
    self.twitterTokenSecret = nil;
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
		theUser.authenticationToken = authenticationToken;
		self.authenticationToken = nil;
        theUser.facebookId = facebookId;
        self.facebookId = nil;
        theUser.facebookFullName = facebookFullName;
        self.facebookFullName = nil;
        theUser.facebookLink = facebookLink;
        self.facebookLink = nil;
        theUser.facebookAccessToken = facebookAccessToken;
        self.facebookAccessToken = nil;
        theUser.facebookExpiresAt = facebookExpiresAt;
        self.facebookExpiresAt = nil;
        theUser.hasFacebookPublishStream = hasFacebookPublishStream;
        self.hasFacebookPublishStream = nil;
		theUser.twitterUsername = twitterUsername;
		self.twitterUsername = nil;
		theUser.twitterAccessToken = twitterAccessToken;
		self.twitterAccessToken = nil;
		theUser.twitterTokenSecret = twitterTokenSecret;
		self.twitterTokenSecret = nil;
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
    } else if ([elementName isEqual:@"facebook-id"]) {
		self.facebookId = [NSNumber numberWithInteger:[mutableString integerValue]];
    } else if ([elementName isEqual:@"facebook-full-name"]) {
		self.facebookFullName = mutableString;
    } else if ([elementName isEqual:@"facebook-link"]) {
		self.facebookLink = mutableString;
    } else if ([elementName isEqual:@"facebook-access-token"]) {
		self.facebookAccessToken = mutableString;
    } else if ([elementName isEqual:@"facebook-expires-at"]) {
		self.facebookExpiresAt = [NSDate dateWithIso8601:mutableString];
    } else if ([elementName isEqual:@"has-facebook-publish-stream"]) {
        if ([mutableString isEqual:@"true"])
            self.hasFacebookPublishStream = [NSNumber numberWithBool:YES];
        else
            self.hasFacebookPublishStream = [NSNumber numberWithBool:NO];
    }  else if ([elementName isEqual:@"twitter-username"]) {
		self.twitterUsername = mutableString;
    } else if ([elementName isEqual:@"twitter-access-token"]) {
		self.twitterAccessToken = mutableString;
    } else if ([elementName isEqual:@"twitter-token-secret"]) {
		self.twitterTokenSecret = mutableString;
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
		NSMutableString *theString;
		
		theString = [[NSMutableString alloc] init];
		self.mutableString = theString;
		[theString release];
	}
	[mutableString appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Error parsing user: %@", [parseError localizedDescription]);
}

@end
