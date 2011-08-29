//
//  Timer.h
//  Blogcastr
//
//  Created by Matthew Rushton on 5/28/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Timer;

@protocol TimerProtocol

- (void)timerExpired:(Timer *)timer;

@end

@interface Timer : NSObject {
	NSTimer *timer;
	id<TimerProtocol> delegate;
}

@property (nonatomic, retain) NSTimer *timer;

- (Timer *)initWithTimeInterval:(NSTimeInterval)seconds delegate:(id)theDelegate;
- (void)invalidate;

@end
