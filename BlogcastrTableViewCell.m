//
//  BlogcastrTableViewCell.m
//  Blogcastr
//
//  Created by Matthew Rushton on 4/4/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BlogcastrTableViewCell.h"
#import "BlogcastrStyleSheet.h"


@implementation BlogcastrTableViewCell

@synthesize highlightView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		UIView *borderView;

		// Initialization code.
		self.backgroundColor == BLOGCASTRSTYLEVAR(backgroundColor);
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, 1.0)];
		borderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		borderView.backgroundColor = BLOGCASTRSTYLEVAR(lightBackgroundColor);
		[self.contentView addSubview:borderView];
		[borderView release];
		highlightView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height)];
		highlightView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		highlightView.backgroundColor = [UIColor blackColor];
		//MVR - hidden until selected
		highlightView.alpha = 0.0;
		[self.contentView addSubview:highlightView];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	if (highlighted)
		highlightView.alpha = 0.3;
	else
		highlightView.alpha = 0.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
	if (selected) {
		highlightView.alpha = 0.3;
	} else {
		//MVR - animate table navigation
		if (animated) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			highlightView.alpha = 0.0;
			[UIView commitAnimations];
		} else {
			highlightView.alpha = 0.0;
		}
	}
}


- (void)dealloc {
	[highlightView release];
    [super dealloc];
}


@end
