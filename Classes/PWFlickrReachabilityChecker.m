//
//  PWFlickrReachabilityChecker.m
//  FlickrExplorer
//
//  Created by Patrik Weiskircher on 10.7.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PWFlickrReachabilityChecker.h"
#import "Reachability.h"

@implementation PWFlickrReachabilityChecker

- (void)dealloc {
    [noNetworkAlertView dismissWithClickedButtonIndex:0 animated:NO], [noNetworkAlertView release], noNetworkAlertView = nil;
    [super dealloc];
}

- (BOOL) checkReachability {
    [noNetworkAlertView dismissWithClickedButtonIndex:0 animated:YES], [noNetworkAlertView release], noNetworkAlertView = nil;
    
    Reachability* r = [Reachability reachabilityWithHostName:@"api.flickr.com"];
    if (![r isReachable]) {
        noNetworkAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Flickr unreachable.", "no network popup")
                                                        message:NSLocalizedString(@"Please make sure your iOS device can connect to the internet.", @"no network message")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Try again.", "no network try again")
                                              otherButtonTitles:nil];
        [noNetworkAlertView show];
        return NO;
    } 
    return YES;
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self checkReachability];
}
@end
