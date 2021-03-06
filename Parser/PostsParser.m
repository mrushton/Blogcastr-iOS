//
//  PostsParser.m
//  Blogcastr
//
//  Created by Matthew Rushton on 5/14/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "PostsParser.h"
#import "Post.h"
#import "User.h"
#import "Comment.h"
#import "NSDate+Format.h"

@implementation PostsParser

@synthesize data;
@synthesize managedObjectContext;
@synthesize blogcast;
@synthesize mutableString;
@synthesize postId;
@synthesize postType;
@synthesize postUser;
@synthesize commentUser;
@synthesize userId;
@synthesize userType;
@synthesize userUsername;
@synthesize userUrl;
@synthesize userAvatarUrl;
@synthesize text;
@synthesize postImageUrl;
@synthesize postImageWidth;
@synthesize postImageHeight;
@synthesize comment;
@synthesize commentId;
@synthesize commentCreatedAt;
@synthesize postCreatedAt;
@synthesize posts;
@synthesize url;
@synthesize shortUrl;

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
	[postId release];
	[postType release];
	[postUser release];
	[userId release];
	[userType release];
	[userUsername release];
	[userAvatarUrl release];
	[userUrl release];
	[text release];
	[postImageUrl release];
	[postImageWidth release];
	[postImageHeight release];
	[comment release];
	[commentId release];
	[commentUser release];
	[commentCreatedAt release];
	[postCreatedAt release];
    [url release];
    [shortUrl release];
	[posts release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	self.mutableString = nil;
	self.postId = nil;
	self.postType = nil;
	self.postUser = nil;
	self.userId = nil;
	self.userType = nil;
	self.userUsername = nil;
	self.userUrl = nil;
	self.userAvatarUrl = nil;
	self.text = nil;
	self.postImageUrl = nil;
	self.postImageWidth = nil;
	self.postImageHeight = nil;
	self.comment = nil;
	self.commentId = nil;
	self.commentUser = nil;
	self.commentCreatedAt = nil;
	self.postCreatedAt = nil;
    self.url = nil;
    self.shortUrl = nil;
	inUser = FALSE;
	inComment = FALSE;
	self.posts = [NSMutableArray array];
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqual:@"user"])
		inUser = TRUE;
	else if ([elementName isEqual:@"comment"])
		inComment = TRUE;
	//MVR - need to reset string here to handle white space
    self.mutableString = nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	NSFetchRequest *request;
	NSEntityDescription *entity;
	NSPredicate *predicate;
	NSArray *array;
	NSError *error;

	if ([elementName isEqual:@"post"]) {
		Post *post;
		
		//MVR - find post if it exists
		request = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];	
		predicate = [NSPredicate predicateWithFormat:@"id = %d", [postId intValue]];
		[request setPredicate:predicate];
		//MVR - execute the fetch
		array = [managedObjectContext executeFetchRequest:request error:&error];
		//MVR - create post if it doesn't exist
		if ([array count] > 0)
			post = [array objectAtIndex:0];
		else
			post = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:managedObjectContext];
		[request release];
		post.id = postId;
		self.postId = nil;
		post.blogcast = blogcast;
		post.type = postType;
		self.postType = nil;
		post.user = postUser;
		self.postUser = nil;
		if ([post.type isEqual:@"TextPost"]) {
			post.text = text;
			self.text = nil;
		} else if ([post.type isEqual:@"ImagePost"]) {
			if (text) {
				post.text = text;
				self.text = nil;
			}
			post.imageUrl = postImageUrl;
			self.postImageUrl = nil;
			post.imageWidth = postImageWidth;
			self.postImageWidth = nil;
			post.imageHeight = postImageHeight;
			self.postImageHeight = nil;
		} else if ([post.type isEqual:@"CommentPost"]) {
			post.comment = comment;
			self.comment = nil;
		}
		post.createdAt = postCreatedAt;
		self.postCreatedAt = nil;
        post.url = url;
        self.url = nil;
        post.shortUrl = shortUrl;
        self.shortUrl = nil;
		//MVR - store post for later processing
		[posts addObject:post];
	} else if ([elementName isEqual:@"id"]) {
		if (inUser)
			self.userId = [NSNumber numberWithInteger:[mutableString integerValue]];
		else if (inComment)
			self.commentId = [NSNumber numberWithInteger:[mutableString integerValue]];					
		else
			self.postId = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"type"]){
		if (inUser)
			self.userType = mutableString;
		else
			self.postType = mutableString;
	} else if ([elementName isEqual:@"username"]) {
		self.userUsername = mutableString;
	} else if ([elementName isEqual:@"url"]) {
        if (inUser)
            self.userUrl = mutableString;
        else
            self.url = mutableString;
	} else if ([elementName isEqual:@"avatar-url"]) {
		self.userAvatarUrl = mutableString;
	} else if ([elementName isEqual:@"text"]) {
		self.text = mutableString;
	} else if ([elementName isEqual:@"image-url"]) {
		self.postImageUrl = mutableString;
	} else if ([elementName isEqual:@"image-width"]) {
		self.postImageWidth = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"image-height"]) {
		self.postImageHeight = [NSNumber numberWithInteger:[mutableString integerValue]];
	} else if ([elementName isEqual:@"created-at"]) {
		NSDate *date;

		date = [NSDate dateWithIso8601:mutableString];
		if (inComment)
			self.commentCreatedAt = date;
		else
			self.postCreatedAt = date;
	} else if ([elementName isEqual:@"short-url"]) {
		self.shortUrl = mutableString;
	} else if ([elementName isEqual:@"user"]) {
		User *theUser;
		
		request = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];	
		predicate = [NSPredicate predicateWithFormat:@"id = %d", [userId intValue]];
		[request setPredicate:predicate];
		//MVR - execute the fetch
		array = [managedObjectContext executeFetchRequest:request error:&error];
		//MVR - create user if they don't exist
		if ([array count] > 0)
			theUser = [array objectAtIndex:0];
		else
			theUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
		[request release];
		theUser.id = userId;
		self.userId = nil;
		theUser.type = userType;
		if ([userType isEqual:@"BlogcastrUser"]) {
			theUser.username = userUsername;
		} else if ([userType isEqual:@"FacebookUser"]) {
			theUser.facebookFullName = userUsername;
			theUser.facebookLink = userUrl;
		} else if ([userType isEqual:@"TwitterUser"]) {
			theUser.twitterUsername = userUsername;
		}
		self.userType = nil;
		self.userUsername = nil;
		theUser.avatarUrl = userAvatarUrl;
		self.userAvatarUrl = nil;
		if (inComment)
			self.commentUser = theUser;
		else
			self.postUser = theUser;
		inUser = NO;
	} else if ([elementName isEqual:@"comment"]) {
		Comment *theComment;
		
		//MVR - find comment if it exists
		request = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];
		predicate = [NSPredicate predicateWithFormat:@"id = %d", [commentId intValue]];
		[request setPredicate:predicate];
		//MVR - execute the fetch
		array = [managedObjectContext executeFetchRequest:request error:&error];
		//MVR - create user if they don't exist
		if ([array count] > 0)
			theComment = [array objectAtIndex:0];
		else
			theComment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:managedObjectContext];
		[request release];
		theComment.id = commentId;
		self.commentId = nil;
		theComment.blogcast = blogcast;
		theComment.user = commentUser;
		self.commentUser = nil;
		theComment.text = text;
		self.text = nil;
		theComment.createdAt = commentCreatedAt;
		self.comment = theComment;
		inComment = NO;
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
	NSLog(@"Error parsing posts: %@", [parseError localizedDescription]);
}

@end
