//
//  BlogcastsParser.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/12/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "BlogcastsParser.h"
#import "Blogcast.h"
#import "NSDate+Format.h"


@implementation BlogcastsParser

@synthesize data;
@synthesize managedObjectContext;
@synthesize mutableString;
@synthesize blogcastId;
@synthesize title;
@synthesize theDescription;
@synthesize user;
@synthesize userId;
@synthesize userUsername;
@synthesize userAvatarUrl;
@synthesize tags;
@synthesize imageUrl;
@synthesize imageWidth;
@synthesize imageHeight;
@synthesize numCurrentViewers;
@synthesize numPosts;
@synthesize numComments;
@synthesize numLikes;
@synthesize numViews;
@synthesize startingAt;
@synthesize blogcastUpdatedAt;
@synthesize url;
@synthesize shortUrl;
@synthesize blogcasts;

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
	[blogcastId release];
	[title release];
	[theDescription release];
	[user release];
	[userId release];
	[userUsername release];
	[userAvatarUrl release];
	[tags release];
	[imageUrl release];
	[imageWidth release];
	[imageHeight release];
	[numCurrentViewers release];
	[numPosts release];
	[numComments release];
	[numLikes release];
	[numViews release];
	[startingAt release];
	[blogcastUpdatedAt release];
    [url release];
    [shortUrl release];
	[blogcasts release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	self.mutableString = nil;
	self.blogcastId = nil;
	self.title = nil;
	self.theDescription = nil;
	self.user = nil;
	self.userId = nil;
	self.userUsername = nil;
	self.userAvatarUrl = nil;
	self.tags = nil;
	self.imageUrl = nil;
	self.imageWidth = nil;
	self.imageHeight = nil;
	self.numCurrentViewers = nil;
	self.numPosts = nil;
	self.numComments = nil;
	self.numLikes = nil;
	self.numViews = nil;
	self.startingAt = nil;
	self.blogcastUpdatedAt = nil;
    self.url = nil;
    self.shortUrl = nil;
	inUser = NO;
	inTags = NO;
	inStats = NO;
	self.blogcasts = [NSMutableArray array];
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqual:@"user"])
		inUser = YES;
	else if ([elementName isEqual:@"tags"])
		inTags = YES;
	else if ([elementName isEqual:@"stats"])
		inStats = YES;
	//MVR - need to reset string here to handle white space
    self.mutableString = nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	NSFetchRequest *request;
	NSEntityDescription *entity;
	NSPredicate *predicate;
	NSArray *array;
	NSError *error;
	
	if ([elementName isEqual:@"blogcast"]) {
		Blogcast *blogcast;
		
		//MVR - find blogcast if it exists
		request = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"Blogcast" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];	
		predicate = [NSPredicate predicateWithFormat:@"id = %d", [blogcastId integerValue]];
		[request setPredicate:predicate];
		//MVR - execute the fetch
		array = [managedObjectContext executeFetchRequest:request error:&error];
		//MVR - create blogcast if it doesn't exist
		if ([array count] > 0)
			blogcast = [array objectAtIndex:0];
		else
			blogcast = [NSEntityDescription insertNewObjectForEntityForName:@"Blogcast" inManagedObjectContext:managedObjectContext];
		[request release];
		blogcast.id = blogcastId;
		self.blogcastId = nil;
		blogcast.title = title;
		self.title = nil;
		blogcast.theDescription = theDescription;
		self.theDescription = nil;
		blogcast.user = user;
		self.user = nil;
		blogcast.tags = tags;
		self.tags = nil;
		blogcast.imageUrl = imageUrl;
		self.imageUrl = nil;
		blogcast.imageWidth = imageWidth;
		self.imageWidth = nil;
		blogcast.imageHeight = imageHeight;
		self.imageHeight = nil;
		blogcast.numCurrentViewers = numCurrentViewers;
		self.numCurrentViewers = nil;
		blogcast.numPosts = numPosts;
		self.numPosts = nil;
		blogcast.numComments = numComments;
		self.numComments = nil;
		blogcast.numLikes = numLikes;
		self.numLikes = nil;
		blogcast.numViews = numViews;
		self.numViews = nil;
		blogcast.startingAt = startingAt;
		self.startingAt = nil;
		blogcast.updatedAt = blogcastUpdatedAt;
		self.blogcastUpdatedAt = nil;
        blogcast.url = url;
        self.url = nil;
        blogcast.shortUrl = shortUrl;
        self.shortUrl = nil;
		//MVR - save for further processing
		[blogcasts addObject:blogcast];
	} else if ([elementName isEqual:@"id"]) {
		if (inUser)
			self.userId = [NSNumber numberWithInteger:[mutableString integerValue]];
		else
			self.blogcastId = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"title"]){
		self.title = mutableString;
	} else if ([elementName isEqual:@"description"]) {
		self.theDescription = mutableString;
	} else if ([elementName isEqual:@"user"]) {
		User *theUser;
		
		//MVR - find blogcast if it exists
		request = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];	
		predicate = [NSPredicate predicateWithFormat:@"id = %d", [userId intValue]];
		[request setPredicate:predicate];
		//MVR - execute the fetch
		array = [managedObjectContext executeFetchRequest:request error:&error];
		//MVR - create blogcast if it doesn't exist
		if ([array count] > 0)
			theUser = [array objectAtIndex:0];
		else
			theUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
		[request release];
		theUser.id = userId;
		self.userId = nil;
		theUser.type = @"BlogcastrUser";
		theUser.username = userUsername;
		self.userUsername = nil;
		theUser.avatarUrl = userAvatarUrl;
		self.userAvatarUrl = nil;
		self.user = theUser;
		inUser = NO;
	} else if ([elementName isEqual:@"username"]) {
		if (inUser)
			self.userUsername = mutableString;	
	} else if ([elementName isEqual:@"avatar-url"]) {
		if (inUser)
			self.userAvatarUrl = mutableString;		
	} else if ([elementName isEqual:@"tags"]) {
		inTags = NO;
	} else if ([elementName isEqual:@"tag"]) {
		if (inTags) {
			if (tags)
				self.tags = [tags stringByAppendingFormat:@", %@", mutableString];
			else
				self.tags = mutableString;
		}
	} else if ([elementName isEqual:@"image-url"]) {
		self.imageUrl = mutableString;
	} else if ([elementName isEqual:@"image-width"]) {
		self.imageWidth = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"image-height"]) {
		self.imageHeight = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"stats"]) {
		inStats = NO;
	} else if ([elementName isEqual:@"current-viewers"]) {
		if (inStats)
			self.numCurrentViewers = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"posts"]) {
		if (inStats)
			self.numPosts = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"comments"]) {
		if (inStats)
			self.numComments = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"likes"]) {
		if (inStats)
			self.numLikes = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"views"]) {
		if (inStats)
			self.numViews = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"starting-at"]) {
		self.startingAt = [NSDate dateWithIso8601:mutableString];
	} else if ([elementName isEqual:@"updated-at"]) {
		self.blogcastUpdatedAt = [NSDate dateWithIso8601:mutableString];
	} else if ([elementName isEqual:@"url"]) {
        self.url = mutableString;
    } else if ([elementName isEqual:@"short-url"]) {
        self.shortUrl = mutableString;
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
	NSLog(@"Error parsing blogcasts: %@", [parseError localizedDescription]);
}

@end
