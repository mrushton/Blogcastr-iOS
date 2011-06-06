//
//  Timer.m
//  Blogcastr
//
//  Created by Matthew Rushton on 5/28/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "Timer.h"


@implementation Timer

@synthesize timer;

- (Timer *)initWithTimeInterval:(NSTimeInterval)seconds delegate:(id)theDelegate; {
	self = [super init];
	if (self) {
		self.timer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(timerExpired) userInfo:nil repeats:YES];
		//MVR - this class is designed to avoid retain cycles 
		delegate = theDelegate;
	}

	return self;
}

- (void)invalidate {
	[timer invalidate];
	self.timer = nil;
}

#pragma mark -
#pragma mark Actions

- (void)timerExpired {
	//MVR - pass to the delegate
	[delegate timerExpired:self]; 
}


@end
