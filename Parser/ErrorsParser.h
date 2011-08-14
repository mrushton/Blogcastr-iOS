//
//  ErrorsParser.h
//  Blogcastr
//
//  Created by Matthew Rushton on 8/14/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ErrorsParser : NSObject <NSXMLParserDelegate> {
	NSData *data;
	//MVR - xml parser
    NSMutableString *mutableString;
	NSMutableArray *errors;
}

@property (nonatomic, retain) NSData *data;
//AS DESIGNED: copy always returns an immutable string
@property (nonatomic, retain) NSMutableString *mutableString;
@property (nonatomic, retain) NSMutableArray *errors;

- (BOOL)parse;

@end
