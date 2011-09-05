//
//  ThumbnailImageView.m
//  Blogcastr
//
//  Created by Matthew Rushton on 9/4/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "ThumbnailImageView.h"
#import "UIImage+Resize.h"


@implementation ThumbnailImageView


@synthesize request;
@synthesize urlPath;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[request cancel];
	[request release];
	[urlPath release];
    [super dealloc];
}

- (void)setImage:(UIImage *)theImage {
	UIImage *thumbnailImage;

	if ([[UIScreen mainScreen] scale] > 1.0)
		thumbnailImage = [theImage thumbnailImage:self.frame.size.width * 2 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
	else
		thumbnailImage = [theImage thumbnailImage:self.frame.size.width transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
	[super setImage:thumbnailImage];
}
 
- (void)setUrlPath:(NSString *)theUrlPath {
	UIImage *theImage;

    [urlPath release];
    urlPath = [theUrlPath copy];
	theImage = [[TTURLCache sharedCache] imageForURL:theUrlPath];
	if (theImage) {
		self.image = theImage;		
	} else {
		TTURLRequest *theRequest;
		
		theRequest = [TTURLRequest requestWithURL:urlPath delegate:self];
		theRequest.response = [[[TTURLImageResponse alloc] init] autorelease];
		self.request = theRequest;
		//TODO: check return value
		[theRequest send];
	}
}

- (void)unsetImage {
	[request cancel];
	self.image = nil;
}

#pragma mark -
#pragma mark TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest *)theRequest {
}

- (void)requestDidFinishLoad:(TTURLRequest*)theRequest {
	TTURLImageResponse *response;
	
	response = theRequest.response;
	self.image = response.image;
	self.request = nil;
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	NSLog(@"ThumbnailImageView failed to load: %@", [error localizedDescription]);
	self.request = nil;
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
	self.request = nil;
}


@end
