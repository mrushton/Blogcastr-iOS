//
//  DatePickerController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 4/25/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DatePickerController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	UITableView *tableView;
	UIDatePicker *datePicker;
	NSDate *date;
	id delegate;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign) id delegate;

@end
