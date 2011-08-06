//
//  ResizeImageOperation.m
//  Blogcastr
//
//  Created by Matthew Rushton on 7/27/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import "ResizeImageOperation.h"
#import "UIImage+Resize.h"


@implementation ResizeImageOperation

@synthesize image;
@synthesize imageViewerController;

static const CGFloat kScaleFactor = 2.0f;

- (void)dealloc {
	[image release];
	[imageViewerController release];
	[super dealloc];
}

- (void)main {
	CGFloat scaleFactor;
	UIImage *resizedImage;

	//MVR - scale either width or height by a factor of screen resolution
	if (image.size.width / image.size.height > 320.0 / 480.0)
		scaleFactor = image.size.width / (320.0 * kScaleFactor);
	else
		scaleFactor = image.size.height / (480.0 * kScaleFactor);
	//TODO: move this check into the controller as well since the image needs no resizing
	if (scaleFactor > 1.0)
		resizedImage = [image resizedImage:CGSizeMake(image.size.width * image.scale / scaleFactor, image.size.height * image.scale / scaleFactor) interpolationQuality:kCGInterpolationHigh];
	else
		resizedImage = image;
	//MVR - all UI processing done on main thread
	[imageViewerController performSelectorOnMainThread:@selector(resizedImage:) withObject:resizedImage waitUntilDone:YES];
}

@end
