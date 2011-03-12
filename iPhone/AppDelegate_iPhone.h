//
//  AppDelegate_iPhone.h
//  Blogcastr
//
//  Created by Matthew Rushton on 2/21/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate_Shared.h"
#import "RootController_iPhone.h"

@interface AppDelegate_iPhone : AppDelegate_Shared {
	RootController_iPhone *rootController;
}

@property (nonatomic, retain) RootController_iPhone *rootController;


@end

