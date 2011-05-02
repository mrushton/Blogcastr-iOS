//
//  BlogcastsRequest.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/10/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "BlogcastsRequest.h"
#import "Blogcast.h"


@implementation BlogcastsRequest

@synthesize xmlParserMutableString;
@synthesize xmlParserBlogcastId;
@synthesize xmlParserBlogcastTitle;
@synthesize xmlParserBlogcastDescription;
@synthesize xmlParserBlogcastStartingAt;
@synthesize xmlParserBlogcastUpdatedAt;
@synthesize xmlParserBlogcasts;

- (BOOL)parse {
	NSXMLParser *parser;
	
    //MVR - parse xml
	parser = [[NSXMLParser alloc] initWithData:mutableData];
	[parser setDelegate:self];
	if ([parser parse]) {
		[parser release];
		return TRUE;
	} else {
		[parser release];
		return FALSE;	
	}
}

- (void)finish {
	if ([delegate respondsToSelector:@selector(requestFinishedWithBlogcasts:)])
		[delegate requestFinishedWithBlogcasts:xmlParserBlogcasts];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	self.xmlParserMutableString = nil;
	self.xmlParserBlogcastId = nil;
	self.xmlParserBlogcastTitle = nil;
	self.xmlParserBlogcastDescription = nil;
	self.xmlParserBlogcastStartingAt = nil;
	self.xmlParserBlogcastUpdatedAt = nil;
	xmlParserInTag = FALSE;
	self.xmlParserBlogcasts = [NSMutableArray array];
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqual:@"tag"]) {
		xmlParserInTag = TRUE;
	}
	//MVR - need to reset string here to handle white space
    self.xmlParserMutableString = nil;
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
		predicate = [NSPredicate predicateWithFormat:@"id = %d", xmlParserBlogcastId];
		[request setPredicate:predicate];
		//MVR - execute the fetch
		array = [managedObjectContext executeFetchRequest:request error:&error];
		//MVR - create blogcast if it doesn't exist
		if ([array count] > 0)
			blogcast = [array objectAtIndex:0];
		else
			blogcast = [NSEntityDescription insertNewObjectForEntityForName:@"Blogcast" inManagedObjectContext:managedObjectContext];
		[request release];
		blogcast.id = xmlParserBlogcastId;
		[xmlParserBlogcastId release];
		xmlParserBlogcastId = nil;
		blogcast.title = xmlParserBlogcastTitle;
		[xmlParserBlogcastTitle release];
		xmlParserBlogcastTitle = nil;
		blogcast.theDescription = xmlParserBlogcastDescription;
		[xmlParserBlogcastDescription release];
		xmlParserBlogcastDescription = nil;
		blogcast.startingAt = xmlParserBlogcastStartingAt;
		[xmlParserBlogcastStartingAt release];
		xmlParserBlogcastStartingAt = nil;
		blogcast.updatedAt = xmlParserBlogcastUpdatedAt;
		[xmlParserBlogcastUpdatedAt release];
		xmlParserBlogcastUpdatedAt = nil;
		//MVR - save in case we need to delete them on error
		[xmlParserBlogcasts addObject:blogcast];
	} else if ([elementName isEqual:@"id"]) {
		if (xmlParserInTag) {
		} else {
			NSNumberFormatter *formatter;
			
			formatter = [[NSNumberFormatter alloc] init];
			self.xmlParserBlogcastId = [formatter numberFromString:xmlParserMutableString];
			[formatter release];
		}
	} else if ([elementName isEqual:@"title"]){
		self.xmlParserBlogcastTitle = xmlParserMutableString;
	} else if ([elementName isEqual:@"description"]) {
		self.xmlParserBlogcastDescription = xmlParserMutableString;
	} else if ([elementName isEqual:@"starting-at"]) {
		NSString *string;
		NSDate *date;
		
		//MVR - convert date string
		string = [NSString stringWithFormat:@"%@ %@ %@%@", [xmlParserMutableString substringToIndex:10], [xmlParserMutableString substringWithRange:NSMakeRange(11, 8)], [xmlParserMutableString substringWithRange:NSMakeRange(19, 3)], [xmlParserMutableString substringWithRange:NSMakeRange(23, 2)]];
		date = [[NSDate alloc] initWithString:string];
		self.xmlParserBlogcastStartingAt = date;
		[date release];
	} else if ([elementName isEqual:@"updated-at"]) {
		NSString *string;
		NSDate *date;
		
		//MVR - convert date string
		string = [NSString stringWithFormat:@"%@ %@ %@%@", [xmlParserMutableString substringToIndex:10], [xmlParserMutableString substringWithRange:NSMakeRange(11, 8)], [xmlParserMutableString substringWithRange:NSMakeRange(19, 3)], [xmlParserMutableString substringWithRange:NSMakeRange(23, 2)]];
		date = [[NSDate alloc] initWithString:string];
		self.xmlParserBlogcastUpdatedAt = date;
		[date release];
	} else if ([elementName isEqual:@"tag"]) {
		xmlParserInTag = FALSE;
	}
	//MVR - release string here to handle potential memory leak
    self.xmlParserMutableString = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!xmlParserMutableString) {
		NSString *string;
		
		string = [[NSMutableString alloc] init];
		self.xmlParserMutableString = string;
		[string release];
	}
	[xmlParserMutableString appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Error parsing XML: %@", [parseError localizedDescription]);
}

@end
