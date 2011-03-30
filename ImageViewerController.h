//
//  ImageViewerController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 3/28/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>


@interface ImageViewerController : UIViewController <TTScrollViewDataSource, TTScrollViewDelegate> {
	TTScrollView *scrollView;
	TTImageView *imageView;
}

@property (nonatomic, retain) TTScrollView *scrollView;
@property (nonatomic, retain) TTImageView *imageView;

- (id)initWithImageView:(TTImageView *)theImageView;
- (BOOL)isShowingBars;
- (void)showBars:(BOOL)show animated:(BOOL)animated;
- (void)showBarsAnimationDidStop;
- (void)hideBarsAnimationDidStop;

@end
