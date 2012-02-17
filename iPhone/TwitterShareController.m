//
//  TwitterShareController.m
//  Blogcastr
//
//  Created by Matthew Rushton on 12/20/11.
//  Copyright (c) 2011 Blogcastr. All rights reserved.
//

#import <Three20/Three20.h>
#import "TwitterShareController.h"
#import "BlogcastrStyleSheet.h"
#import "TwitterCredentials.h"


@implementation TwitterShareController

@synthesize session;
@synthesize textView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        UITextView *theTextView;
        UIBarButtonItem *cancelButton;
		UIBarButtonItem *tweetButton;
        
		// Custom initialization.
        self.tableView.backgroundColor = TTSTYLEVAR(backgroundColor);
        theTextView = [[UITextView alloc] initWithFrame:CGRectMake(2.0, 4.0, 296.0, 112.0)];
        theTextView.delegate = self;
        //MVR - slight hack with insets to make the top align a little nicer
        theTextView.contentInset = UIEdgeInsetsMake(-4.0, 0.0, 0.0, 0.0);
        theTextView.backgroundColor = [UIColor clearColor];	
        theTextView.font = [UIFont systemFontOfSize:15.0];
        theTextView.textColor = BLOGCASTRSTYLEVAR(blueTextColor);
        self.textView = theTextView;
        [theTextView release];
        self.navigationItem.title = @"Twitter Share";
		cancelButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
		cancelButton.title = @"Cancel";
		self.navigationItem.leftBarButtonItem = cancelButton;
		[cancelButton release];
		tweetButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleBordered target:self action:@selector(tweet)];
		tweetButton.title = @"Tweet";
		self.navigationItem.rightBarButtonItem = tweetButton;
		[tweetButton release];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    // Configure the cell...
    //AS DESIGNED: only a few cells no need to make them reusable
	cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:textView];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
            
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return [NSString stringWithFormat:@"Tweeting from %@", session.user.twitterUsername];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [session release];
    [textView release];
    [text release];
    _twitterXAuth.delegate = nil;
    [_twitterXAuth cancel];
    [_twitterXAuth release];
    _progressHud.delegate = nil;
    [_progressHud release];
    [_cancelActionSheet release];
    [_cancelRequestActionSheet release];
    [_alertView release];
    [super dealloc];
}

- (TwitterXAuth *)twitterXAuth {
	if (!_twitterXAuth) {
        _twitterXAuth = [[TwitterXAuth alloc] init];
        _twitterXAuth.consumerKey = CONSUMER_KEY;
        _twitterXAuth.consumerSecret = CONSUMER_SECRET;
        _twitterXAuth.token = session.user.twitterAccessToken;
        _twitterXAuth.tokenSecret = session.user.twitterTokenSecret;
        _twitterXAuth.delegate = self;
	}
	
	return _twitterXAuth;
}

- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        //MVR - modal view can cancel
        if (self.presentingViewController)
            _progressHud = [[MBProgressHUD alloc] initWithView:self.view.superview];
        else
            _progressHud = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
        _progressHud.delegate = self;
	}
    
    return _progressHud;
}

- (UIAlertView *)alertView {
	if (!_alertView) {
		_alertView = [[UIAlertView alloc] init];
		[_alertView addButtonWithTitle:@"Ok"];
	}
	
	return _alertView;
}

- (UIActionSheet *)cancelActionSheet {
	if (!_cancelActionSheet)
		_cancelActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Discard Tweet" otherButtonTitles: nil];
	
	return _cancelActionSheet;
}

- (UIActionSheet *)cancelRequestActionSheet {
	if (!_cancelRequestActionSheet)
		_cancelRequestActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Discard Tweet" otherButtonTitles:@"Cancel Sending", nil];
	
	return _cancelRequestActionSheet;
}

#pragma mark -
#pragma mark UITextView delegate

- (void)textViewDidChange:(UITextView *)theTextView {
	if (!textView.text || [textView.text isEqualToString:@""])
		self.navigationItem.rightBarButtonItem.enabled = NO;
	else
		self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark -
#pragma mark TwitterXAuth delegate

- (void)twitterXAuthTweetDidFail:(TwitterXAuth *)twitterXAuth {
    isTweeting = NO;
    //MVR - hide the progress HUD
	[self.progressHud hide:YES];
    //MVR - enable tweet button
	self.navigationItem.rightBarButtonItem.enabled = YES;
    if (twitterXAuth.error == TwitterXAuthConnectionError) {
        NSLog(@"Connection error making tweet");
        [self errorAlertWithTitle:@"Connection Error" message:@"Oops! We couldn't make the tweet."];
    } else {
        NSLog(@"Twitter error making tweet");
        [self errorAlertWithTitle:@"Twitter Error" message:@"Oops! We couldn't make the tweet."];
    }
}

- (void)twitterXAuthDidTweet:(TwitterXAuth *)twitterXAuth {
	//MVR - we need to dismiss the action sheet here for some reason
	if (self.cancelRequestActionSheet.visible)
		[self.cancelRequestActionSheet dismissWithClickedButtonIndex:0 animated:YES];
	//MVR - hide the progress HUD
	[self.progressHud hide:YES];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate delegate

- (void)hudWasHidden:(MBProgressHUD *)theProgressHUD {
	//MVR - remove HUD from screen when the HUD was hidden
	[theProgressHUD removeFromSuperview];
}

#pragma mark -
#pragma mark Action sheet delegate

- (void)actionSheet:(UIActionSheet *)theActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (theActionSheet == _cancelRequestActionSheet) {
		if (buttonIndex == 0) {
            [self.twitterXAuth cancel];
			[self dismissModalViewControllerAnimated:YES];
		} else if (buttonIndex == 1) {
			[self.twitterXAuth cancel];
            //MVR - hide the progress HUD
            [self.progressHud hide:YES];
            //MVR - enable tweet button
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
	} else if (theActionSheet == _cancelActionSheet) {
		if (buttonIndex == 0)
			[self dismissModalViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark Actions

- (void)tweet {
    isTweeting = YES;
    //MVR - dismiss keyboard
	[textView resignFirstResponder];
    //MVR - disable tweet button
	self.navigationItem.rightBarButtonItem.enabled = NO;
    [self showProgressHudWithLabelText:@"Tweeting..." animated:YES animationType: MBProgressHUDAnimationZoom];
    [self.twitterXAuth tweet:textView.text];
}

- (void)cancel {
    //MVR - need to make sure we aren't tweeting 
    if (([textView.text isEqualToString:text] || !textView.text || [textView.text isEqualToString:@""]) && !isTweeting) {
		[self dismissModalViewControllerAnimated:YES];
		return;
	}
    if (isTweeting)
        [self.cancelRequestActionSheet showInView:self.navigationController.view];
    else
        [self.cancelActionSheet showInView:self.navigationController.view];
}

#pragma mark -
#pragma mark Helpers

- (NSString *)text {
    return text;
}

- (void)setText:(NSString *)theText {
    NSString *tmp;

    tmp = text;
    text = [theText copy];
    [tmp release];
    //MVR - update text view
    textView.text = theText;
}

- (void)showProgressHudWithLabelText:(NSString *)labelText animated:(BOOL)animated animationType:(MBProgressHUDAnimation)animationType {
	self.progressHud.labelText = labelText;
	if (animated)
		self.progressHud.animationType = animationType;
    [self.view.superview addSubview:self.progressHud];
	[self.progressHud show:animated];
}

- (void)errorAlertWithTitle:(NSString *)title message:(NSString *)message {
	//MVR - update and display the alert view
	self.alertView.title = title;
	self.alertView.message = message;
	[self.alertView show];
}

@end
