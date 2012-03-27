//
//  FlickrExploreAppDelegate.h
//  FlickrExplore
//
//  Created by Patrik Weiskircher on 11.12.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWFlickrReachabilityChecker.h"

@class FlickrExploreViewController;

@interface FlickrExploreAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
    UIWindow *window;
    FlickrExploreViewController *viewController;
    
    PWFlickrReachabilityChecker* reachability;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FlickrExploreViewController *viewController;

@end

