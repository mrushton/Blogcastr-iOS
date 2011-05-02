//
//  Request.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/10/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol RequestServerProtocol;

@interface Request : NSObject {
	NSManagedObjectContext *managedObjectContext;
	NSMutableData *mutableData;
	id<RequestServerProtocol> delegate;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableData *mutableData;
@property (nonatomic, assign) id<RequestServerProtocol> delegate;

- (Request *)initWithDelegate:(id<RequestServerProtocol>)theDelegate;
- (BOOL)parse;
- (void)finish;

@end