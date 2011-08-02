//
//  ResizeImageOperation.h
//  Blogcastr
//
//  Created by Matthew Rushton on 7/27/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageViewerController.h"


@interface ResizeImageOperation : NSOperation {
	UIImage *image;
	ImageViewerController *imageView;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) ImageViewerController *imageViewerController;

@end
