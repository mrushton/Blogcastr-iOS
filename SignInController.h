//
//  SignInController.h
//  Blogcastr
//
//  Created by Matthew Rushton on 2/26/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "MBProgressHUD.h"

@protocol SignInControllerProtocol

- (void)signIn;

@end

@interface SignInController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate, MBProgressHUDDelegate> {
    NSManagedObjectContext *managedObjectContext;
	Session *session;
    NSString *username;
	NSString *password;
    //MVR - url connection dictionary
	//AS DESIGNED: NSMutableDictionary is not used because NSURLConnection does not support copying	
	CFMutableDictionaryRef urlConnectionDataMutableDictionaryRef_;
    //MVR - xml parser
	//AS DESIGNED: xml parsing does not need to be thread safe
    NSMutableString *xmlParserMutableString;
	NSString *xmlParserAuthenticationToken;
	NSString *xmlParserId;
	NSString *xmlParserUsername;
	NSString *xmlParserAvatarUrl;
	NSString *xmlParserBio;
	NSString *xmlParserFullName;
	NSString *xmlParserLocation;
	NSString *xmlParserWeb;
	NSString *xmlParserNumBlogacsts;
	NSString *xmlParserNumSubscriptions;
	NSString *xmlParserNumSubscribers;
	NSString *xmlParserNumPosts;
	NSString *xmlParserNumComments;
	NSString *xmlParserNumLikes;
	BOOL xmlParserInBlogcastrUser;
	BOOL xmlParserInSetting;
	BOOL xmlParserInStats;
	//MVR - use a delegate to properly get rid of a compiler warning
	id<SignInControllerProtocol> delegate;
	UITextField *usernameTextField;
	UITextField *passwordTextField;
	MBProgressHUD *progressHUD;
	UIAlertView *alertView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Session *session;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, readonly) CFMutableDictionaryRef urlConnectionDataMutableDictionaryRef;
@property (nonatomic, copy) NSString *xmlParserMutableString;
@property (nonatomic, copy) NSString *xmlParserAuthenticationToken;
@property (nonatomic, copy) NSString *xmlParserId;
@property (nonatomic, copy) NSString *xmlParserUsername;
@property (nonatomic, copy) NSString *xmlParserAvatarUrl;
@property (nonatomic, copy) NSString *xmlParserBio;
@property (nonatomic, copy) NSString *xmlParserFullName;
@property (nonatomic, copy) NSString *xmlParserLocation;
@property (nonatomic, copy) NSString *xmlParserWeb;
@property (nonatomic, copy) NSString *xmlParserNumBlogcasts;
@property (nonatomic, copy) NSString *xmlParserNumSubscriptions;
@property (nonatomic, copy) NSString *xmlParserNumSubscribers;
@property (nonatomic, copy) NSString *xmlParserNumPosts;
@property (nonatomic, copy) NSString *xmlParserNumComments;
@property (nonatomic, copy) NSString *xmlParserNumLikes;
@property (nonatomic, retain) id<SignInControllerProtocol> delegate;
@property (nonatomic, retain) UITextField *usernameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;
@property (nonatomic, retain) MBProgressHUD *progressHUD;
@property (nonatomic, retain) UIAlertView *alertView;

- (IBAction)usernameEntered:(id)object;
- (IBAction)signIn:(id)object;
- (void)connection:(NSURLConnection *)urlConnection didReceiveResponse:(NSURLResponse *)urlResponse;
- (void)connection:(NSURLConnection *)urlConnection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)urlConnection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)urlConnection;
- (void)parserDidEndDocument:(NSXMLParser *)parser;
- (void)parserDidStartDocument:(NSXMLParser *)parser;
- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError;
- (void)errorAlert:(NSString *)error;

@end
