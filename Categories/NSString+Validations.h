//
//  NSString+Validations.h
//  Blogcastr
//
//  Created by Matthew Rushton on 8/13/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Validations)

- (BOOL)isValidFullName;
- (BOOL)isValidUsername;
- (BOOL)isValidEmail;
- (BOOL)isValidPassword;

@end
