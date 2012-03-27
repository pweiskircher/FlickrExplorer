//
//  PWLoadingMessage.h
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 12.12.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PWLoadingMessage : UIView {
	NSString* message;
	UIActivityIndicatorView* activityView;
	UILabel* label;
	UIFont* font;
	BOOL hidesWhenStopped;
}
@property(nonatomic, readwrite, retain) NSString* message;
@property(nonatomic, readwrite, assign) BOOL hidesWhenStopped;

- (void) startAnimating;
- (void) startAnimatingWithFadeInAnimation:(BOOL)animation;
- (void) stopAnimating;

@end
