//
//  ThumbnailImageView.h
//  Blogcastr
//
//  Created by Matthew Rushton on 9/4/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>


@interface ThumbnailImageView : UIImageView {
	TTURLRequest *request;
	NSString *urlPath;
}

@property (nonatomic, retain) TTURLRequest *request;
@property (nonatomic, copy) NSString *urlPath;

- (void)unsetImage;

@end
