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


@implementation BlogcastsParser

@synthesize data;
@synthesize managedObjectContext;
@synthesize mutableString;
@synthesize blogcastId;
@synthesize blogcastTitle;
@synthesize blogcastDescription;
@synthesize blogcastStartingAt;
@synthesize blogcastUpdatedAt;
@synthesize blogcasts;

#pragma mark -
#pragma mark Methods

- (BlogcastsParser *)initWithData:(NSData *)theData managedObjectContext:(NSManagedObjectContext *)theManagedObjectContext {
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
	[blogcastId release];
	[blogcastTitle release];
	[blogcastDescription release];
	[blogcastStartingAt release];
	[blogcastUpdatedAt release];
	[blogcasts release];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	self.mutableString = nil;
	self.blogcastId = nil;
	self.blogcastTitle = nil;
	self.blogcastDescription = nil;
	self.blogcastStartingAt = nil;
	self.blogcastUpdatedAt = nil;
	inTag = FALSE;
	self.blogcasts = [NSMutableArray array];
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqual:@"tag"]) {
		inTag = TRUE;
	}
	//MVR - need to reset string here to handle white space
    self.mutableString = nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqual:@"blogcast"]) {
		NSFetchRequest *request;
		NSEntityDescription *entity;
		NSPredicate *predicate;
		NSArray *array;
		Blogcast *blogcast;
		NSError *error;
		
		//MVR - find blogcast if it exists
		request = [[NSFetchRequest alloc] init];
		entity = [NSEntityDescription entityForName:@"Blogcast" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];	
		predicate = [NSPredicate predicateWithFormat:@"id = %d", blogcastId];
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
		blogcast.title = blogcastTitle;
		self.blogcastTitle = nil;
		blogcast.theDescription = blogcastDescription;
		self.blogcastDescription = nil;
		blogcast.startingAt = blogcastStartingAt;
		self.blogcastStartingAt = nil;
		blogcast.updatedAt = blogcastUpdatedAt;
		self.blogcastUpdatedAt = nil;
		//MVR - save in case we need to delete them on error
		[blogcasts addObject:blogcast];
	} else if ([elementName isEqual:@"id"]) {
		if (inTag) {
		} else {
			NSNumberFormatter *formatter;
			
			formatter = [[NSNumberFormatter alloc] init];
			self.blogcastId = [formatter numberFromString:mutableString];
			[formatter release];
		}
	} else if ([elementName isEqual:@"title"]){
		self.blogcastTitle = mutableString;
	} else if ([elementName isEqual:@"description"]) {
		self.blogcastDescription = mutableString;
	} else if ([elementName isEqual:@"starting-at"]) {
		NSString *string;
		NSDate *date;
		
		//MVR - convert date string
		string = [NSString stringWithFormat:@"%@ %@ %@%@", [mutableString substringToIndex:10], [mutableString substringWithRange:NSMakeRange(11, 8)], [mutableString substringWithRange:NSMakeRange(19, 3)], [mutableString substringWithRange:NSMakeRange(23, 2)]];
		date = [[NSDate alloc] initWithString:string];
		self.blogcastStartingAt = date;
		[date release];
	} else if ([elementName isEqual:@"updated-at"]) {
		NSString *string;
		NSDate *date;
		
		//MVR - convert date string
		string = [NSString stringWithFormat:@"%@ %@ %@%@", [mutableString substringToIndex:10], [mutableString substringWithRange:NSMakeRange(11, 8)], [mutableString substringWithRange:NSMakeRange(19, 3)], [mutableString substringWithRange:NSMakeRange(23, 2)]];
		date = [[NSDate alloc] initWithString:string];
		self.blogcastUpdatedAt = date;
		[date release];
	} else if ([elementName isEqual:@"tag"]) {
		inTag = FALSE;
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
	NSLog(@"Error parsing blogcasts: %@", [parseError localizedDescription]);
}

@end
