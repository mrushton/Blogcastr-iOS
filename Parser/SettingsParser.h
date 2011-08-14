//
//  SettingsParser.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/21/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"


@interface SettingsParser : NSObject <NSXMLParserDelegate> {
	NSData *data;
	User *user;
	//MVR - xml parser
    NSMutableString *mutableString;
	NSString *bio;
	NSString *fullName;
	NSString *location;
	NSString *web;
	NSString *avatarUrl;
}

@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) User *user;
//AS DESIGNED: copy always returns an immutable string
@property (nonatomic, retain) NSMutableString *mutableString;
@property (nonatomic, retain) NSString *bio;
@property (nonatomic, retain) NSString *fullName;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *web;
@property (nonatomic, retain) NSString *avatarUrl;

- (SettingsParser *)initWithData:(NSData *)theData;
- (BOOL)parse;

@end