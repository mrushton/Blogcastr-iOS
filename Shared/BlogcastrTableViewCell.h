//
//  BlogcastrTableViewCell.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/4/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>


#define TITLE_LABEL_TAG 1
#define TIMESTAMP_LABEL_TAG 2
#define IMAGE_VIEW_TAG 3
#define USERNAME_LABEL_TAG 4
#define DESCRIPTION_VIEW_TAG 5
#define TEXT_VIEW_TAG 6
#define RIGHT_ARROW_VIEW_TAG 7

@interface BlogcastrTableViewCell : UITableViewCell {
	UIView *highlightView;
}

@property (nonatomic, retain) UIView *highlightView;

@end
