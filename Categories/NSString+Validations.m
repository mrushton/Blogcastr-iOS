//
//  NSString+Validations.m
//  Blogcastr
//
//  Created by Matthew Rushton on 8/13/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "NSString+Validations.h"


@implementation NSString (Validations)

- (BOOL)isValidFullName {
	if ([self isEqualToString:@""])
		return NO;
	else
		return YES;
}

- (BOOL)isValidUsername {
	NSError *error = NULL;
	NSRegularExpression *regex;
	NSUInteger numMatches;

	//MVR - first check length
	if ([self length] < 4 || [self length] > 15)
		return NO;
	regex = [NSRegularExpression regularExpressionWithPattern:@"\\A[\\w_]*\\z" options:0 error:&error];
	numMatches = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];
	if (numMatches)
		return YES;
	else
		return NO;
}

- (BOOL)isValidEmail {
	NSError *error = NULL;
	NSRegularExpression *regex;
	NSUInteger numMatches;

	//MVR - just a simple email check which is the same as Clearance
	regex = [NSRegularExpression regularExpressionWithPattern:@"\\A.+@.+\\..+\\z" options:0 error:&error];
	numMatches = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];
	if (numMatches)
		return YES;
	else
		return NO;
}

- (BOOL)isValidPassword {
	if ([self length] < 6)
		return NO;
	else
		return YES;
}

@end
