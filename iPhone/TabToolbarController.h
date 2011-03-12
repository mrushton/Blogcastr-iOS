//
//  TabToolbarController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 2/26/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>


#define TAB_TOOLBAR_VIEW_TAG 7

@interface TabToolbarController : UIViewController <UITabBarDelegate> {
	NSArray *viewControllers;
	NSUInteger selectedIndex;
	UITabBar *tabBar;
}

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic, retain) UITabBar *tabBar;

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;

@end
