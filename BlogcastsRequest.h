//
//  BlogcastsRequest.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/10/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"


@interface BlogcastsRequest : Request <NSXMLParserDelegate> {
	//MVR - xml parser
    NSMutableString *xmlParserMutableString;
	NSNumber *xmlParserBlogcastId;
	NSString *xmlParserBlogcastTitle;
	NSString *xmlParserBlogcastDescription;
	NSDate *xmlParserBlogcastStartingAt;
	NSDate *xmlParserBlogcastUpdatedAt;
	BOOL xmlParserInTag;
	NSMutableArray *xmlParserBlogcasts;
}

@property (nonatomic, retain) NSString *xmlParserMutableString;
@property (nonatomic, retain) NSNumber *xmlParserBlogcastId;
@property (nonatomic, retain) NSString *xmlParserBlogcastTitle;
@property (nonatomic, retain) NSString *xmlParserBlogcastDescription;
@property (nonatomic, retain) NSDate *xmlParserBlogcastStartingAt;
@property (nonatomic, retain) NSDate *xmlParserBlogcastUpdatedAt;
@property (nonatomic, retain) NSMutableArray *xmlParserBlogcasts;

@end
