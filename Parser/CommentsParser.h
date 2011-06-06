//
//  CommentsParser.h
//  Blogcastr
//
//  Created by Matthew Rushton on 6/4/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CommentsParser : NSObject <NSXMLParserDelegate> {
	NSData *data;
	NSManagedObjectContext *managedObjectContext;
	//MVR - xml parser
    NSMutableString *mutableString;
	NSNumber *commentId;
	NSString *commentText;
	NSNumber *userId;
	NSString *userType;
	NSString *userUsername;
	NSString *userUrl;
	NSString *userAvatarUrl;
	NSDate *commentCreatedAt;
	BOOL inUser;
	NSMutableArray *comments;
}

@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSString *mutableString;
@property (nonatomic, retain) NSNumber *commentId;
@property (nonatomic, retain) NSString *commentText;
@property (nonatomic, retain) NSNumber *userId;
@property (nonatomic, retain) NSString *userType;
@property (nonatomic, retain) NSString *userUsername;
@property (nonatomic, retain) NSString *userUrl;
@property (nonatomic, retain) NSString *userAvatarUrl;
@property (nonatomic, retain) NSDate *commentCreatedAt;
@property (nonatomic, retain) NSMutableArray *comments;

- (CommentsParser *)initWithData:(NSData *)theData managedObjectContext:(NSManagedObjectContext *)theManagedObjectContext;
- (BOOL)parse;

@end
