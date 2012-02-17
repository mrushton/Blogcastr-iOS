//
//  NSDate+Format.h
//  Blogcastr
//
//  Created by Matthew Rushton on 1/23/12.
//  Copyright (c) 2012 Blogcastr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSDate.h>

@interface NSDate (Format)

+ (NSDate *)dateWithIso8601: (NSString *)string;
- (NSString *)stringInWords;
- (NSString *)iso8601;

@end
