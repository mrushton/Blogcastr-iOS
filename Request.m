//
//  Request.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/10/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "Request.h"


@implementation Request

@synthesize managedObjectContext;
@synthesize mutableData;
@synthesize delegate;

- (Request *)initWithDelegate:(id<RequestServerProtocol>)theDelegate {
	NSMutableData *theMutableData;
	

	self.delegate = theDelegate;
	theMutableData = [[NSMutableData alloc] initWithCapacity:1024];
	self.mutableData = theMutableData;
	NSLog(@"MVR - init mutable data 0x%x",self.mutableData);

	[theMutableData release];
	
	return self;
}

- (BOOL)parse {
	return FALSE;
}

- (void)finish {
}

- (void)dealloc {
	[managedObjectContext release];
	[mutableData release];
	[super dealloc];
}

@end
