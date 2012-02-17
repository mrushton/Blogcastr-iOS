//
//  NSDate+Format.m
//  Blogcastr
//
//  Created by Matthew Rushton on 1/23/12.
//  Copyright (c) 2012 Blogcastr. All rights reserved.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)

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

- (NSString *)iso8601 {
    NSDateFormatter *dateFormatter;
    NSTimeZone *timeZone;
    NSInteger offset;
    NSMutableString *format;
    
    format = [NSMutableString stringWithString:@"yyyy-MM-dd'T'HH:mm:ss"];
    timeZone = [NSTimeZone localTimeZone];
    offset = [timeZone secondsFromGMT];
    if (offset > 0)
        [format appendFormat:@"+%02d:%02d", offset / 3600, (offset / 60) % 60];
    else if (offset < 0)
        [format appendFormat:@"-%02d:%02d", -offset / 3600, (-offset / 60) % 60];
    else
        [format appendString:@"Z"];
    dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:format];

    return [dateFormatter stringFromDate:self];
}

+ (NSDate *)dateWithIso8601:(NSString *)string {
    NSMutableString *tmp;
	NSMutableString *format;
    NSDateFormatter *dateFormatter;

    format = [NSMutableString stringWithString:@"yyyy-MM-dd'T'HH:mm:ss"];
    if ([string length] == 20) {
        [format appendString:@"z"];
        tmp = [NSString stringWithFormat:@"%@UTC", [string substringWithRange:NSMakeRange(0, 19)]];
    } else {
        [format appendString:@"ZZ"];
        tmp = [NSMutableString stringWithString:string];
        //TODO: should catch NSRangeException
        [tmp deleteCharactersInRange:NSMakeRange(22, 1)];
    }
    dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:format];
    
	return [dateFormatter dateFromString:tmp];
}

@end
