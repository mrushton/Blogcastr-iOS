//
//  SettingsParser.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/21/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "SettingsParser.h"


@implementation SettingsParser

@synthesize data;
@synthesize user;
@synthesize mutableString;
@synthesize bio;
@synthesize fullName;
@synthesize location;
@synthesize web;
@synthesize avatarUrl;

#pragma mark -
#pragma mark Class methods

- (SettingsParser *)initWithData:(NSData *)theData {
	self.data = theData;
	
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
#pragma mark NSXMLParserDelegate methods

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	//MVR  - save settings to user
	user.bio = self.bio;
	user.fullName = self.fullName;
	user.location = self.location;
	user.web = self.web;
	user.avatarUrl = self.avatarUrl;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	self.mutableString = nil;
	self.bio = nil;
	self.fullName = nil;
	self.location = nil;
	self.web = nil;
	self.avatarUrl = nil;
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	//MVR - need to reset string here to handle white space
    self.mutableString = nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqual:@"bio"])
		self.bio = mutableString;
	else if ([elementName isEqual:@"full-name"])
		self.fullName = mutableString;
	else if ([elementName isEqual:@"location"])
		self.location = mutableString;
	else if ([elementName isEqual:@"web"])
		self.web = mutableString;
	else if ([elementName isEqual:@"avatar-url"])
		self.avatarUrl = mutableString;
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
	NSLog(@"Error parsing settings: %@", [parseError localizedDescription]);
}

@end
