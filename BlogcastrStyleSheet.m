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

- (TTStyle *)roundedAvatar:(UIControlState)state {
	if (state & UIControlStateHighlighted)
		return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:4] next: 
               [TTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero next:
               [TTSolidFillStyle styleWithColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3] next:nil]]];	
	else
		return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:4] next: 
               [TTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero next:nil]];		
}

- (TTStyle *)redTableFooterButton:(UIControlState)state {
	UIColor *stateTintColor;
	UIFont *font;
	
	
	if (state & UIControlStateHighlighted || state & UIControlStateSelected) {
		stateTintColor = [UIColor colorWithRed:0.457 green:0.129 blue:0.027 alpha:1.0];
	} else {
		stateTintColor = [UIColor colorWithRed:0.557 green:0.229 blue:0.127 alpha:1.0];
	}
	font = [UIFont boldSystemFontOfSize:18.0];

	
	return
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:12.0] next:
	 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0) next:
	//  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.18) blur:0 offset:CGSizeMake(0, 1) next:

	   [TTReflectiveFillStyle styleWithColor:stateTintColor next:
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(-1.0, -1.0, -1.0, -1.0) next:
		[TTSolidBorderStyle styleWithColor:[UIColor colorWithRed:0.208 green:0.22 blue:0.259 alpha:1.0] width:3 next:

	//	[TTBevelBorderStyle styleWithHighlight:[stateTintColor multiplyHue:1 saturation:0.9 value:0.7]
//										shadow:[stateTintColor multiplyHue:1 saturation:0.5 value:0.6]
//										 width:1 lightSource:270 next:
		// [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
		 //  [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 8, 8, 8) next:
			//[TTImageStyle styleWithImageURL:nil defaultImage:nil
			//					contentMode:UIViewContentModeScaleToFill size:CGSizeZero next:
				 [TTTextStyle styleWithFont:font
								  color:[UIColor whiteColor] shadowColor:[UIColor colorWithWhite:0.0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, 1) next:nil]]]]]];
	

}

- (TTStyle *)statView:(UIControlState)state {
	UIColor *gradientColor1;
	UIColor *gradientColor2;
	
	gradientColor1 = [UIColor colorWithRed:0.984 green:0.980 blue:0.973 alpha:1.0];
	gradientColor2 = [UIColor colorWithRed:0.863 green:0.863 blue:0.863 alpha:1.0];

	return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:6.0] next:
           [TTShadowStyle styleWithColor:[UIColor colorWithRed:0.718 green:0.718 blue:0.718 alpha:1.0] blur:2.0 offset:CGSizeMake(0.0, 2.0) next:
           [TTLinearGradientFillStyle styleWithColor1:gradientColor1 color2:gradientColor2 next:
           [TTInnerShadowStyle styleWithColor:[UIColor colorWithRed:0.976 green:0.976 blue:0.976 alpha:1.0] blur:0.0 offset:CGSizeMake(0.0, -1.0) next:nil]]]];
}

@end
