//
//  BlogcastrStyleSheet.m
//  Blogcastr
//
//  Created by Matthew Rushton on 3/12/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "BlogcastrStyleSheet.h"


@implementation BlogcastrStyleSheet

- (UIColor *)navigationBarTintColor {
	return [UIColor colorWithRed:0.18 green:0.30 blue:0.38 alpha:1.0];
}

- (UIColor *)toolbarTintColor {
	return [UIColor colorWithRed:0.18 green:0.30 blue:0.38 alpha:1.0];
}

- (UIColor *)backgroundColor {
	return [UIColor colorWithRed:0.914 green:0.914 blue:0.914 alpha:1.0];
}

- (UIColor *)lightBackgroundColor {
	return [UIColor whiteColor];
	return [UIColor colorWithRed:0.996 green:0.996 blue:0.996 alpha:1.0];
}

- (UIColor *)tableViewSeperatorColor {
	return [UIColor colorWithRed:0.816 green:0.816 blue:0.816 alpha:1.0];
}

- (UIColor *)tableRefreshHeaderBackgroundColor {
	return [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0];
}

- (UIColor *)blueButtonColor {
	return [UIColor colorWithRed:0.294 green:0.522 blue:0.753 alpha:1.0];
}

- (UIColor *)redButtonColor {
	return [UIColor colorWithRed:0.557 green:0.229 blue:0.127 alpha:1.0];
}

- (UIColor *)blueTextColor {
	return [UIColor colorWithRed:0.22 green:0.329 blue:0.529 alpha:1.0];
}

- (UIColor *)blueGrayTextColor {
	return [UIColor colorWithRed:0.245 green:0.301 blue:0.370 alpha:1.0];
}

- (UIColor *)topBarLabelColor {
	return [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
}

- (TTStyle *)topBar {
	UIColor *gradientColor1;
	UIColor *gradientColor2;
	UIColor *bottomBorderColor;
	
	gradientColor1 = [UIColor colorWithRed:0.918 green:0.918 blue:0.925 alpha:1.0];
	gradientColor2 = [UIColor colorWithRed:0.765 green:0.776 blue:0.796 alpha:1.0];
	bottomBorderColor = [UIColor colorWithRed:0.616 green:0.62 blue:0.635 alpha:1.0];
	
	//MVR - use inset style to get around bottom border not being drawn the full width
	return [TTLinearGradientFillStyle styleWithColor1:gradientColor1 color2:gradientColor2 next:
           [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0.0, -1.0, 0.0, -1.0) next:
           [TTFourBorderStyle styleWithTop:[UIColor whiteColor] right:nil bottom:bottomBorderColor left:nil width:1.0 next:nil]]];
}

- (TTStyle *)avatar:(UIControlState)state {
	NSString *defaultImagePath;
	
	defaultImagePath = [[NSBundle mainBundle] pathForResource:@"avatar" ofType:@"png"];
	if (state & UIControlStateHighlighted)
		return [TTShapeStyle styleWithShape:[TTRectangleShape shape] next:
               [TTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero next:
               [TTSolidFillStyle styleWithColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3] next:nil]]];	
	else
		return [TTShapeStyle styleWithShape:[TTRectangleShape shape] next:
               [TTImageStyle styleWithImageURL:nil defaultImage:[UIImage imageWithContentsOfFile:defaultImagePath] contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero next:nil]];		
}

- (TTStyle *)roundedAvatar:(UIControlState)state {
	NSString *defaultImagePath;
	
	defaultImagePath = [[NSBundle mainBundle] pathForResource:@"avatar" ofType:@"png"];
	if (state & UIControlStateHighlighted)
		return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next: 
               [TTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero next:
               [TTSolidFillStyle styleWithColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3] next:nil]]];	
	else
		return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
               [TTImageStyle styleWithImageURL:nil defaultImage:[UIImage imageWithContentsOfFile:defaultImagePath] contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero next:nil]];		
}

- (TTStyle *)roundedImagePost:(UIControlState)state {
	if (state & UIControlStateHighlighted)
		return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
               [TTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero next:
               [TTSolidFillStyle styleWithColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3] next:nil]]];	
	else
		return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
               [TTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero next:nil]];		
}

- (TTStyle *)blueButton:(UIControlState)state {
	UIColor *stateTintColor;
	UIColor *textShadowColor;
	UIFont *font;
	
	if (state & UIControlStateHighlighted || state & UIControlStateSelected)
		stateTintColor = [UIColor colorWithRed:0.194 green:0.422 blue:0.653 alpha:1.0];
	else
		stateTintColor = [UIColor colorWithRed:0.294 green:0.522 blue:0.753 alpha:1.0];
	textShadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
	font = [UIFont boldSystemFontOfSize:13.0];
    
    return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:14.0] next:
           [TTReflectiveFillStyle styleWithColor:stateTintColor next:
           [TTInnerShadowStyle styleWithColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75] blur:2.0 offset:CGSizeMake(0.0, 1.0) next:
           [TTInnerShadowStyle styleWithColor:[UIColor colorWithRed:0.867 green:0.91 blue:0.894 alpha:1.0] blur:0.0 offset:CGSizeMake(0.0, -1.0) next:
           [TTTextStyle styleWithFont:font color:[UIColor whiteColor] minimumFontSize:0.0 shadowColor:textShadowColor shadowOffset:CGSizeMake(0, 1) textAlignment:UITextAlignmentCenter verticalAlignment:UIControlContentVerticalAlignmentCenter lineBreakMode:UILineBreakModeTailTruncation numberOfLines:1 next:nil]]]]];
}

- (TTStyle *)blueButtonWithImage:(UIControlState)state {
	UIColor *stateTintColor;
	UIColor *textShadowColor;
	UIFont *font;
	
	if (state & UIControlStateHighlighted || state & UIControlStateSelected)
		stateTintColor = [UIColor colorWithRed:0.194 green:0.422 blue:0.653 alpha:1.0];
	else
		stateTintColor = [UIColor colorWithRed:0.294 green:0.522 blue:0.753 alpha:1.0];
	textShadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
	font = [UIFont boldSystemFontOfSize:13.0];

    return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:14.0] next:
           [TTReflectiveFillStyle styleWithColor:stateTintColor next:
           [TTInnerShadowStyle styleWithColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75] blur:2.0 offset:CGSizeMake(0.0, 1.0) next:
           [TTInnerShadowStyle styleWithColor:[UIColor colorWithRed:0.867 green:0.91 blue:0.894 alpha:1.0] blur:0.0 offset:CGSizeMake(0.0, -1.0) next:
           [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(6.0, 10.0, 0.0, 0.0) next:
           [TTShapeStyle styleWithShape:[TTRectangleShape shape] next:
           [TTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeTopLeft size:CGSizeMake(17.0, 16.0) next:
           [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(-6.0, 20.0, 0.0, 0.0) next:
           [TTTextStyle styleWithFont:font color:[UIColor whiteColor] minimumFontSize:0.0 shadowColor:textShadowColor shadowOffset:CGSizeMake(0, 1) textAlignment:UITextAlignmentLeft verticalAlignment:UIControlContentVerticalAlignmentCenter lineBreakMode:UILineBreakModeTailTruncation numberOfLines:1 next:nil]]]]]]]]];
}

- (TTStyle *)orangeButtonWithImage:(UIControlState)state {
	UIColor *stateTintColor;
	UIColor *textShadowColor;
	UIFont *font;
	
	if (state & UIControlStateHighlighted || state & UIControlStateSelected)
		stateTintColor = [UIColor colorWithRed:0.772 green:0.591 blue:0.207 alpha:1.0];
	else
		stateTintColor = [UIColor colorWithRed:0.872 green:0.691 blue:0.307 alpha:1.0];
	textShadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
	font = [UIFont boldSystemFontOfSize:13.0];	

    return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:14.0] next:
           [TTReflectiveFillStyle styleWithColor:stateTintColor next:
           [TTInnerShadowStyle styleWithColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75] blur:2.0 offset:CGSizeMake(0.0, 1.0) next:
           [TTInnerShadowStyle styleWithColor:[UIColor colorWithRed:0.867 green:0.91 blue:0.894 alpha:1.0] blur:0.0 offset:CGSizeMake(0.0, -1.0) next:
           [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(6.0, 10.0, 0.0, 0.0) next:
           [TTShapeStyle styleWithShape:[TTRectangleShape shape] next:
           [TTImageStyle styleWithImageURL:nil defaultImage:nil	contentMode:UIViewContentModeTopLeft size:CGSizeMake(19.0, 16.0) next:
           [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(-6.0, 22.0, 0.0, 0.0) next:
           [TTTextStyle styleWithFont:font color:[UIColor whiteColor] minimumFontSize:0.0 shadowColor:textShadowColor shadowOffset:CGSizeMake(0, 1) textAlignment:UITextAlignmentLeft verticalAlignment:UIControlContentVerticalAlignmentCenter lineBreakMode:UILineBreakModeTailTruncation numberOfLines:1 next:nil]]]]]]]]];
}

- (TTStyle *)redTableFooterButton:(UIControlState)state {
	UIColor *stateTintColor;
	UIFont *font;

	if (state & UIControlStateHighlighted || state & UIControlStateSelected)
		stateTintColor = [UIColor colorWithRed:0.457 green:0.129 blue:0.027 alpha:1.0];
	else
		stateTintColor = [UIColor colorWithRed:0.557 green:0.229 blue:0.127 alpha:1.0];
	font = [UIFont boldSystemFontOfSize:18.0];

	return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:12.0] next:
           [TTInsetStyle styleWithInset:UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0) next:
           [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.18) blur:0 offset:CGSizeMake(0, 1) next:
           [TTReflectiveFillStyle styleWithColor:stateTintColor next:
           [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-1.0, -1.0, -1.0, -1.0) next:
           [TTSolidBorderStyle styleWithColor:[UIColor colorWithRed:0.208 green:0.22 blue:0.259 alpha:1.0] width:3 next:
           [TTTextStyle styleWithFont:font color:[UIColor whiteColor] shadowColor:[UIColor colorWithWhite:0.0 alpha:0.4] shadowOffset:CGSizeMake(0, 1) next:nil]]]]]]];
}

- (TTStyle *)stat {
	UIColor *gradientColor1;
	UIColor *gradientColor2;
	
	gradientColor1 = [UIColor colorWithRed:0.984 green:0.980 blue:0.973 alpha:1.0];
	gradientColor2 = [UIColor colorWithRed:0.863 green:0.863 blue:0.863 alpha:1.0];

	return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:6.0] next:
           [TTShadowStyle styleWithColor:[UIColor colorWithRed:0.718 green:0.718 blue:0.718 alpha:1.0] blur:2.0 offset:CGSizeMake(0.0, 2.0) next:
           [TTLinearGradientFillStyle styleWithColor1:gradientColor1 color2:gradientColor2 next:
           [TTInnerShadowStyle styleWithColor:[UIColor colorWithRed:0.976 green:0.976 blue:0.976 alpha:1.0] blur:0.0 offset:CGSizeMake(0.0, -1.0) next:nil]]]];
}

- (TTStyle *)currentViewers {
	UIColor *gradientColor1;
	UIColor *gradientColor2;
	
	gradientColor1 = [UIColor colorWithRed:0.988 green:0.835 blue:0.227 alpha:1.0];
	gradientColor2 = [UIColor colorWithRed:0.875 green:0.58 blue:0.004 alpha:1.0];
	
	return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:6.0] next:
           [TTShadowStyle styleWithColor:[UIColor colorWithRed:0.718 green:0.718 blue:0.718 alpha:1.0] blur:2.0 offset:CGSizeMake(0.0, 2.0) next:
           [TTLinearGradientFillStyle styleWithColor1:gradientColor1 color2:gradientColor2 next:
           [TTInnerShadowStyle styleWithColor:[UIColor colorWithRed:0.996 green:0.937 blue:0.718 alpha:1.0] blur:0.0 offset:CGSizeMake(0.0, 1.0) next:nil]]]];
}

- (TTStyle *)tag {
	return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:12.0] next:
           [TTSolidFillStyle styleWithColor:[UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0] next:
           [TTInnerShadowStyle styleWithColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25] blur:2.0 offset:CGSizeMake(0.0, 1.0) next:
           [TTInnerShadowStyle styleWithColor:[UIColor colorWithRed:0.976 green:0.976 blue:0.976 alpha:1.0] blur:0.0 offset:CGSizeMake(0.0, -1.0) next:
           [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(4.0, 10.0, 5.0, 10.0) next:
           [TTTextStyle styleWithFont:[UIFont systemFontOfSize:13.0] color:[UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:1.0] next:nil]]]]]];
}

- (TTStyle *)timestampInWords {
    //MVR - right padding changed for iOS 5
	return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:2.5] next:
           [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0.0, -3.0, -1.0, -1.0) next:
           [TTSolidFillStyle styleWithColor:[UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0] next:
           [TTInnerShadowStyle styleWithColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] blur:1.0 offset:CGSizeMake(0.0, 1.0) next:
           [TTInnerShadowStyle styleWithColor:[UIColor colorWithRed:0.976 green:0.976 blue:0.976 alpha:1.0] blur:0.0 offset:CGSizeMake(0.0, -1.0) next:
           [TTTextStyle styleWithFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:9.0] color:[self blueGrayTextColor] next:nil]]]]]];
}

@end
