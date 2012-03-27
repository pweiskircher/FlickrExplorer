//
//  PWFlickrAuthenticationHandler.m
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 20.9.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PWFlickrAuthenticationHandler.h"

#import "GTMOAuthAuthentication.h"
#import "GTMOAuthViewControllerTouch.h"
#import "PWPreferences.h"

NSString * const kAuthenticatedToFlickr = @"kAuthenticatedToFlickr";

@interface PWFlickrAuthenticationHandler ()
- (GTMOAuthViewControllerTouch*) authenticationViewControllerWithAuth:(GTMOAuthAuthentication*)auth;
@end

@implementation PWFlickrAuthenticationHandler
@synthesize block;

- (void)dealloc {
    block = nil;
    [super dealloc];
}

- (GTMOAuthViewControllerTouch*) authenticationViewControllerWithAuth:(GTMOAuthAuthentication*)auth {
    [auth setCallback:@"http://flickrexplorer.weiskircher.name/OAuthCallback"];
    GTMOAuthViewControllerTouch* viewController;
    
    viewController = [[[GTMOAuthViewControllerTouch alloc] initWithScope:@"http://api.flickr.com"
                                                                language:nil
                                                         requestTokenURL:[PWPreferences flickrRequestUrl]
                                                       authorizeTokenURL:[PWPreferences flickrAuthorizeUrl]
                                                          accessTokenURL:[PWPreferences flickrAccessUrl]
                                                          authentication:auth
                                                          appServiceName:[PWPreferences flickrAppServiceName]
                                                       delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
    viewController.initialHTMLString = @"<html><head><style type=\"text/css\">body { background-color: #000; font-family: Helvetica; color: #FFF; }</style></head><body><br/><br/><h3>Loading Flickr Login Page …</h3></body></html>";
    return viewController;
}

- (void) viewController:(GTMOAuthViewControllerTouch*)viewController finishedWithAuth:(GTMOAuthAuthentication*)auth error:(NSError*)error {
    if (_popoverController) {
        [_popoverController dismissPopoverAnimated:YES];
        [_popoverController release];
        _popoverController = nil;
    } else if (_viewController) {
        [_viewController dismissModalViewControllerAnimated:YES];
        [_viewController release];
        _viewController = nil;
    }
    
    if (error == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticatedToFlickr object:nil];
    }
    self.block(error == nil);
}

- (void) presentFromBarButtonItem:(UIBarButtonItem*)barButtonItem withMaximumSize:(CGSize)size withBlock:(void(^)(BOOL success))aBlock {
    self.block = aBlock;
    _popoverController = [[UIPopoverController alloc] initWithContentViewController:[self authenticationViewControllerWithAuth:[PWPreferences authentication]]];
    [_popoverController setPopoverContentSize:CGSizeMake(size.width*0.8, size.height*0.8)];
    [_popoverController presentPopoverFromBarButtonItem:barButtonItem
                       permittedArrowDirections:UIPopoverArrowDirectionAny
                                       animated:YES];    
}

- (void) presentInViewController:(UIViewController*)viewController withBlock:(void(^)(BOOL success))aBlock {
    self.block = aBlock;
    _viewController = [viewController retain];
    GTMOAuthViewControllerTouch* authViewController = [self authenticationViewControllerWithAuth:[PWPreferences authentication]];
    UINavigationController* navController = [[[UINavigationController alloc] initWithRootViewController:authViewController] autorelease];
    authViewController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                                      target:self
                                                                                                                       action:@selector(dismissNavController:)] autorelease];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    [_viewController presentModalViewController:navController
                                       animated:YES];
}

- (void) dismissNavController:(id)sender {
    [_viewController dismissModalViewControllerAnimated:YES];
    [_viewController release];
    _viewController = nil;
    self.block(NO);
}

@end
