//
//  PWFlickrAuthenticationHandler.h
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 20.9.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kAuthenticatedToFlickr;

@interface PWFlickrAuthenticationHandler : NSObject {
    UIPopoverController* _popoverController;
    UIViewController* _viewController;
}
@property(nonatomic, readwrite, copy) void (^block)(BOOL success);
- (void) presentFromBarButtonItem:(UIBarButtonItem*)barButtonItem  withMaximumSize:(CGSize)size withBlock:(void(^)(BOOL success))block;
- (void) presentInViewController:(UIViewController*)viewController withBlock:(void(^)(BOOL success))block;
@end
