//
//  UINavigationBar+ButtonColor.m
//  Blogcastr
//
//  Created by Matthew Rushton on 8/3/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "UINavigationBar+ButtonColor.h"

@class UINavigationButton;

@implementation UINavigationBar (ButtonColor)

- (void)changeButtonColor:(UIColor *)color withName:(NSString *)name {
	for (UIView *view in self.subviews) {
		if ([[[view class] description] isEqualToString:@"UINavigationButton"] && [[(UINavigationButton *)view currentTitle] isEqualToString:name])
			[(UINavigationButton *)view setTintColor:color];
	}       
}

@end
