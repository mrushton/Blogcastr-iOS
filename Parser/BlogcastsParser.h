//
//  BlogcastsParser.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/12/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BlogcastsParser : NSObject <NSXMLParserDelegate> {
	NSData *data;
	NSManagedObjectContext *managedObjectContext;
	//MVR - xml parser
    NSMutableString *mutableString;
	NSNumber *blogcastId;
	NSString *blogcastTitle;
	NSString *blogcastDescription;
	NSDate *blogcastStartingAt;
	NSDate *blogcastUpdatedAt;
	BOOL inTag;
	NSMutableArray *blogcasts;
}

@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSString *mutableString;
@property (nonatomic, retain) NSNumber *blogcastId;
@property (nonatomic, retain) NSString *blogcastTitle;
@property (nonatomic, retain) NSString *blogcastDescription;
@property (nonatomic, retain) NSDate *blogcastStartingAt;
@property (nonatomic, retain) NSDate *blogcastUpdatedAt;
@property (nonatomic, retain) NSMutableArray *blogcasts;

- (BlogcastsParser *)initWithData:(NSData *)theData managedObjectContext:(NSManagedObjectContext *)theManagedObjectContext;
- (BOOL)parse;

@end
