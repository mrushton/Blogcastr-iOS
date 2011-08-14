//
//  CommentsParser.m
//  Blogcastr
//
//  Created by Matthew Rushton on 6/4/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CommentsParser.h"
#import "Post.h"
#import "User.h"
#import "Comment.h"

@implementation CommentsParser

@synthesize data;
@synthesize managedObjectContext;
@synthesize blogcast;
@synthesize mutableString;
@synthesize commentId;
@synthesize commentText;
@synthesize userId;
@synthesize userType;
@synthesize userUsername;
@synthesize userUrl;
@synthesize userAvatarUrl;
@synthesize commentCreatedAt;
@synthesize comments;

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
	[blogcast release];
    [mutableString release];
	[commentId release];
	[commentText release];
	[userId release];
	[userType release];
	[userUsername release];
	[userUrl release];
	[userAvatarUrl release];
	[commentCreatedAt release];
	[comments release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	self.mutableString = nil;
	self.commentId = nil;
	self.commentText = nil;
	self.userId = nil;
	self.userType = nil;
	self.userUsername = nil;
	self.userUrl = nil;
	self.userAvatarUrl = nil;
	self.commentCreatedAt = nil;
	inUser = NO;
	self.comments = [NSMutableArray array];
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqual:@"user"])
		inUser = YES;
	//MVR - need to reset string here to handle white space
    self.mutableString = nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqual:@"comment"]) {
		NSFetchRequest *request;
		NSEntityDescription *entity;
		NSPredicate *predicate;
		NSArray *array;
		Comment *comment;
		User *user;
		NSError *error;
		
		//MVR - find comment if it exists
		request = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];	
		predicate = [NSPredicate predicateWithFormat:@"id = %d", [commentId intValue]];
		[request setPredicate:predicate];
		//MVR - execute the fetch
		array = [managedObjectContext executeFetchRequest:request error:&error];
		[request release];
		//MVR - create post if it doesn't exist
		if ([array count] > 0) {
			comment = [array objectAtIndex:0];
		} else {
			comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:managedObjectContext];
			comment.id = commentId;
			comment.blogcast = blogcast;
			comment.text = commentText;
			comment.createdAt = commentCreatedAt;			
			//MVR - find comment user if they exist
			request = [[NSFetchRequest alloc] init];
			entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
			[request setEntity:entity];
			predicate = [NSPredicate predicateWithFormat:@"id = %d", [userId intValue]];
			[request setPredicate:predicate];
			//MVR - execute the fetch
			array = [managedObjectContext executeFetchRequest:request error:&error];
			//MVR - create post user if they don't exist
			if ([array count] > 0) {
				user = [array objectAtIndex:0];
			} else {
				user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
				user.id = userId;
				user.type = userType;
				if ([userType isEqual:@"BlogcastrUser"]) {
					user.username = userUsername;
				} else if ([userType isEqual:@"FacebookUser"]) {
					user.facebookFullName = userUsername;
					user.facebookLink = userUrl;
				} else if ([userType isEqual:@"TwitterUser"]) {
					user.twitterUsername = userUsername;
				}
				user.avatarUrl = userAvatarUrl;
			}
			comment.user = user;			
		}
		self.userId = nil;
		self.userType = nil;
		self.userUsername = nil;
		self.userUrl = nil;
		self.userAvatarUrl = nil;
		self.commentId = nil;
		self.commentText = nil;
		self.commentCreatedAt = nil;
		//MVR - store post for later processing
		[comments addObject:comment];
	} else if ([elementName isEqual:@"id"]) {
		if (inUser)
			self.userId = [NSNumber numberWithInteger:[mutableString integerValue]];
		else
			self.commentId = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"type"]){
		self.userType = mutableString;
	} else if ([elementName isEqual:@"username"]) {
		self.userUsername = mutableString;
	} else if ([elementName isEqual:@"url"]) {
		self.userUrl = mutableString;
	} else if ([elementName isEqual:@"avatar-url"]) {
		self.userAvatarUrl = mutableString;
	} else if ([elementName isEqual:@"text"]) {
		self.commentText = mutableString;
	} else if ([elementName isEqual:@"created-at"]) {
		self.commentCreatedAt = [self parseTimestamp:mutableString];
	} else if ([elementName isEqual:@"user"]) {
		inUser = NO;
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
	NSLog(@"Error parsing comments: %@", [parseError localizedDescription]);
}

#pragma mark -
#pragma mark Helpers

- (NSDate *)parseTimestamp: (NSString *)timestamp {
	NSString *string;
	NSDate *date;
	
	//MVR - parse timestamp based on whether it is in UTC format or not
	if ([timestamp length] == 20)
		string = [NSString stringWithFormat:@"%@ %@ +0000", [timestamp substringToIndex:10], [timestamp substringWithRange:NSMakeRange(11, 8)]];
	else
		string = [NSString stringWithFormat:@"%@ %@ %@%@", [timestamp substringToIndex:10], [timestamp substringWithRange:NSMakeRange(11, 8)], [timestamp substringWithRange:NSMakeRange(19, 3)], [timestamp substringWithRange:NSMakeRange(23, 2)]];
	date = [[[NSDate alloc] initWithString:string] autorelease];
	
	return date;
}

@end
