//
//  PWAboutScreen.m
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 10.7.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PWAboutScreen.h"
#import "PWHelper.h"
#import "PWPreferences.h"
#import "GTMOAuthViewControllerTouch.h"
#import "SHKActivityIndicator.h"
#import "PWFlickrAuthenticationHandler.h"

@interface PWAboutScreen ()
- (void) enableLogoutButton:(BOOL)enabled;
@end

@implementation PWAboutScreen
@synthesize view;
@synthesize versionLabel;
@synthesize logoutTwitterButton;
@synthesize feedbackButton;

- (id) initWithViewController:(UIViewController*)controller {
    self = [super init];
    if (self) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            [[NSBundle mainBundle] loadNibNamed:@"PWAboutScreen" owner:self options:nil];
        else {
            [[NSBundle mainBundle] loadNibNamed:@"PWiPhoneAboutScreen" owner:self options:nil];
            _originalFeedbackButtonRect = feedbackButton.frame;
        }
        
        versionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Version %@", "version string"), [PWPreferences version]];
        viewController = controller;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(authenticated:)
                                                     name:kAuthenticatedToFlickr
                                                   object:nil];
        
        [self enableLogoutButton:[[PWPreferences authentication] canAuthorize]];
    }
    return self;
}

- (void)dealloc {
    [view release];
    [versionLabel release];
    [logoutTwitterButton release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [feedbackButton release];
    [super dealloc];
}

- (void) authenticated:(NSNotification*)notification {
        [self enableLogoutButton:[[PWPreferences authentication] canAuthorize]];
}

- (IBAction)feedbackClicked:(id)sender {
    if (![PWHelper checkCanSendMailAndShowError])
        return;
    
    MFMailComposeViewController* controller = [[[MFMailComposeViewController alloc] init] autorelease];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    controller.mailComposeDelegate = self;
    [controller setSubject:[NSString stringWithFormat:NSLocalizedString(@"Flickr Explorer %@ Feedback", "flickr feedback email subject"), [PWPreferences version]]];
    [controller setToRecipients:[NSArray arrayWithObject:[PWPreferences supportEmail]]];
    [viewController presentModalViewController:controller animated:YES];
}

- (IBAction)logoutOfTwitter:(id)sender {
    [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:[PWPreferences flickrAppServiceName]];
    [[SHKActivityIndicator currentIndicator] displayCompleted:NSLocalizedString(@"Logged out.", "logged out of flickr")];
    [self enableLogoutButton:NO];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [viewController dismissModalViewControllerAnimated:YES];
}

- (void) enableLogoutButton:(BOOL)enabled {
    [logoutTwitterButton setHidden:!enabled];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (enabled) {
            feedbackButton.frame = _originalFeedbackButtonRect;
        } else {
            feedbackButton.frame = CGRectMake(view.bounds.size.width/2 - feedbackButton.bounds.size.width/2,
                                              _originalFeedbackButtonRect.origin.y,
                                              _originalFeedbackButtonRect.size.width,
                                              _originalFeedbackButtonRect.size.height);
        }
    }
}

@end
