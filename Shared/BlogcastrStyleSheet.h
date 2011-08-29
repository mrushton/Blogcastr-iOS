//
//  BlogcastrStyleSheet.h
//  Blogcastr
//
//  Created by Matthew Rushton on 3/12/11.
//  Copyright 2011 Blogcastr. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

#define BLOGCASTRSTYLESHEET ((BlogcastrStyleSheet *)[TTStyleSheet globalStyleSheet])
#define BLOGCASTRSTYLEVAR(_VARNAME) [BLOGCASTRSTYLESHEET _VARNAME]

@interface BlogcastrStyleSheet : TTDefaultStyleSheet {

}

- (UIColor *)tableViewSeperatorColor;
- (UIColor *)lightBackgroundColor;
- (UIColor *)blueButtonColor;
- (UIColor *)redButtonColor;
- (UIColor *)blueTextColor;
- (UIColor *)blueGrayTextColor;

@end
