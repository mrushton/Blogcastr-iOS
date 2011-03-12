//
//  BlogcastrServer.m
//  Blogcastr
//
//  Created by Matthew Rushton on 3/1/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "BlogcastrServer.h"
#import "Session.h"


static BlogcastrServer *sharedBlogcastrServer = nil;

@implementation BlogcastrServer

@synthesize managedObjectContext;

+ (BlogcastrServer*)sharedBlogcastrServer {
	if (sharedBlogcastrServer == nil) {
		sharedBlogcastrServer = [[super allocWithZone:NULL] init];
	}

	return sharedBlogcastrServer;
}

+ (id)allocWithZone:(NSZone*)zone {
	return [[self sharedBlogcastrServer] retain];
}

- (id)copyWithZone:(NSZone*)zone {
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;
}

- (void)release {
	return;  
}

- (id)autorelease {
	return self;  
}

@end
