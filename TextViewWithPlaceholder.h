//
//  TextViewWithPlaceholder.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/28/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextViewWithPlaceholder : UITextView  {
    NSString *placeholder;
    UIColor *placeholderColor;
}

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
