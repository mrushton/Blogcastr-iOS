//
//  NSDate+Timestamp.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/7/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "NSDate+Timestamp.h"


@implementation NSDate (Timestamp)

- (NSString *)stringInWords {
	NSTimeInterval timeInterval;
	NSInteger days;
	
	timeInterval = [self timeIntervalSinceNow];
	if (timeInterval < 0) {
		days = -timeInterval / (24 * 60 * 60);
		if (days > 0) {
			if (days == 1)
				return @"1 day ago";
			else
				return [NSString stringWithFormat:@"%d days ago", days];
		} else {
			NSInteger hours;
			
			hours = -timeInterval / (60 * 60);
			if (hours > 0) {
				if (hours == 1)
					return @"1 hour ago";
				else
					return [NSString stringWithFormat:@"%d hours ago", hours];
			} else {
				NSInteger minutes;
				
				minutes = -timeInterval / 60;
				if (minutes > 0) {
					if (minutes == 1)
						return @"1 minute ago";
					else
						return [NSString stringWithFormat:@"%d minutes ago", minutes];
				} else {
					//MVR - at this point we know timeInterval is greater than 0 and less than 60
					return @"just now";
				}
			}
		}
	} else {
		days = timeInterval / (24 * 60 * 60);
		if (days > 0) {
			if (days == 1)
				return @"in 1 day";
			else
				return [NSString stringWithFormat:@"in %d days", days];
		}
		else {
			NSInteger hours;
			
			hours = timeInterval / (60 * 60);
			if (hours > 0) {
				if (hours == 1)
					return @"in 1 hour";
				else
					return [NSString stringWithFormat:@"in %d hours", hours];
			} else {
				NSInteger minutes;
				
				minutes = timeInterval / 60;
				if (minutes > 0) {
					if (minutes == 1)
						return @"in 1 minute";
					else
						return [NSString stringWithFormat:@"in %d minutes", minutes];
				} else {
					//MVR - at this point we know timeInterval is greater than 0 and less than 60
					return @"just now";
				}
			}
		}
	}
}

@end
