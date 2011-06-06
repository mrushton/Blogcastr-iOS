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

@implementation PostsParser

@synthesize data;
@synthesize managedObjectContext;
@synthesize mutableString;
@synthesize postId;
@synthesize postType;
@synthesize postUserId;
@synthesize postUserUsername;
@synthesize postUserAvatarUrl;
@synthesize postText;
@synthesize postImageUrl;
@synthesize postImageWidth;
@synthesize postImageHeight;
@synthesize commentId;
@synthesize commentUserId;
@synthesize commentUserType;
@synthesize commentUserUsername;
@synthesize commentUserUrl;
@synthesize commentUserAvatarUrl;
@synthesize commentCreatedAt;
@synthesize postCreatedAt;
@synthesize posts;

#pragma mark -
#pragma mark Methods

- (PostsParser *)initWithData:(NSData *)theData managedObjectContext:(NSManagedObjectContext *)theManagedObjectContext {
	self.data = theData;
	self.managedObjectContext = theManagedObjectContext;
	
	return self;
}

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
	[postId release];
	[postType release];
	[postUserId release];
	[postUserUsername release];
	[postUserAvatarUrl release];
	[postText release];
	[postImageUrl release];
	[postImageWidth release];
	[postImageHeight release];
	[commentId release];
	[commentUserId release];
	[commentUserType release];
	[commentUserUsername release];
	[commentUserUrl release];
	[commentUserAvatarUrl release];
	[commentCreatedAt release];
	[postCreatedAt release];
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
	self.postUserId = nil;
	self.postUserUsername = nil;
	self.postUserAvatarUrl = nil;
	self.postText = nil;
	self.postImageUrl = nil;
	self.postImageWidth = nil;
	self.postImageHeight = nil;
	self.commentId = nil;
	self.commentUserId = nil;
	self.commentUserType = nil;
	self.commentUserUsername = nil;
	self.commentUserUrl = nil;
	self.commentUserAvatarUrl = nil;
	self.commentCreatedAt = nil;
	self.postCreatedAt = nil;
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
	if ([elementName isEqual:@"post"]) {
		NSFetchRequest *request;
		NSEntityDescription *entity;
		NSPredicate *predicate;
		NSArray *array;
		Post *post;
		User *user;
		NSError *error;
		
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
		post.type = postType;
		self.postType = nil;
		//MVR - find post user if they exist
		request = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];
		predicate = [NSPredicate predicateWithFormat:@"id = %d", [postUserId intValue]];
		[request setPredicate:predicate];
		//MVR - execute the fetch
		array = [managedObjectContext executeFetchRequest:request error:&error];
		//MVR - create post user if they don't exist
		if ([array count] > 0)
			user = [array objectAtIndex:0];
		else
			user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
		user.id = postUserId;
		self.postUserId = nil;
		user.username = postUserUsername;
		self.postUserUsername = nil;
		user.avatarUrl = postUserAvatarUrl;
		self.postUserAvatarUrl = nil;
		user.type = @"BlogcastrUser";
		post.user = user;
		if ([post.type isEqual:@"TextPost"]) {
			post.text = postText;
			self.postText = nil;
		} else if ([post.type isEqual:@"ImagePost"]) {
			if (postText) {
				post.text = postText;
				self.postText = nil;
			}
			post.imageUrl = postImageUrl;
			self.postImageUrl = nil;
			post.imageWidth = postImageWidth;
			self.postImageWidth = nil;
			post.imageHeight = postImageHeight;
			self.postImageHeight = nil;
		} else if ([post.type isEqual:@"CommentPost"]) {
			Comment *comment;
			
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
				comment = [array objectAtIndex:0];
			else
				comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:managedObjectContext];
			[request release];
			comment.id = commentId;
			self.commentId = nil;
			//AS DESIGNED: use the post equivalent variable
			comment.text = postText;
			self.postText = nil;
			//MVR - find comment user if they exist
			request = [[NSFetchRequest alloc] init];
			entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
			[request setEntity:entity];
			predicate = [NSPredicate predicateWithFormat:@"id = %d", [commentUserId intValue]];
			[request setPredicate:predicate];
			//MVR - execute the fetch
			array = [managedObjectContext executeFetchRequest:request error:&error];
			//MVR - create user if they don't exist
			if ([array count] > 0)
				user = [array objectAtIndex:0];
			else
				user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
			user.id = commentUserId;
			self.commentUserId = nil;
			user.type = commentUserType;
			self.commentUserType = nil;
			if ([user.type isEqual:@"BlogcastrUser"]) {
				user.username = commentUserUsername;
				self.commentUserUsername = nil;
			} else if ([user.type isEqual:@"FacebookUser"]) {
				user.facebookFullName = commentUserUsername;
				self.commentUserUsername = nil;
				user.facebookLink = commentUserUrl;
				self.commentUserUrl = nil;
			} else if ([user.type isEqual:@"TwitterUser"]) {
				user.twitterUsername = commentUserUsername;
				self.commentUserUsername = nil;
			}
			user.avatarUrl = commentUserAvatarUrl;
			self.commentUserAvatarUrl = nil;
			comment.createdAt = commentCreatedAt;
			self.commentCreatedAt = nil;
			comment.user = user;
			post.comment = comment;
		}
		post.createdAt = postCreatedAt;
		self.postCreatedAt = nil;
		//MVR - store post for later processing
		[posts addObject:post];
	} else if ([elementName isEqual:@"id"]) {
		NSNumberFormatter *formatter;
		
		formatter = [[NSNumberFormatter alloc] init];
		if (inComment) {
			if (inUser)
				self.commentUserId = [formatter numberFromString:mutableString];
			else
				self.commentId = [formatter numberFromString:mutableString];					
		}
		else {
			if (inUser)
				self.postUserId = [formatter numberFromString:mutableString];
			else
				self.postId = [formatter numberFromString:mutableString];
		}
		[formatter release];
	} else if ([elementName isEqual:@"type"]){
		if (inComment) {
			//AS DESIGNED: there is only one comment type
			self.commentUserType = mutableString;
		} else {
			//AS DESIGNED: to post the user must be a BlogastrUser
			if (!inUser)
				self.postType = mutableString;
		}
	} else if ([elementName isEqual:@"username"]) {
		if (inComment)		
			self.commentUserUsername = mutableString;
		else
			self.postUserUsername = mutableString;
	} else if ([elementName isEqual:@"url"]) {
		if (inComment)		
			self.commentUserUrl = mutableString;
	} else if ([elementName isEqual:@"avatar-url"]) {
		if (inComment)		
			self.commentUserAvatarUrl = mutableString;
		else
			self.postUserAvatarUrl = mutableString;
	} else if ([elementName isEqual:@"text"]) {
		//AS DESIGNED: use the post equivalent variable
		self.postText = mutableString;
	} else if ([elementName isEqual:@"image-url"]) {
		self.postImageUrl = mutableString;
	} else if ([elementName isEqual:@"image-width"]) {
		NSNumberFormatter *formatter;
		
		formatter = [[NSNumberFormatter alloc] init];
		self.postImageWidth = [formatter numberFromString:mutableString];
		[formatter release];
	} else if ([elementName isEqual:@"image-height"]) {
		NSNumberFormatter *formatter;
		
		formatter = [[NSNumberFormatter alloc] init];
		self.postImageHeight = [formatter numberFromString:mutableString];
		[formatter release];
	} else if ([elementName isEqual:@"created-at"]) {
		NSString *string;
		NSDate *date;
		
		//MVR - convert date string
		string = [NSString stringWithFormat:@"%@ %@ %@%@", [mutableString substringToIndex:10], [mutableString substringWithRange:NSMakeRange(11, 8)], [mutableString substringWithRange:NSMakeRange(19, 3)], [mutableString substringWithRange:NSMakeRange(23, 2)]];
		date = [[NSDate alloc] initWithString:string];
		if (inComment)
			self.commentCreatedAt = date;
		else
			self.postCreatedAt = date;
		[date release];
	} else if ([elementName isEqual:@"user"]) {
		inUser = FALSE;
	} else if ([elementName isEqual:@"comment"]) {
		inComment = FALSE;
	}
	//MVR - release string here to handle potential memory leak
    self.mutableString = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!mutableString) {
		NSString *string;
		
		string = [[NSMutableString alloc] init];
		self.mutableString = string;
		[string release];
	}
	[mutableString appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Error parsing posts: %@", [parseError localizedDescription]);
}

@end
